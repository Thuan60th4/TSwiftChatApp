//
//  LocalMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 18/10/2023.
//

import Foundation
import RealmSwift

class LocalMessage : Object,Codable {
    @Persisted var id = ""
    @Persisted var chatRoomId = ""
    @Persisted var sentDate = Date()
    @Persisted var senderName = ""
    @Persisted var senderId = ""
//    @Persisted var readDate = Date()
    @Persisted var type = ""
    @Persisted var status = ""
    
    @Persisted var message = ""
    @Persisted var audioUrl = ""
    @Persisted var audioDuration = 0.0
    @Persisted var videoUrl = ""
    @Persisted var pictureUrl = ""
    @Persisted var latitude = ""
    @Persisted var longitude = 0.0
    override class func primaryKey() -> String? {
        return "id"
    }
}

