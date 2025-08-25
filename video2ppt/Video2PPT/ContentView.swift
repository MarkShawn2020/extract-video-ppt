import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var conversionManager: ConversionManager
    @State private var selectedFile: URL?
    @State private var outputFormat: ExportFormat = .png
    @State private var similarity: Double = 0.6
    @State private var addTimestamp: Bool = false
    @State private var pdfName: String = "output.pdf"
    @State private var isConverting: Bool = false
    @State private var conversionProgress: Double = 0.0
    @State private var statusMessage: String = ""
    
    let initialFile: String?
    
    init(initialFile: String? = nil) {
        self.initialFile = initialFile
    }
    
    enum ExportFormat: String, CaseIterable {
        case png = "PNG"
        case pdf = "PDF"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            fileSelectionSection
            if selectedFile != nil {
                settingsSection
                actionButtons
            }
            if !statusMessage.isEmpty {
                statusSection
            }
        }
        .padding(30)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            // Set initial file if provided
            if let filePath = initialFile {
                NSLog("ContentView: Setting initial file from onAppear: \(filePath)")
                selectedFile = URL(fileURLWithPath: filePath)
            } else {
                NSLog("ContentView: No initial file in onAppear")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LoadVideoFile"))) { notification in
            if let filePath = notification.userInfo?["filePath"] as? String {
                NSLog("ContentView: Received file path from notification: \(filePath)")
                selectedFile = URL(fileURLWithPath: filePath)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "video.square.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("Video to PPT Converter")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Extract key frames from video")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var fileSelectionSection: some View {
        VStack(spacing: 12) {
            if let file = selectedFile {
                HStack {
                    Image(systemName: "doc.on.doc.fill")
                        .foregroundColor(.accentColor)
                    Text(file.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button(action: { selectedFile = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            } else {
                Button(action: selectFile) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                        Text("Select Video File")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conversion Settings")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Output Format:")
                        .frame(width: 120, alignment: .leading)
                    Picker("", selection: $outputFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }
                
                HStack {
                    Text("Similarity:")
                        .frame(width: 120, alignment: .leading)
                    Slider(value: $similarity, in: 0.1...1.0, step: 0.05)
                    Text(String(format: "%.2f", similarity))
                        .frame(width: 40)
                        .font(.system(.body, design: .monospaced))
                }
                
                if outputFormat == .pdf {
                    HStack {
                        Text("PDF Name:")
                            .frame(width: 120, alignment: .leading)
                        TextField("output.pdf", text: $pdfName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Toggle("Add Timestamps", isOn: $addTimestamp)
                        .padding(.leading, 120)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                NSApp.terminate(nil)
            }) {
                Label("Cancel", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            
            Button(action: startConversion) {
                if isConverting {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.7)
                        Text("Converting...")
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Label("Convert", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
            }
            .controlSize(.large)
            .keyboardShortcut(.return)
            .disabled(isConverting)
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isConverting {
                ProgressView(value: conversionProgress)
                    .progressViewStyle(.linear)
            }
            
            Text(statusMessage)
                .font(.caption)
                .foregroundColor(isConverting ? .secondary : .green)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.title = "Select Video File"
        panel.allowedContentTypes = [
            UTType(filenameExtension: "mp4")!,
            UTType(filenameExtension: "mov")!,
            UTType(filenameExtension: "avi")!,
            UTType(filenameExtension: "mkv")!,
            UTType(filenameExtension: "webm")!
        ]
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            selectedFile = panel.url
        }
    }
    
    private func startConversion() {
        guard let inputFile = selectedFile else { return }
        
        isConverting = true
        statusMessage = "Starting conversion..."
        conversionProgress = 0.0
        
        Task {
            await conversionManager.convert(
                inputFile: inputFile,
                format: outputFormat.rawValue.lowercased(),
                similarity: similarity,
                pdfName: pdfName,
                addTimestamp: addTimestamp
            ) { progress, message in
                DispatchQueue.main.async {
                    self.conversionProgress = progress
                    self.statusMessage = message
                }
            }
            
            DispatchQueue.main.async {
                self.isConverting = false
                self.statusMessage = "Conversion completed successfully!"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    NSApp.terminate(nil)
                }
            }
        }
    }
}