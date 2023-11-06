//
//  PhotoMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 06/11/2023.
//

import Foundation
import MessageKit
import UIKit

class VideoMessage : NSObject,MediaItem{
    var url: URL?
    var thumbnailUrl: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(videoLink : String, thumbnailLink: String){
        url = URL(string: videoLink)
        thumbnailUrl = URL(string: thumbnailLink)
        placeholderImage = UIImage(named: "photoPlaceholder")!
        size = CGSize(width: 240, height: 240)
    }
    
}
