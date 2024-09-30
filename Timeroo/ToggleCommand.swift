//  Created by Erez Volk

import Foundation

@MainActor
@objc class ToggleCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooAppDelegate.shared?.startPauseTimer()
        return nil
    }
}
