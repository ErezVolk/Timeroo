//  Created by Erez Volk

import AppKit

/// Allow a menu popover text field to get focus
class PopoverWindow: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return false
    }
}
