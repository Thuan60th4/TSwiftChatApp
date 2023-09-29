//
//  Chat.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 28/09/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Chat : Codable {
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var recieverId = ""
    var recieverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var isReaded = false
    var avatarLink = ""
}
