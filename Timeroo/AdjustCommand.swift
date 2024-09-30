//  Created by Erez Volk

import Foundation

@objc class AdjustCommand: NSScriptCommand {
    @objc override func performDefaultImplementation() -> Any? {
        let newTime = self.evaluatedArguments!["NewTime"] as! String
        print("Change called with \(newTime)")
        return newTime
    }
}
