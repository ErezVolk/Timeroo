//  Created by Erez Volk

import Cocoa
import UserNotifications

class TimerooMenu: NSObject, NSApplicationDelegate, NSTextFieldDelegate, NSMenuDelegate {
    /// Allow the AppleScript command objects to access the running app (hack, but I couldn't find a better way)
    static var shared: TimerooMenu?
    var statusItem: NSStatusItem!
    var timer: Timer?
    var totalTime: TimeInterval = 0
    var isPaused: Bool = true
    var setPopover: NSPopover!
    var startPauseCommand: NSMenuItem!
    var clearCommand: NSMenuItem!
    let idleImage = NSImage(systemSymbolName: "stopwatch.fill", accessibilityDescription: "timer")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        TimerooMenu.shared = self
        hideFromDock()
        createStatusItem()
        createSetPopover()
        createMenu()
        updateStatusBarTitle()
        requestNotificationPermissions()
    }

    /// Stop the timer if active
    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
    }

    func hideFromDock() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }

    func createSetPopover() {
        let box = NSSize(width: 160, height: 24)
        let margin = NSSize(width: 16, height: 12)
        let contentViewController = NSViewController()
        contentViewController.view = NSView(frame: NSRect(
            x: 0,
            y: 0,
            width: margin.width * 2 + box.width,
            height: margin.height * 2 + box.height))

        let textField = NSTextField(frame: NSRect(
            x: margin.width, y: margin.height, width: box.width, height: box.height))
        textField.placeholderString = "Enter time ([h:]mm:ss)"
        textField.delegate = self
        contentViewController.view.addSubview(textField)

        setPopover = createPopover(contentViewController)
    }

    func createPopover(_ contentViewController: NSViewController) -> NSPopover {
        let popover = NSPopover()
        popover.contentViewController = contentViewController
        popover.behavior = .transient // Automatically closes when focus is lost
        return popover
    }

    func createMenu() {
        let menu = NSMenu()
        menu.delegate = self
        startPauseCommand = makeItem(title: "Start",
                                     action: #selector(startPauseTimer),
                                     sfName: "playpause.circle")
        clearCommand = makeItem(title: "Clear",
                                action: #selector(clearTimer),
                                sfName: "restart.circle")
        menu.addItem(startPauseCommand)
        menu.addItem(clearCommand)
        menu.addItem(makeItem(title: "Set...",
                              action: #selector(showSetPopover),
                              sfName: "exclamationmark.arrow.circlepath"))

        menu.addItem(NSMenuItem.separator())
        menu.addItem(makeItem(title: "Quit", action: #selector(quitApplication), sfName: "eject.circle"))
        menu.autoenablesItems = false
        statusItem.menu = menu
    }

    /// Create an item for the status menu (wraps `NSMenuItem` constructor)
    /// - parameter sfName: Optional system image name for the menu entry.
    func makeItem(title: String,
                  action: Selector,
                  keyEquivalent: String = "",
                  sfName: String? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        if let sfName {
            item.image = NSImage(systemSymbolName: sfName, accessibilityDescription: sfName)
        }
        return item
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, error in
            if let error = error {
                print("Failed to request notification permission: \(error)")
            }
        }
    }
    
    /// Return `true` iff timer was started (i.e., not already running)
    @objc func startTimer() -> Bool {
        if !isPaused { return false }

        // Start the timer
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
        isPaused = false
        updateStatusBarTitle()

        if totalTime == 0 {
            sendNotification("Starting")
        } else {
            sendNotification("Resuming at \(getTimeString())")
        }
        return true
    }
    
    /// Return `true` iff timer was paused (i.e., not already paused)
    @objc func pauseTimer() -> Bool {
        if isPaused { return false }

        timer?.invalidate()
        timer = nil
        isPaused = true
        updateStatusBarTitle()
        sendNotification("Pausing at \(getTimeString())")
        return false
    }

    /// Return whether the timer is running after starting/pausing.
    @objc func startPauseTimer() -> Bool {
        if isPaused {
            _ = startTimer()
        } else {
            _ = pauseTimer()
        }
        return !isPaused
    }

    /// Called every second by the timer
    @objc func updateTimer() {
        totalTime += 1
        updateStatusBarTitle()
    }

    @objc func clearTimer() {
        timer?.invalidate()
        timer = nil
        totalTime = 0
        isPaused = true
        updateStatusBarTitle()
    }

    @objc func quitApplication() {
        NSApplication.shared.terminate(self)
    }

    func updateStatusBarTitle() {
        if totalTime == 0 && isPaused {
            statusItem.button?.image = idleImage
            statusItem.button?.title = ""
            statusItem.button?.appearsDisabled = false
        } else {
            statusItem.button?.image = nil
            statusItem.button?.title = getTimeString()
            statusItem.button?.appearsDisabled = isPaused
        }
        startPauseCommand.title = isPaused ? "Start" : "Pause"
        clearCommand.isEnabled = totalTime > 0
    }

    func getTimeString() -> String {
        var total = Int(totalTime)
        let seconds = total % 60
        total /= 60
        let minutes = total % 60
        let hours = total / 60
        let title = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        return title
    }

    func sendNotification(_ body: String) {
        let content = UNMutableNotificationContent()
        content.body = body

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to deliver notification: \(error)")
            }
        }
    }

    /// Gets called when the user presses Enter in the popover
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            setTimerFromPopover()
            return true
        }
        return false
    }

    func getPopoverTextField() -> NSTextField? {
        return setPopover.contentViewController?.view.subviews.first(where: { $0 is NSTextField }) as? NSTextField
    }

    @objc func showSetPopover() {
        if let button = statusItem.button {
            setPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            if let textField = getPopoverTextField() {
                textField.becomeFirstResponder() // Make the text field active
            }
        }
    }

    @objc func setTimerFromPopover() {
        if let total = parsePopover() {
            totalTime = total
            updateStatusBarTitle()
        }
        setPopover.performClose(nil) // Close the popover after setting the timer
    }

    func parsePopover() -> TimeInterval? {
        guard let textField = getPopoverTextField() else { return nil }
        let timeString = textField.stringValue
        textField.stringValue = ""  // For next time
        return parseTimeString(timeString)
    }

    func setTimerFromString(_ timeString: String) -> String {
        if let total = parseTimeString(timeString) {
            totalTime = total
            updateStatusBarTitle()
        }
        return getTimeString()
    }

    func parseTimeString(_ timeString: String) -> TimeInterval? {
        let parts = timeString.split(separator: ":")

        guard parts.count == 2 || parts.count == 3 else { return nil }

        guard let seconds = Int(parts[parts.count - 1]) else { return nil }
        guard seconds >= 0 && seconds < 60 else { return nil }

        guard let minutes = Int(parts[parts.count - 2]) else { return nil }
        guard minutes >= 0 && minutes < 60 else { return nil }

        if parts.count <= 2 {
            return TimeInterval(seconds + 60 * minutes)
        }

        guard let hours = Int(parts[0]) else { return nil }
        guard hours >= 0 else { return nil }

        return TimeInterval(seconds + 60 * (minutes + 60 * hours))
    }
}
