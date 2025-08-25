import Foundation
import Combine
import AppKit

@MainActor
class ConversionManager: ObservableObject {
    @Published var isConverting = false
    @Published var progress: Double = 0.0
    @Published var statusMessage = ""
    
    private var process: Process?
    private var outputPipe: Pipe?
    
    func convert(
        inputFile: URL,
        format: String,
        similarity: Double,
        pdfName: String,
        addTimestamp: Bool,
        progressHandler: @escaping (Double, String) -> Void
    ) async -> URL? {
        await MainActor.run {
            self.isConverting = true
            self.progress = 0.0
            self.statusMessage = "Preparing conversion..."
        }
        
        let outputDir = inputFile.deletingLastPathComponent()
            .appendingPathComponent("video2ppt_output")
        
        NSLog("Video2PPT: Creating output directory at: \(outputDir.path)")
        
        do {
            try FileManager.default.createDirectory(
                at: outputDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            NSLog("Video2PPT: Output directory created successfully")
        } catch {
            NSLog("Video2PPT: Failed to create output directory: \(error)")
            await MainActor.run {
                self.statusMessage = "Failed to create output directory: \(error.localizedDescription)"
                self.isConverting = false
            }
            return nil
        }
        
        await withCheckedContinuation { continuation in
            Task.detached {
                await self.runPythonScript(
                    inputFile: inputFile,
                    outputDir: outputDir,
                    format: format,
                    similarity: similarity,
                    pdfName: pdfName,
                    addTimestamp: addTimestamp,
                    progressHandler: progressHandler
                ) {
                    continuation.resume()
                }
            }
        }
        
        await MainActor.run {
            self.isConverting = false
            self.progress = 1.0
            self.statusMessage = "Conversion completed!"
        }
        
        NSLog("Video2PPT: Conversion completed. Returning output directory: \(outputDir.path)")
        NSLog("Video2PPT: NOT opening Finder automatically")
        
        return outputDir
    }
    
    nonisolated private func runPythonScript(
        inputFile: URL,
        outputDir: URL,
        format: String,
        similarity: Double,
        pdfName: String,
        addTimestamp: Bool,
        progressHandler: @escaping (Double, String) -> Void,
        completion: @escaping () -> Void
    ) async {
        let process = Process()
        let outputPipe = Pipe()
        
        await MainActor.run {
            self.process = process
            self.outputPipe = outputPipe
        }
        
        let pythonPath = findPythonPath()
        
        NSLog("Video2PPT: Python path: \(pythonPath)")
        NSLog("Video2PPT: Input file: \(inputFile.path)")
        NSLog("Video2PPT: Output dir: \(outputDir.path)")
        
        process.executableURL = URL(fileURLWithPath: pythonPath)
        
        // Set PYTHONPATH to include the video2ppt module directory
        var environment = ProcessInfo.processInfo.environment
        environment["PYTHONPATH"] = "/Users/mark/projects/video2ppt"
        environment["PYTHONDONTWRITEBYTECODE"] = "1"  // Prevent __pycache__ creation
        process.environment = environment
        
        // Set current directory to output directory so temp files are created there
        process.currentDirectoryURL = outputDir
        
        NSLog("Video2PPT: PYTHONPATH set to: \(environment["PYTHONPATH"] ?? "nil")")
        NSLog("Video2PPT: Working directory set to: \(outputDir.path)")
        
        // Use python -m video2ppt to run as module
        var arguments = [
            "-m", "video2ppt",
            "--format", format,
            "--similarity", String(similarity)
        ]
        
        // video2ppt will create output in the specified directory
        // For PNG: creates a subfolder with videoname_frames
        // For PDF: creates the PDF file directly
        arguments.append(contentsOf: ["--output", outputDir.path])
        
        if format == "pdf" {
            arguments.append(contentsOf: ["--pdfname", pdfName])
            if addTimestamp {
                arguments.append("--add-timestamp")
            }
        }
        
        // Input file must be the last argument
        arguments.append(inputFile.path)
        
        NSLog("Video2PPT: Full command: \(pythonPath) \(arguments.joined(separator: " "))")
        
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        // Create a log file for debugging
        let logPath = outputDir.appendingPathComponent("conversion_log.txt")
        FileManager.default.createFile(atPath: logPath.path, contents: nil, attributes: nil)
        let logHandle = FileHandle(forWritingAtPath: logPath.path)
        
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                // Write to log file
                logHandle?.write(data)
                
                if let output = String(data: data, encoding: .utf8) {
                    NSLog("Video2PPT Output: \(output)")
                    DispatchQueue.main.async {
                        let lines = output.components(separatedBy: .newlines)
                        for line in lines where !line.isEmpty {
                            if line.contains("Processing") {
                                progressHandler(0.3, line)
                            } else if line.contains("Extracting") {
                                progressHandler(0.1, "Extracting frames...")
                            } else if line.contains("Extracted") {
                                progressHandler(0.5, line)
                            } else if line.contains("Saved") {
                                progressHandler(0.9, line)
                            } else if line.contains("Error") || line.contains("error") {
                                progressHandler(0, "Error: \(line)")
                            }
                        }
                    }
                }
            }
        }
        
