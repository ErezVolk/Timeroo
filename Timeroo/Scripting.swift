//  Created by Erez Volk

import Foundation

/// Implement the `toggle` AppleScript command
@MainActor
@objc class ToggleCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooMenu.shared?.startPauseTimer()
        return nil
    }
}

/// Implement the `clear` AppleScript command
@objc class ClearCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooMenu.shared?.clearTimer()
        return nil
    }
}

/// Implement the `adjust` AppleScript command
@objc class AdjustCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        let newTime = self.evaluatedArguments!["NewTime"] as? String ?? "N/A"
        return TimerooMenu.shared?.setTimerFromString(newTime)
    }
}

/// Implement the `start` AppleScript command
@MainActor
@objc class StartCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooMenu.shared?.startTimer()
        return nil
    }
}

/// Implement the `pause` AppleScript command
@MainActor
@objc class PauseCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooMenu.shared?.pauseTimer()
        return nil
    }
}
