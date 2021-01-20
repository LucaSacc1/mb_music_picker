//
//  MediaItemConverter.swift
//  mb_music_picker
//
//  Created by Alessandro Viviani on 15/01/21.
//

import Foundation
import MediaPlayer

struct MediaItemConverter {
    static func convert(song: MPMediaItem) -> [String: String] {
        var result = [String: String]()
        
        result["persistent_id"] = song.persistentID.description
        result["title"] = song.title
        result["artist"] = song.artist
        
        if let assetUrl = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
            result["asset_url"] = assetUrl.relativeString
        }
        return result
    }
}
