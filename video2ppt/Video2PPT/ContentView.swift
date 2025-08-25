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
    @State private var outputDirectory: URL? = nil
    @State private var conversionCompleted: Bool = false
    @State private var showingSettings: Bool = false
    @State private var bounceAnimation: Bool = false
    
    let initialFile: String?
    
    init(initialFile: String? = nil) {
        self.initialFile = initialFile
    }
    
    enum ExportFormat: String, CaseIterable {
        case png = "PNG"
        case pdf = "PDF"
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.90, green: 0.92, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerSection
                
                if selectedFile != nil {
                    fileCard
                }
                
                if selectedFile != nil && !conversionCompleted {
                    settingsCard
                    actionButtons
                } else if selectedFile == nil {
                    dropZone
                }
                
                if isConverting || !statusMessage.isEmpty {
                    statusCard
                }
                
                if outputDirectory != nil, conversionCompleted {
                    resultCard
                }
                
                Spacer()
            }
            .padding(30)
        }
        .frame(minWidth: 650, minHeight: 600)
        .onAppear {
            if let filePath = initialFile {
                selectedFile = URL(fileURLWithPath: filePath)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LoadVideoFile"))) { notification in
            if let filePath = notification.userInfo?["filePath"] as? String {
                selectedFile = URL(fileURLWithPath: filePath)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Extension status indicator
            HStack {
                Spacer()
                Button(action: {
                    ExtensionManager.shared.openExtensionPreferences()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: ExtensionManager.shared.isExtensionEnabled() ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(ExtensionManager.shared.isExtensionEnabled() ? .green : .orange)
                        Text(ExtensionManager.shared.isExtensionEnabled() ? "Extension Active" : "Extension Disabled")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    )
                }
                .buttonStyle(.plain)
                .help(ExtensionManager.shared.isExtensionEnabled() ? 
                      "Right-click context menu is enabled" : 
                      "Click to enable right-click context menu")
            }
            .padding(.horizontal)
            
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "video.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .scaleEffect(bounceAnimation ? 1.1 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.5), value: bounceAnimation)
            
            Text("Video to PPT Converter")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            
            Text("Extract key frames from video")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - File Card
    private var fileCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedFile?.lastPathComponent ?? "")
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                if let fileSize = getFileSize() {
                    Text(fileSize)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
            }
            
            Spacer()
            
            if !conversionCompleted {
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedFile = nil
                        showingSettings = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.75))
                        .background(Circle().fill(Color.white))
                }
                .buttonStyle(.plain)
                .help("Remove file")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Drop Zone
    private var dropZone: some View {
        Button(action: selectFile) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                
                Text("Select Video File")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                Text("MP4, MOV, AVI, MKV, WEBM")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8, 8])
                            )
                            .foregroundColor(Color.blue.opacity(0.3))
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(bounceAnimation ? 1.02 : 1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                bounceAnimation = hovering
            }
        }
    }
    
    // MARK: - Settings Card
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                Text("Conversion Settings")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            }
            
            VStack(spacing: 16) {
                // Output Format
                HStack {
                    Label("Format", systemImage: "doc.badge.arrow.up")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                        .frame(width: 110, alignment: .leading)
                    
                    Picker("", selection: $outputFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
                
                // Similarity Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Similarity", systemImage: "slider.horizontal.below.rectangle")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", similarity * 100))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    
                    Slider(value: $similarity, in: 0.1...1.0, step: 0.05)
                        .accentColor(.blue)
                }
                
                // PDF Options
                if outputFormat == .pdf {
                    VStack(spacing: 12) {
                        HStack {
                            Label("PDF Name", systemImage: "doc.text")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                                .frame(width: 110, alignment: .leading)
                            
                            TextField("output.pdf", text: $pdfName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack {
                            Toggle("Add Timestamps", isOn: $addTimestamp)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .font(.system(size: 14))
                            Spacer()
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                NSApp.terminate(nil)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                    Text("Exit")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.96))
                )
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            }
            .buttonStyle(.plain)
            
            Button(action: startConversion) {
                HStack(spacing: 8) {
                    if isConverting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                            .frame(width: 16, height: 16)
                        Text("Converting...")
                    } else {
                        Image(systemName: "play.circle.fill")
                        Text("Convert")
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isConverting ? Color.gray : Color.blue,
                                    isConverting ? Color.gray.opacity(0.8) : Color.blue.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .foregroundColor(.white)
                .shadow(color: isConverting ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3), 
                       radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .disabled(isConverting)
            .keyboardShortcut(.return)
        }
    }
    
    // MARK: - Status Card
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isConverting {
                ProgressView(value: conversionProgress)
                    .progressViewStyle(.linear)
                    .accentColor(.blue)
            }
            
            HStack(spacing: 8) {
                if isConverting {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                } else if conversionCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
                
                Text(statusMessage)
                    .font(.system(size: 14))
                    .foregroundColor(
                        isConverting ? Color(red: 0.4, green: 0.4, blue: 0.5) :
                        conversionCompleted ? .green : Color(red: 0.4, green: 0.4, blue: 0.5)
                    )
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    conversionCompleted ? Color.green.opacity(0.05) : Color.blue.opacity(0.05)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            conversionCompleted ? Color.green.opacity(0.2) : Color.blue.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Result Card
    private var resultCard: some View {
        VStack(spacing: 16) {
            // Output Path
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Output saved to:")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    
                    Text(outputDirectory?.path ?? "")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                        .lineLimit(2)
                        .truncationMode(.middle)
                        .help(outputDirectory?.path ?? "")
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.98, green: 0.98, blue: 0.99))
            )
            
            // Action Buttons
            HStack(spacing: 12) {
                // Open in Finder
                Button(action: {
                    if let outputDir = outputDirectory {
                        conversionManager.openOutputFolder(outputDir)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "folder.badge.gearshape")
                        Text("Open in Finder")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.blue, lineWidth: 1.5)
                            )
                    )
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                // Re-convert (New Feature)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        conversionCompleted = false
                        outputDirectory = nil
                        statusMessage = ""
                        // Keep the same file selected
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Re-convert")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .help("Convert the same file with different settings")
                
                // Convert Another
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedFile = nil
                        outputDirectory = nil
                        conversionCompleted = false
                        statusMessage = ""
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.square")
                        Text("New File")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 2)
        )
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        ))
    }
    
    // MARK: - Helper Functions
    private func getFileSize() -> String? {
        guard let file = selectedFile else { return nil }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
            if let fileSize = attributes[.size] as? Int64 {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                return formatter.string(fromByteCount: fileSize)
            }
        } catch {
            return nil
        }
        return nil
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
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedFile = panel.url
                conversionCompleted = false
                outputDirectory = nil
                statusMessage = ""
            }
        }
    }
    
    private func startConversion() {
        guard let inputFile = selectedFile else { return }
        
        isConverting = true
        statusMessage = "Starting conversion..."
        conversionProgress = 0.0
        
        Task {
            let outputDir = await conversionManager.convert(
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
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isConverting = false
                    self.outputDirectory = outputDir
                    self.conversionCompleted = outputDir != nil
                    self.statusMessage = outputDir != nil ? "Conversion completed successfully!" : "Conversion failed."
                }
            }
        }
    }
}