//  Created by Erez Volk

import SwiftUI

/// An empty app, since Timeroo only has a status menu
@main
struct TimerooApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: TimerooAppDelegate
    
    var body: some Scene {
        Settings { EmptyView() }
    }
}
