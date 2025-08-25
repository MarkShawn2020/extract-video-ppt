#!/usr/bin/osascript

-- AppleScript to set up right-click functionality for Video2PPT
-- This creates a Service that appears in the context menu

on run
    set serviceName to "Convert to PPT"
    set serviceFolder to (POSIX path of (path to home folder)) & "Library/Services/"
    set workflowPath to serviceFolder & serviceName & ".workflow"
    
    -- Check if Video2PPT app exists
    try
        set appPath to POSIX path of (path to application "Video2PPT")
    on error
        display dialog "Video2PPT app not found in Applications folder. Please install it first." buttons {"OK"} default button 1
        return
    end try
    
    -- Create the service using shell script
    do shell script "bash " & quoted form of ((POSIX path of (path to me)) & "/../install-quick-action.sh")
    
    -- Notify user
    display notification "Right-click menu for Video2PPT has been set up successfully!" with title "Video2PPT" subtitle "Setup Complete"
    
    -- Offer to demonstrate
    set userChoice to display dialog "Right-click menu has been installed!" & return & return & "To use it:" & return & "1. Right-click any video file" & return & "2. Select 'Quick Actions' → 'Convert to PPT'" & return & return & "Would you like to open a Finder window to try it?" buttons {"Not Now", "Open Finder"} default button 2
    
    if button returned of userChoice is "Open Finder" then
        tell application "Finder"
            activate
            open (path to movies folder)
        end tell
    end if
end run