        process.terminationHandler = { process in
            let exitCode = process.terminationStatus
            NSLog("Video2PPT: Process terminated with exit code: \(exitCode)")
            
            // Close log file
            logHandle?.closeFile()
            
            if exitCode != 0 {
                DispatchQueue.main.async {
                    progressHandler(0, "Conversion failed with exit code: \(exitCode)")
                }
            }
            
            outputPipe.fileHandleForReading.readabilityHandler = nil
            completion()
        }
        
        do {
            try process.run()
            NSLog("Video2PPT: Process started successfully")
        } catch {
            NSLog("Video2PPT: Failed to start process: \(error)")
            progressHandler(0, "Failed to start conversion: \(error.localizedDescription)")
            completion()
        }
    }
    
    nonisolated private func findPythonPath() -> String {
        let paths = [
            "/opt/homebrew/anaconda3/bin/python3",  // Anaconda Python
            "/usr/local/bin/python3",
            "/opt/homebrew/bin/python3",
            "/usr/bin/python3",
            "/usr/bin/python"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                NSLog("Video2PPT: Found Python at: \(path)")
                return path
            }
        }
        
        NSLog("Video2PPT: WARNING - No Python found, using default")
        return "/usr/bin/python3"
    }
    
    nonisolated private func findScriptPath() -> String {
        // First, try to find the script in the app bundle
        let bundlePath = Bundle.main.bundlePath + "/Contents/Resources/video2ppt/video2ppt.py"
        if FileManager.default.fileExists(atPath: bundlePath) {
            NSLog("Video2PPT: Using bundled script at: \(bundlePath)")
            return bundlePath
        }
        
        // For development, check the project directory
        let projectPath = "/Users/mark/projects/video2ppt/video2ppt/video2ppt.py"
        if FileManager.default.fileExists(atPath: projectPath) {
            NSLog("Video2PPT: Using development script at: \(projectPath)")
            return projectPath
        }
        
        // Try to find installed video2ppt command
        let installedPaths = [
            "/opt/homebrew/anaconda3/bin/video2ppt",
            "/usr/local/bin/video2ppt",
            "/opt/homebrew/bin/video2ppt",
            NSHomeDirectory() + "/.local/bin/video2ppt"
        ]
        
        for path in installedPaths {
            if FileManager.default.fileExists(atPath: path) {
                NSLog("Video2PPT: Using installed script at: \(path)")
                return path
            }
        }
        
        NSLog("Video2PPT: WARNING - No script found, using fallback")
        return "video2ppt"
    }
    
    func openOutputFolder(_ url: URL) {
        NSLog("Video2PPT: User clicked 'Open in Finder' button for path: \(url.path)")
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        NSLog("Video2PPT: Finder should now be opened showing the output folder")
    }
    
    func cancelConversion() {
        process?.terminate()
        process = nil
        outputPipe = nil
        isConverting = false
        statusMessage = "Conversion cancelled"
    }
}