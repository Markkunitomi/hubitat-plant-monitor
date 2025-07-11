import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Close any automatically opened windows
        for window in NSApp.windows {
            window.close()
        }
        
        menuBarController = MenuBarController()
        
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up resources
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}