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
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var createtedById = ""
    var updatedById = ""
    
    //    var senderId = ""
    //    var senderName = ""
    //    var recieverId = ""
    //    var recieverName = ""
    
    //    var isReaded = false
    //    var avatarLink = ""
}

func getChatRoomIdFrom(memberIds: [String]) -> String{
    var ids = memberIds
    ids.sort()
    return ids.joined()
}

func startChat(message : String = "test",memberIds : [String]){
    let chatRoomId = getChatRoomIdFrom(memberIds: memberIds)
    
    let recentChat = Chat(id: UUID().uuidString, chatRoomId: chatRoomId, date: Date(), memberIds: memberIds, lastMessage: message, createtedById: User.currentId, updatedById: User.currentId)
    FirebaseChatListeners.shared.createNewChat(recentChat)
}
