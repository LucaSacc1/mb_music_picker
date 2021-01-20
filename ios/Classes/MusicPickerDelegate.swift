//
//  MusicPickerDelegate.swift
//  mb_music_picker
//
//  Created by Alessandro Viviani on 15/01/21.
//

import Foundation
import MediaPlayer

class MusicPickerDelegate: NSObject, MPMediaPickerControllerDelegate {
    public var musicPickerController: MPMediaPickerController
    public var didComplete: (([String: String]?) -> Void)?
    
    init(withResult result: @escaping FlutterResult) {
        self.musicPickerController = MPMediaPickerController(mediaTypes: .music)
        super.init()
        
        musicPickerController.allowsPickingMultipleItems = false
        musicPickerController.showsCloudItems = false
        if #available(iOS 9.2, *) {
            musicPickerController.showsItemsWithProtectedAssets = false
        } else {
            // Fallback on earlier versions
        }
        musicPickerController.modalPresentationStyle = .overFullScreen
        musicPickerController.delegate = self
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        guard let song = mediaItemCollection.items.first else {
            self.didComplete?(nil)
            return
        }
        
        if song.assetURL == nil {
            musicPickerController.showAlert(withTitle: "Bad Choice", body: "Impossible to pick this song")
            mediaPicker.dismiss(animated: true, completion: nil)
            self.didComplete?(nil)
        }
        mediaPicker.dismiss(animated: true, completion: nil)
        
        self.didComplete?(MediaItemConverter.convert(song: song))
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
        self.didComplete?(nil)
    }
}

extension UIViewController {
    func showAlert(withTitle title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
