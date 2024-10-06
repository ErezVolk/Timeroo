//  Created by Erez Volk

import Foundation

/// Implement the `toggle` AppleScript command
@objc class ToggleCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        guard let shared = TimerooMenu.shared else { return nil }
        return shared.startPauseTimer() ? "STARTED" : "PAUSED"
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
@objc class StartCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        guard let shared = TimerooMenu.shared else { return nil }
        return shared.startTimer() ? "STARTED" : "NOP"
    }
}

/// Implement the `pause` AppleScript command
@objc class PauseCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        guard let shared = TimerooMenu.shared else { return nil }
        return shared.pauseTimer() ? "PAUSED" : "NOP"
    }
}
