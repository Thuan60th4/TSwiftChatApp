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
    @Persisted var sentDate = Date().timeIntervalSince1970
    @Persisted var senderName = ""
    @Persisted var senderId = ""
    @Persisted var memberLocalId = "" // thêm vào đây chủ yếu để phân biệt các máy ở local dùg setValue bên RealmManager
    @Persisted var type = ""
    @Persisted var status = ""
    
    @Persisted var message = ""
    @Persisted var audioUrl = ""
    @Persisted var audioDuration = 0.0
    @Persisted var videoUrl = ""
    @Persisted var pictureUrl = ""
    @Persisted var latitude = 0.0
    @Persisted var longitude = 0.0
    override class func primaryKey() -> String? {
        return "id"
    }
}

