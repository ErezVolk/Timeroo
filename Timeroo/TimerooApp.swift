//  Created by Erez Volk

import SwiftUI

@main
struct TimerooApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: TimerooAppDelegate
    
    var body: some Scene {
        Settings { EmptyView() }
    }
}
