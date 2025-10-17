import Flutter
import UIKit
import MediaPlayer

public class SwiftMbMusicPickerPlugin: NSObject, FlutterPlugin {
    private let flutterViewController: UIViewController
    private var musicPickerDelegate: MusicPickerDelegate?
    
    init(withViewController viewController: UIViewController) {
        flutterViewController = viewController
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "mb_music_picker", binaryMessenger: registrar.messenger())
      
      guard let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate else { return }
      
      let rootViewController = appDelegate.window?.rootViewController ?? UIViewController()
      
      let instance = SwiftMbMusicPickerPlugin(withViewController: rootViewController)
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "openMusicSelection" {
            showMusicPicker(withResult: result)
        }
    }
    
    func showMusicPicker(withResult result: @escaping FlutterResult) {
        self.musicPickerDelegate = MusicPickerDelegate(withResult: result)
        
        self.musicPickerDelegate!.didComplete = { [weak self] (song) in
            self?.musicPickerDelegate = nil
            
            result(song)
        }
        
        DispatchQueue.main.async {
            self.flutterViewController.present(self.musicPickerDelegate!.musicPickerController, animated: true)
        }
    }
}
