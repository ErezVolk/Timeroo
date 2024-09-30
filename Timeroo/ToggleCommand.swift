//  Created by Erez Volk

import Foundation

@objc class ToggleCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        print("Called")
        return nil
    }
}
