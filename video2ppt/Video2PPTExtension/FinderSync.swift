import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        
        NSLog("Video2PPT FinderSync extension started")
        
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForItems else { return nil }
        
        let menu = NSMenu(title: "")
        let menuItem = NSMenuItem(
            title: "Convert to PPT",
            action: #selector(convertToPPT(_:)),
            keyEquivalent: ""
        )
        menuItem.image = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: nil)
        menu.addItem(menuItem)
        
        return menu
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            return false
        }
        
        if items.count != 1 {
            return false
        }
        
        guard let url = items.first else {
            return false
        }
        
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "webm", "m4v", "flv", "wmv", "mpg", "mpeg"]
        let fileExtension = url.pathExtension.lowercased()
        
        return videoExtensions.contains(fileExtension)
    }
    
    @objc func convertToPPT(_ sender: AnyObject?) {
        NSLog("Video2PPT Extension: convertToPPT called")
        
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("Video2PPT Extension: No selected items")
            return
        }
        
        NSLog("Video2PPT Extension: Selected items count: \(items.count)")
        
        guard let fileURL = items.first else {
            NSLog("Video2PPT Extension: Could not get first item")
            return
        }
        
        NSLog("Video2PPT Extension: Converting file: \(fileURL.path)")
        NSLog("Video2PPT Extension: File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")
        
        launchMainApp(with: fileURL)
    }
    
    private func launchMainApp(with fileURL: URL) {
        NSLog("Video2PPT Extension: launchMainApp called with: \(fileURL.path)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            // First, terminate any existing instances
            let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.video2ppt.Video2PPT")
            for app in runningApps {
                NSLog("Video2PPT Extension: Terminating existing instance")
                app.terminate()
            }
            
            // Small delay to ensure termination completes
            Thread.sleep(forTimeInterval: 0.2)
            
            // Encode the file path for use in URL
            guard let encodedPath = fileURL.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                NSLog("Video2PPT Extension: Failed to encode file path")
                self.showErrorAlert()
                return
            }
            
            // Create URL scheme URL
            let urlString = "video2ppt://convert?file=\(encodedPath)"
            guard let schemeURL = URL(string: urlString) else {
                NSLog("Video2PPT Extension: Failed to create URL scheme URL")
                self.showErrorAlert()
                return
            }
            
            NSLog("Video2PPT Extension: Opening URL scheme: \(schemeURL)")
            
            // Open the URL, which will launch the app and pass the file path
            DispatchQueue.main.async {
                let success = NSWorkspace.shared.open(schemeURL)
                if success {
                    NSLog("Video2PPT Extension: Successfully opened URL scheme")
                } else {
                    NSLog("Video2PPT Extension: Failed to open URL scheme")
                    self.showErrorAlert()
                }
            }
        }
    }
    
    private func showErrorAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Video2PPT Error"
            alert.informativeText = "Could not launch Video2PPT converter. Please ensure the application is installed correctly."
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

extension FinderSync {
    override func beginObservingDirectory(at url: URL) {
    }
    
    override func endObservingDirectory(at url: URL) {
    }
    
    override func requestBadgeIdentifier(for url: URL) {
    }
}