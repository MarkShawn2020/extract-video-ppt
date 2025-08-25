import Cocoa
import FinderSync

class ExtensionManager {
    static let shared = ExtensionManager()
    
    private init() {}
    
    /// Check if the Finder Extension is enabled
    func isExtensionEnabled() -> Bool {
        let bundleId = "com.video2ppt.Video2PPT.FinderExtension"
        return FIFinderSyncController.isExtensionEnabled(bundleId)
    }
    
    /// Open System Preferences to the Extensions pane
    func openExtensionPreferences() {
        FIFinderSyncController.showExtensionManagementInterface()
    }
    
    /// Get diagnostic information about the extension
    func getDiagnosticInfo() -> String {
        var info = "Extension Diagnostic Information\n"
        info += "================================\n\n"
        
        // Check extension bundle
        let bundleId = "com.video2ppt.Video2PPT.FinderExtension"
        info += "Extension Bundle ID: \(bundleId)\n"
        
        // Check if extension is enabled
        let enabled = isExtensionEnabled()
        info += "Extension Enabled: \(enabled ? "✅ Yes" : "❌ No")\n"
        
        // Check app signature
        if let appPath = Bundle.main.bundlePath as NSString? {
            let signatureCheck = checkCodeSignature(path: appPath as String)
            info += "App Signature: \(signatureCheck)\n"
        }
        
        // Check extension path
        if let extensionURL = Bundle.main.builtInPlugInsURL?.appendingPathComponent("Video2PPTExtension.appex") {
            let exists = FileManager.default.fileExists(atPath: extensionURL.path)
            info += "Extension Bundle: \(exists ? "✅ Found" : "❌ Not Found")\n"
            
            if exists {
                let signatureCheck = checkCodeSignature(path: extensionURL.path)
                info += "Extension Signature: \(signatureCheck)\n"
            }
        }
        
        // Check system version
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        info += "macOS Version: \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)\n"
        
        // Check monitored folders
        if enabled {
            info += "\nMonitored Folders:\n"
            // This would normally query the extension for its monitored folders
            info += "• Default: User's home directory\n"
        }
        
        return info
    }
    
    /// Check code signature of a bundle
    private func checkCodeSignature(path: String) -> String {
        let task = Process()
        task.launchPath = "/usr/bin/codesign"
        task.arguments = ["-dv", path]
        
        let pipe = Pipe()
        task.standardError = pipe
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if output.contains("adhoc") {
                return "⚠️ Ad-hoc signed (not trusted)"
            } else if output.contains("TeamIdentifier=") {
                return "✅ Developer signed"
            } else {
                return "❌ Not signed"
            }
        } catch {
            return "❌ Unable to check"
        }
    }
    
    /// Show first-time setup alert
    func showSetupInstructions() {
        let alert = NSAlert()
        alert.messageText = "Enable Video2PPT Extension"
        alert.informativeText = """
        To use the right-click video conversion feature, you need to enable the Video2PPT Extension:
        
        1. Click "Open System Settings" below
        2. In the Extensions settings, find "Finder Extensions"
        3. Check the box next to "Video2PPT Extension"
        4. You may need to allow the app in Privacy & Security settings
        
        Note: For unsigned apps, you may need to:
        • Right-click the app and select "Open" first
        • Go to System Settings > Privacy & Security
        • Click "Open Anyway" if prompted
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            openExtensionPreferences()
        }
    }
    
    /// Check and prompt for extension activation if needed
    func checkAndPromptForActivation() {
        if !isExtensionEnabled() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showSetupInstructions()
            }
        }
    }
}