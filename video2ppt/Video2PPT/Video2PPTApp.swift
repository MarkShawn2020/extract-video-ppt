import SwiftUI

@main
struct Video2PPTApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var conversionManager = ConversionManager()
    
    var body: some Scene {
        WindowGroup("Video2PPT") {
            ContentView(initialFile: appDelegate.initialFilePath)
                .environmentObject(conversionManager)
                .frame(minWidth: 600, minHeight: 400)
                .onOpenURL { url in
                    // Handle URL scheme here to prevent new window creation
                    handleURLScheme(url)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))  // Handle all external events
        .commands {
            CommandGroup(replacing: .newItem) { }  // Remove File > New Window
        }
    }
    
    private func handleURLScheme(_ url: URL) {
        NSLog("Video2PPT: Handling URL in SwiftUI: \(url)")
        
        if url.scheme == "video2ppt" && url.host == "convert" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let fileItem = queryItems.first(where: { $0.name == "file" }),
               let filePath = fileItem.value?.removingPercentEncoding {
                
                NSLog("Video2PPT: Setting file path from URL: \(filePath)")
                
                // Update the AppDelegate's property
                appDelegate.initialFilePath = filePath
                
                // Send notification to ContentView
                NotificationCenter.default.post(
                    name: NSNotification.Name("LoadVideoFile"),
                    object: nil,
                    userInfo: ["filePath": filePath]
                )
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var initialFilePath: String? = nil
    
    override init() {
        super.init()
        
        // Parse command line arguments immediately in init
        let arguments = ProcessInfo.processInfo.arguments
        NSLog("Video2PPT: AppDelegate init with arguments: \(arguments)")
        
        if arguments.count > 2 && arguments[1] == "--file" {
            self.initialFilePath = arguments[2]
            NSLog("Video2PPT: Found file path in init: \(initialFilePath ?? "none")")
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("Video2PPT: Application did finish launching, file path: \(initialFilePath ?? "none")")
        
        // Prevent multiple instances
        if let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: "com.video2ppt.Video2PPT").first(where: { $0 != NSRunningApplication.current }) {
            NSLog("Video2PPT: Another instance is already running, activating it")
            runningApp.activate(options: .activateIgnoringOtherApps)
            NSApp.terminate(nil)
            return
        }
        
        registerExtension()
        setupDistributedNotifications()
        
        // Check and prompt for extension activation
        ExtensionManager.shared.checkAndPromptForActivation()
    }
    
    // URL scheme handling is now done in SwiftUI's onOpenURL
    // This method is kept for compatibility but simplified
    func application(_ application: NSApplication, open urls: [URL]) {
        NSLog("Video2PPT: AppDelegate received URLs (handled by SwiftUI): \(urls.count)")
        // SwiftUI's onOpenURL will handle the actual processing
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Terminate app when window is closed
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // If there's already a window, just bring it to front
        if !flag {
            if let window = NSApplication.shared.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
        return true
    }
    
    private func registerExtension() {
        // Removed: Main app should not manage extension settings
        // Extension registration is handled by the system
    }
    
    private func setupDistributedNotifications() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleConversionRequest(_:)),
            name: NSNotification.Name("com.video2ppt.convert"),
            object: nil
        )
    }
    
    @objc private func handleConversionRequest(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let filePath = userInfo["filePath"] as? String else { 
            NSLog("Video2PPT: No file path in distributed notification")
            return 
        }
        
        NSLog("Video2PPT: Received file path from distributed notification: \(filePath)")
        
        DispatchQueue.main.async { [weak self] in
            // Update the @Published property
            self?.initialFilePath = filePath
            
            if let window = NSApplication.shared.windows.first {
                window.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            
            // Also send local notification for ContentView
            NotificationCenter.default.post(
                name: NSNotification.Name("LoadVideoFile"),
                object: nil,
                userInfo: ["filePath": filePath]
            )
        }
    }
}