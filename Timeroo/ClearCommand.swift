//  Created by Erez Volk

import Foundation

@objc class ClearCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        print("Clear Called")
        return nil
    }
}
