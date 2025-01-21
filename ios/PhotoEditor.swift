//
//  PhotoEditor.swift
//  PhotoEditor
//
//  Created by Donquijote on 27/07/2021.
//

import Foundation
import HXPhotoPicker

public enum ImageLoad: Error {
    case failedToLoadImage(String)
}

@objc(PhotoEditor)
class PhotoEditor: NSObject {
    
    @objc(open:withResolver:withRejecter:)
    func open(options: NSDictionary, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        
        // handle path
        guard let path = options["path"] as? String else {
            reject("DONT_FIND_IMAGE", "Dont find image", nil)
            return;
        }
        let animated = options["animated"] as? Bool ?? true
        let quality = options["photoQuality"] as? CGFloat ?? 0.4
        let asset: EditorAsset
        guard let url = URL(string: path), let data = try? Data(contentsOf: url)
        else {
            reject("DONT_FIND_IMAGE", "Dont find image", nil)
            return
        }
        
        asset = .init(type: .imageData(data))
        var config = EditorConfiguration()
        config.toolsView.toolOptions = config.toolsView.toolOptions.filter { element in 
            element.type == .cropSize || element.type == .text || 
            element.type == .graffiti || element.type == .mosaic
        }
        
        Task {
            do {
                let editorAsset = try await Photo.edit(asset, config: config)
                resolve(editorAsset.result?.url.absoluteString ?? path)
            } catch {
                reject("USER_CANCELLED", "User has cancelled", error)
            }
        }
    }
}

