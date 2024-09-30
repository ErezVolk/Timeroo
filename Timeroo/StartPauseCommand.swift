//  Created by Erez Volk

import Foundation

@objc class StartPauseCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        print("Called")
        return nil
    }
}
