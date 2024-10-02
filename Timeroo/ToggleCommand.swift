//  Created by Erez Volk

import Foundation

/// Implement the `toggle` AppleScript command
@MainActor
@objc class ToggleCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooAppDelegate.shared?.startPauseTimer()
        return nil
    }
}
