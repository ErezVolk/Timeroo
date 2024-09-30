//  Created by Erez Volk

import Foundation

@objc class ClearCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        TimerooAppDelegate.shared?.clearTimer()
        return nil
    }
}
