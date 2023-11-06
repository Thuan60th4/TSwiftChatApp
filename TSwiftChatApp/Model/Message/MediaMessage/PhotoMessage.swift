//
//  PhotoMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 05/11/2023.
//

import Foundation
import MessageKit
import UIKit

class PhotoMessage : NSObject,MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path : String){
        url = URL(string: path)
        placeholderImage = UIImage(named: "photoPlaceholder")!
        size = CGSize(width: 240, height: 240)
    }
    
}
