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
    var memberIdsLeft = [""]
    var lastMessage = ""
    var createtedById = ""
    var updatedById = ""
    var timeLeave :[String: TimeInterval]?
    var isRead :[String: Bool] = [:]
    
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

func startChat(message : String,memberIds : [String]){
    let chatRoomId = getChatRoomIdFrom(memberIds: memberIds)
    let guestId = memberIds.first( where: { $0 != User.currentId})
    var isReadDict : [String:Bool] = [:]
    if guestId != nil {
        isReadDict[guestId!] = false
    }
    let recentChat = Chat(id: UUID().uuidString, chatRoomId: chatRoomId, date: Date(), memberIds: memberIds,memberIdsLeft: memberIds, lastMessage: message, createtedById: User.currentId, updatedById: User.currentId,isRead: isReadDict)
    FirebaseChatListeners.shared.createNewChat(recentChat)
}
