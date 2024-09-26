//  Created by Erez Volk

import Cocoa
import UserNotifications

class TimerooAppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?
    var totalTime: TimeInterval = 0
    var isPaused: Bool = true
    var popover: NSPopover!
    let stopwatch = NSImage( // https://github.com/sam4096/apple-sf-symbols-list
        systemSymbolName: "stopwatch.fill",
        accessibilityDescription: "timer"
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        disableForceQuit()
        createStatusItem()
        updateStatusBarTitle()
        setUpPopover()
        createMenu()
        requestNotificationPermissions()
    }

    /// Stop the timer if active
    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
    }

    func disableForceQuit() {
        NSApplication.shared.setActivationPolicy(.prohibited)
    }

    func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }

    /// Create the "Set..." popover
    func setUpPopover() {
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

        popover = NSPopover()
        popover.contentViewController = contentViewController
        popover.behavior = .transient // Automatically closes when focus is lost
    }

    func createMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Start/Pause", action: #selector(startPauseTimer), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Clear", action: #selector(clearTimer), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Set...", action: #selector(showPopover), keyEquivalent: ""))

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: ""))
        statusItem.menu = menu
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, error in
            if let error = error {
                print("Failed to request notification permission: \(error)")
            }
        }
    }

    @objc func startPauseTimer() {
        if isPaused {
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
        } else {
            // Pause the timer
            timer?.invalidate()
            timer = nil
            isPaused = true
            updateStatusBarTitle()
            sendNotification("Pausing at \(getTimeString())")
        }
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
            statusItem.button?.image = stopwatch
            statusItem.button?.title = ""
            statusItem.button?.appearsDisabled = false
        } else {
            statusItem.button?.image = nil
            statusItem.button?.title = getTimeString()
            statusItem.button?.appearsDisabled = isPaused
        }
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
        return popover.contentViewController?.view.subviews.first(where: { $0 is NSTextField }) as? NSTextField
    }

    @objc func showPopover() {
        // Show the popover next to the status item
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            if let textField = getPopoverTextField() {
                textField.becomeFirstResponder() // Make the text field active
            }
        }
    }

    @objc func setTimerFromPopover() {
        if let total = parsePopover() {
            totalTime = TimeInterval(total)
            updateStatusBarTitle()
        }
        popover.performClose(nil) // Close the popover after setting the timer
    }

    func parsePopover() -> Int? {
        guard let textField = getPopoverTextField() else { return nil }

        let timeString = textField.stringValue
        textField.stringValue = ""  // For next time
        let parts = timeString.split(separator: ":")

        guard parts.count == 2 || parts.count == 3 else { return nil }

        guard let seconds = Int(parts[parts.count - 1]) else { return nil }
        guard seconds >= 0 && seconds < 60 else { return nil }

        guard let minutes = Int(parts[parts.count - 2]) else { return nil }
        guard minutes >= 0 && minutes < 60 else { return nil }

        if parts.count <= 2 {
            return seconds + 60 * minutes
        }

        guard let hours = Int(parts[0]) else { return nil }
        guard hours >= 0 else { return nil }

        return seconds + 60 * (minutes + 60 * hours)
    }
}
