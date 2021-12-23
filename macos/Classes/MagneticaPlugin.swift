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
            
            guard let magneticaKeyCombo = try? JSONDecoder().decode(MagneticaKeyCombo.self, from: typedData!.data) else { return }
            guard let keyCombo = magneticaKeyCombo.convertKeyCombo() else { return }
            
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

public final class MagneticaKeyCombo: NSObject, NSCopying, NSCoding, Codable {
    let key: String
    let doubledModifiers: Bool
    let modifiers: Int
    
    public convenience init?(key: String, carbonModifiers: Int) {
        self.init(key: key, cocoaModifiers: NSEvent.ModifierFlags(carbonModifiers: carbonModifiers))
    }
    
    public init?(key: String, cocoaModifiers: NSEvent.ModifierFlags) {
        let filterdCocoaModifiers = cocoaModifiers.filterUnsupportModifiers()
        guard filterdCocoaModifiers.containsSupportModifiers else { return nil }
        self.key = key
        self.modifiers = filterdCocoaModifiers.carbonModifiers(isSupportFunctionKey: true)
        self.doubledModifiers = false
    }
    
    public func copy(with zone: NSZone?) -> Any {
        return MagneticaKeyCombo(key: key, carbonModifiers: modifiers) as Any
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: CodingKeys.key.rawValue)
        aCoder.encode(modifiers, forKey: CodingKeys.modifiers.rawValue)
        aCoder.encode(doubledModifiers, forKey: CodingKeys.doubledModifiers.rawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(modifiers, forKey: .modifiers)
        try container.encode(doubledModifiers, forKey: .doubledModifiers)
    }
    
    public init?(coder aDecoder: NSCoder) {
        self.doubledModifiers = aDecoder.decodeBool(forKey: CodingKeys.doubledModifiers.rawValue)
        self.modifiers = aDecoder.decodeInteger(forKey: CodingKeys.modifiers.rawValue)
        self.key = CodingKeys.keyCode.rawValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.doubledModifiers = try container.decode(Bool.self, forKey: .doubledModifiers)
        self.modifiers = try container.decode(Int.self, forKey: .modifiers)
    }
    
    private enum CodingKeys: String, CodingKey {
        case key
        case keyCode
        case QWERTYKeyCode
        case modifiers
        case doubledModifiers
    }
    
    public func convertKeyCombo() -> KeyCombo? {
        return KeyCombo.init(QWERTYKeyCode: self.convertCharacter(), carbonModifiers: self.modifiers) ?? nil
    }
    
    func convertCharacter() -> Int {
        switch self.key {
        case "a":
            return kVK_ANSI_A
        case "s":
            return kVK_ANSI_S
        case "d":
            return kVK_ANSI_D
        case "f":
            return kVK_ANSI_F
        case "h":
            return kVK_ANSI_H
        case "g":
            return kVK_ANSI_G
        case "z":
            return kVK_ANSI_Z
        case "x":
            return kVK_ANSI_X
        case "c":
            return kVK_ANSI_C
        case "v":
            return kVK_ANSI_V
        case "b":
            return kVK_ANSI_B
        case "q":
            return kVK_ANSI_Q
        case "w":
            return kVK_ANSI_W
        case "e":
            return kVK_ANSI_E
        case "r":
            return kVK_ANSI_R
        case "y":
            return kVK_ANSI_Y
        case "t":
            return kVK_ANSI_T
        case "1":
            return kVK_ANSI_1
        case "2":
            return kVK_ANSI_2
        case "3":
            return kVK_ANSI_3
        case "4":
            return kVK_ANSI_4
        case "6":
            return kVK_ANSI_6
        case "5":
            return kVK_ANSI_5
        case "=":
            return kVK_ANSI_Equal
        case "9":
            return kVK_ANSI_9
        case "7":
            return kVK_ANSI_7
        case "-":
            return kVK_ANSI_Minus
        case "8":
            return kVK_ANSI_8
        case "0":
            return kVK_ANSI_0
        case "RightBracket":
            return kVK_ANSI_RightBracket
        case "o":
            return kVK_ANSI_O
        case "u":
            return kVK_ANSI_U
        case "LeftBracket":
            return kVK_ANSI_LeftBracket
        case "i":
            return kVK_ANSI_I
        case "p":
            return kVK_ANSI_P
        case "l":
            return kVK_ANSI_L
        case "j":
            return kVK_ANSI_J
        case "'":
            return kVK_ANSI_Quote
        case "k":
            return kVK_ANSI_K
        case ";":
            return kVK_ANSI_Semicolon
        case "\\":
            return kVK_ANSI_Backslash
        case ",":
            return kVK_ANSI_Comma
        case "/":
            return kVK_ANSI_Slash
        case "n":
            return kVK_ANSI_N
        case "m":
            return kVK_ANSI_M
        case ".":
            return kVK_ANSI_Period
        case "`":
            return kVK_ANSI_Grave
        case "⏎":
            return kVK_Return
        case "⇔":
            return kVK_Tab
        case "☐":
            return kVK_Space
        case "⌫":
            return kVK_Delete
        case "Esc":
            return kVK_Escape
        case "⌘":
            return kVK_Command
        case "⇧":
            return kVK_Shift
        case "⌥":
            return kVK_Option
        case "⌃":
            return kVK_Control
        case "fn":
            return kVK_Function
        case "F17":
            return kVK_F17
        case "F18":
            return kVK_F18
        case "F19":
            return kVK_F19
        case "F20":
            return kVK_F20
        case "F5":
            return kVK_F5
        case "F6":
            return kVK_F6
        case "F7":
            return kVK_F7
        case "F3":
            return kVK_F3
        case "F8":
            return kVK_F8
        case "F9":
            return kVK_F9
        case "F11":
            return kVK_F11
        case "F13":
            return kVK_F13
        case "F16":
            return kVK_F16
        case "F14":
            return kVK_F14
        case "F10":
            return kVK_F10
        case "F12":
            return kVK_F12
        case "F15":
            return kVK_F15
        case "Help":
            return kVK_Help
        case "Home":
            return kVK_Home
        case "PageUp":
            return kVK_PageUp
        case "ForwardDelete":
            return kVK_ForwardDelete
        case "F4":
            return kVK_F4
        case "End":
            return kVK_End
        case "F2":
            return kVK_F2
        case "PageDown":
            return kVK_PageDown
        case "F1":
            return kVK_F1
        case "left":
            return kVK_LeftArrow
        case "right":
            return kVK_RightArrow
        case "down":
            return kVK_DownArrow
        case "up":
            return kVK_UpArrow
        case "¥":
            return kVK_JIS_Yen
        case "_":
            return kVK_JIS_Underscore
        case "eisu":
            return kVK_JIS_Eisu
        case "kana":
            return kVK_JIS_Kana
        case "enter":
            return kVK_Return
        case "tab":
            return kVK_Tab
        case "space":
            return kVK_Space
        case "delete":
            return kVK_Delete
        case "esc":
            return kVK_Escape
        case "command":
            return kVK_Command
        case "shift":
            return kVK_Shift
        case "caps":
            return kVK_CapsLock
        case "option":
            return kVK_Option
        case "ctrl":
            return kVK_Control
        case "rightCommand":
            return kVK_RightCommand
        case "rightShift":
            return kVK_RightShift
        case "rightOption":
            return kVK_RightOption
        case "rightCtrl":
            return kVK_RightControl
        case "f17":
            return kVK_F17
        case "volumeUp":
            return kVK_VolumeUp
        case "volumeDown":
            return kVK_VolumeDown
        case "mute":
            return kVK_Mute
        default:
            return 0
        }
    }
}
