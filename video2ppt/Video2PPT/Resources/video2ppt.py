from json.encoder import INFINITY
import math
import cv2
import os
import shutil
import click
import time
from tqdm import tqdm

from .compare import compareImg
from .images2pdf import images2pdf

DEFAULT_PATH = './.extract-video-ppt-tmp-data'
DEFAULT_PDFNAME = 'output.pdf'
DEFAULT_MAXDEGREE = 0.6
CV_CAP_PROP_FRAME_WIDTH = 1920
CV_CAP_PROP_FRAME_HEIGHT = 1080
INFINITY_SIGN = 'INFINITY'
ZERO_SISG = '00:00:00'
DEFAULT_FORMAT = 'png'
SUPPORTED_FORMATS = ['png', 'pdf']

URL = ''
OUTPUTPATH = ''
PDFNAME = DEFAULT_PDFNAME
MAXDEGREE = DEFAULT_MAXDEGREE
START_FRAME = 0
END_FRAME = INFINITY
FORMAT = DEFAULT_FORMAT
ADD_TIMESTAMP = False
QUIET_MODE = False

@click.command()
@click.option('--similarity', default = DEFAULT_MAXDEGREE, help = 'The similarity between this frame and the previous frame is less than this value and this frame will be saveed, default: %02g' % (DEFAULT_MAXDEGREE))
@click.option('--format', type=click.Choice(SUPPORTED_FORMATS), default = DEFAULT_FORMAT, help = 'Output format: png (default, saves frames to folder) or pdf')
@click.option('--output', '-o', default = None, help = 'Output directory for PNG or output file path for PDF. Default: same directory as input video')
@click.option('--pdfname', default = None, help = 'the name of output pdf file (only used when format=pdf), default: video_name.pdf')
@click.option('--add-timestamp', is_flag=True, default=False, help = 'Add timestamp overlay on images (default: False)')
@click.option('--quiet', '-q', is_flag=True, default=False, help = 'Minimal output mode')
@click.option('--start_frame', default = ZERO_SISG, help = 'start frame time point, default = %02s' % (ZERO_SISG))
@click.option('--end_frame', default = INFINITY_SIGN, help = 'end frame time point, default = %02s' % (INFINITY_SIGN))
@click.argument('url')
def main(
    similarity, format, output, pdfname, add_timestamp, quiet, start_frame, end_frame, 
    url):
    global URL
    global OUTPUTPATH
    global MAXDEGREE
    global PDFNAME
    global START_FRAME
    global END_FRAME
    global FORMAT
    global ADD_TIMESTAMP
    global QUIET_MODE

    URL = url
    QUIET_MODE = quiet
    
    # Determine output path based on input video location
    video_dir = os.path.dirname(os.path.abspath(url))
    video_name = os.path.splitext(os.path.basename(url))[0]
    
    # Set output path - use provided path or default to video directory
    if output:
        OUTPUTPATH = output
    else:
        OUTPUTPATH = video_dir
    
    # Set PDF name - use provided name or default to video_name.pdf
    if pdfname:
        PDFNAME = pdfname
    else:
        PDFNAME = video_name + '.pdf'
    
    MAXDEGREE = similarity
    START_FRAME = hms2second(start_frame)
    END_FRAME = hms2second(end_frame)
    FORMAT = format
    ADD_TIMESTAMP = add_timestamp

    if START_FRAME >= END_FRAME:
        exitByPrint('start >= end can not work')

    prepare()
    start()
    export()
    clearEnv()

    

