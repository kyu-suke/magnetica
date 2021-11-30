import Cocoa
import FlutterMacOS
import Magnet
import Carbon

public class MagneticaPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    var eventChannel: FlutterEventChannel? {
        didSet {
            oldValue?.setStreamHandler(nil)
            eventChannel?.setStreamHandler(self)
        }
    }
    var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "magnetica", binaryMessenger: registrar.messenger)
        let instance = MagneticaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "magnetica/stream",
                                                  binaryMessenger: registrar.messenger)
        eventChannel.setStreamHandler(instance)
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "register":
            if call.arguments == nil {
                result("argument is empty")
                return
            }
            let args = call.arguments as! Dictionary<String, Any>
            let typedData = args["keyCombo"] as? FlutterStandardTypedData
            if typedData == nil {
                return
            }
            
            let hotKeyName = args["hotKeyName"] as? String
            if hotKeyName == nil {
                return
            }
            
            guard let keyCombo = try? JSONDecoder().decode(KeyCombo.self, from: typedData!.data) else { return }
            
            HotKeyCenter.shared.unregisterHotKey(with: hotKeyName!)
            let hotKey = HotKey(identifier: hotKeyName!,
                                keyCombo: keyCombo,
                                target: MagneticaKeyComboAction(hotKeyName: hotKeyName!, eventSink: eventSink),
                                action: #selector(MagneticaKeyComboAction.called))
            hotKey.register()
            result("register")
            
        case "unregister":
            let args = call.arguments as! Dictionary<String, Any>
            let hotKeyName = args["hotKeyName"] as? String
            if hotKeyName == nil {
                return
            }
            
            HotKeyCenter.shared.unregisterHotKey(with: hotKeyName!)
            result("unregister")
        case "unregisterAll":
            HotKeyCenter.shared.unregisterAll()
            result("unregisterAll")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @objc func hotkeyCalled() {
        guard let eventSink = eventSink else {
            return
        }
        eventSink("HotKey called in dart!!!!")
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    public class MagneticaKeyComboAction: NSObject {
        var hotKeyName: String = ""
        var eventSink: FlutterEventSink?
        init(hotKeyName: String, eventSink: FlutterEventSink?) {
            self.hotKeyName = hotKeyName
            self.eventSink = eventSink
        }
        
        @objc func called() {
            guard let eventSink = eventSink else {
                return
            }
            eventSink(hotKeyName)
        }
    }
    
}

