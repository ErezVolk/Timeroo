//  Created by Erez Volk

import AppKit

/// Allow a menu popover text field to get focus (so we can have the Set input field)
class PopoverWindow: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return false
    }
}
