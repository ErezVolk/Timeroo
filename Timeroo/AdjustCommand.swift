//  Created by Erez Volk

import Foundation

/// Implement the `adjust` AppleScript command
@objc class AdjustCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        let newTime = self.evaluatedArguments!["NewTime"] as! String
        return TimerooAppDelegate.shared?.setTimerFromString(newTime)
    }
}
