//  Created by Erez Volk

import Foundation
import AppKit

@objc class ToggleCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        print("EREZ \(NSApplication.shared)")
        print("EREZ \(NSApplication.shared.delegate!)")
        //let delegate = NSApplication.shared.delegate as! TimerooAppDelegate
        //delegate.startPauseTimer()
        return nil
    }
}
