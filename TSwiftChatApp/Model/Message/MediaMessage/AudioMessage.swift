//
//  AudioMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 04/12/2023.
//

import Foundation
import MessageKit

class AudioMessage : NSObject,AudioItem{
    var url: URL
    var duration: Float
    var size: CGSize
    
    init(audioLink : String, duration : Float){
        url = URL(string: audioLink) ?? URL(fileURLWithPath: "")
        self.duration = duration
        size = CGSize(width: 160, height: 40)
    }
}
