import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Wide enough for the desktop layout (sidebar + panes, >= 900pt) by
    // default; the minimum still allows the compact phone-style layout.
    self.setContentSize(NSSize(width: 1180, height: 760))
    self.minSize = NSSize(width: 480, height: 560)
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
