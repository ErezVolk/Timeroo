//  Created by Erez Volk

import Foundation

/// Implement the `clear` AppleScript command
@objc class ClearCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooMenu.shared?.clearTimer()
        return nil
    }
}
