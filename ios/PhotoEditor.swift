//
//  PhotoEditor.swift
//  PhotoEditor
//
//  Created by Donquijote on 27/07/2021.
//

import Foundation
import UIKit
import Photos
import SDWebImage
import AVFoundation
import ZLImageEditor

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
        
        getUIImage(url: path) { image in
            DispatchQueue.main.async {
                //  set config
                ZLImageEditorConfiguration.default().editImageTools ([.draw, .clip, .textSticker, .mosaic ])
              if let controller = UIApplication.getTopViewController() {
                  controller.modalTransitionStyle = .crossDissolve
                  
                  ZLEditImageViewController.showEditImageVC(parentVC:controller, animate: animated, image: image) { (resImage, editModel) in
                      let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                      
                      let destinationPath = URL(fileURLWithPath: documentsPath).appendingPathComponent(String(Int64(Date().timeIntervalSince1970 * 1000)) + ".jpg")
                      
                      do {
                        try resImage.jpegData(compressionQuality: quality)?.write(to: destinationPath)
                          resolve(destinationPath.absoluteString)
                      } catch {
                          debugPrint("writing file error", error)
                      }
                  } cancelBlock: {
                      reject("USER_CANCELLED", "User has cancelled", nil)
                  }
              }

            }
        } reject: {_ in
            reject("LOAD_IMAGE_FAILED", "Load image failed: " + path, nil)
        }
    }
    
    private func getUIImage (url: String ,completion:@escaping (UIImage) -> (), reject:@escaping(String)->()){
        if let path = URL(string: url) {
            SDWebImageManager.shared.loadImage(with: path, options: .continueInBackground, progress: { (recieved, expected, nil) in
            }, completed: { (downloadedImage, data, error, SDImageCacheType, true, imageUrlString) in
                DispatchQueue.main.async {
                    if(error != nil){
                        print("error", error as Any)
                        reject("false")
                        return;
                    }
                    if downloadedImage != nil{
                        completion(downloadedImage!)
                    }
                }
            })
        }else{
            reject("false")
        }
    }
    
}

extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
}