def start():
    global CV_CAP_PROP_FRAME_WIDTH
    global CV_CAP_PROP_FRAME_HEIGHT

    vcap = cv2.VideoCapture(URL)
    FPS = vcap.get(cv2.CAP_PROP_FPS)  # Keep as float for accuracy
    TOTAL_FRAME= int(vcap.get(cv2.CAP_PROP_FRAME_COUNT))

    if TOTAL_FRAME == 0:
        exitByPrint('Please check if the video url is correct')

    CV_CAP_PROP_FRAME_WIDTH = int(vcap.get(cv2.CAP_PROP_FRAME_WIDTH))
    CV_CAP_PROP_FRAME_HEIGHT = int(vcap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    if START_FRAME > TOTAL_FRAME / FPS:
        exitByPrint('video duration is not support')
    
    # set start frame
    vcap.set(cv2.CAP_PROP_POS_MSEC, START_FRAME * 1000)  # Use milliseconds for accuracy
    total_duration = TOTAL_FRAME / FPS if END_FRAME == INFINITY else END_FRAME
    frameCount = int((total_duration - START_FRAME) * FPS)

    lastDegree = 0
    lastFrame = []
    readedFrame = 0
    extracted_frames = 0
    
    # Print video information
    video_name = os.path.basename(URL)
    duration = frameCount / FPS
    
    if not QUIET_MODE:
        click.echo(f'\nProcessing: {video_name} ({CV_CAP_PROP_FRAME_WIDTH}x{CV_CAP_PROP_FRAME_HEIGHT}, {duration:.1f}s @ {FPS:.2f}fps)')
    
    # Create progress bar
    disable_progress = QUIET_MODE
    with tqdm(total=frameCount, 
              desc="Extracting", 
              unit="frame",
              bar_format='{desc}: {percentage:3.0f}%|{bar}| {n:.0f}/{total:.0f} [{elapsed}<{remaining}]',
              disable=disable_progress,
              mininterval=0.5,  # Update at most twice per second
              miniters=FPS) as pbar:  # Update only after processing FPS frames
        
        start_time = time.time()
        
        while(True):
            ret, frame = vcap.read()
            if ret:
                if readedFrame >= frameCount:
                    break

                readedFrame += 1
                pbar.update(1)
                
                if readedFrame % int(FPS) != 0:  # Process approximately once per second
                    continue

                isWrite = False

                if len(lastFrame):
                    degree = compareImg(frame, lastFrame)
                    if degree < MAXDEGREE:
                        isWrite = True
                        lastDegree = round(degree, 2)
                else:
                    isWrite = True

                if isWrite:
                    # Get actual timestamp from video
                    current_time_ms = vcap.get(cv2.CAP_PROP_POS_MSEC)
                    current_second = int(current_time_ms / 1000)  # Convert to seconds
                    timestamp_str = second2hms(current_second)
                    name = DEFAULT_PATH + '/frame'+ timestamp_str + '-' + str(lastDegree) + '.jpg'
                    
                    # Add timestamp overlay if requested
                    if ADD_TIMESTAMP:
                        frame_with_timestamp = frame.copy()
                        font = cv2.FONT_HERSHEY_SIMPLEX
                        text = 'Time: ' + timestamp_str.replace('.', ':')
                        font_scale = 2
                        thickness = 3
                        text_size = cv2.getTextSize(text, font, font_scale, thickness)[0]
                        text_x = 50
                        text_y = CV_CAP_PROP_FRAME_HEIGHT - 50
                        # Add background rectangle for better visibility
                        cv2.rectangle(frame_with_timestamp, 
                                    (text_x - 10, text_y - text_size[1] - 10),
                                    (text_x + text_size[0] + 10, text_y + 10),
                                    (0, 0, 0), -1)
                        cv2.putText(frame_with_timestamp, text, (text_x, text_y), 
                                  font, font_scale, (255, 255, 255), thickness)
                        if not cv2.imwrite(name, frame_with_timestamp):
                            exitByPrint('write file failed !')
                    else:
                        if not cv2.imwrite(name, frame):
                            exitByPrint('write file failed !')

                    lastFrame = frame
                    extracted_frames += 1
                    
            else:
                break
    
    # Print summary
    if not QUIET_MODE:
        click.echo(f'Extracted {extracted_frames} frames in {time.time() - start_time:.1f}s')
    else:
        click.echo(f'Extracted {extracted_frames} frames')

    vcap.release()
    cv2.destroyAllWindows()

def prepare():
    global OUTPUTPATH

    try:

        if not os.path.exists(OUTPUTPATH):
            os.makedirs(OUTPUTPATH)

    except OSError as error:
        exitByPrint(error)

    try:
        
        clearEnv()
        os.makedirs(DEFAULT_PATH)

    except OSError as error:
        exitByPrint(error)

def export():
    """Export frames based on the selected format"""
    if FORMAT == 'png':
        exportPng()
    elif FORMAT == 'pdf':
        exportPdf()
    else:
        exitByPrint(f'Unsupported format: {FORMAT}')

def exportPng():
    """Export frames as PNG files with readable timestamp filenames"""
    images = os.listdir(DEFAULT_PATH)
    images.sort()
    
    # Get video name for output directory
    video_name = os.path.splitext(os.path.basename(URL))[0]
    
    # Create output directory for PNG files
    png_output_dir = os.path.join(OUTPUTPATH, f'{video_name}_frames')
    if not os.path.exists(png_output_dir):
        os.makedirs(png_output_dir)
    
    exported_count = 0
    with tqdm(total=len(images), desc="Exporting", unit="file", disable=True) as pbar:  # Disable progress bar for export
        for image in images:
            if not image.endswith('.jpg'):
                pbar.update(1)
                continue
                
            source_path = os.path.join(DEFAULT_PATH, image)
            
            # Extract timestamp and similarity from filename
            # Format: frameHH.MM.SS-similarity.jpg
            parts = image.replace('frame', '').replace('.jpg', '').split('-')
            if len(parts) >= 1:
                timestamp = parts[0].replace('.', '-')  # Convert HH.MM.SS to HH-MM-SS
                similarity = parts[1] if len(parts) > 1 else '0'
                
                # Create readable filename: timestamp_HH-MM-SS_similarity_0.XX.png
                new_filename = f'timestamp_{timestamp}_similarity_{similarity}.png'
                dest_path = os.path.join(png_output_dir, new_filename)
                
                # Read and save as PNG
                img = cv2.imread(source_path)
                if img is not None:
                    cv2.imwrite(dest_path, img)
                    exported_count += 1
            
            pbar.update(1)
    
    if not QUIET_MODE:
        click.echo(f'Saved {exported_count} frames to: {png_output_dir}')
    else:
        click.echo(f'Saved to: {png_output_dir}')

def exportPdf():
    """Export frames as PDF document"""
    images = os.listdir(DEFAULT_PATH)
    images.sort()
    imagePaths = []

    for image in images:
        basepath = DEFAULT_PATH + '/' + image
        (fileName, mimeType) = os.path.splitext(basepath)
        
        if mimeType != '.jpg':
            continue

        imagePaths.append(basepath)
    
    pdfPath = DEFAULT_PATH + '/' + PDFNAME
    images2pdf(pdfPath, imagePaths, CV_CAP_PROP_FRAME_WIDTH, CV_CAP_PROP_FRAME_HEIGHT, ADD_TIMESTAMP)

    shutil.copy(pdfPath, OUTPUTPATH)
    
    # Get file size
    pdf_size = os.path.getsize(os.path.join(OUTPUTPATH, PDFNAME)) / (1024 * 1024)  # Convert to MB
    
    if not QUIET_MODE:
        click.echo(f'Created PDF ({pdf_size:.1f}MB, {len(imagePaths)} pages): {os.path.join(OUTPUTPATH, PDFNAME)}')
    else:
        click.echo(f'Saved to: {os.path.join(OUTPUTPATH, PDFNAME)}')

def exitByPrint(str):
    print(str)
    clearEnv()
    exit(1)

def clearEnv():
    if os.path.exists(DEFAULT_PATH):
        shutil.rmtree(DEFAULT_PATH)

def second2hms(second):
    m, s = divmod(second, 60)
    h, m = divmod(m, 60)
    return ("%02d.%02d.%02d" % (h, m, s))

def hms2second(hms):
    if hms == INFINITY_SIGN:
        return INFINITY

    h, m, s = hms.split(':')
    return int(h) * 3600 + int(m) * 60 + int(s)

if __name__ == '__main__':
    main()