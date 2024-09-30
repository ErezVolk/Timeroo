//  Created by Erez Volk

import Foundation

@objc class ToggleCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        print("Toggle Called")
        return nil
    }
}
