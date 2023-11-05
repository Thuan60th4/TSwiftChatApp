//
//  OutgoingMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 21/10/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class OutComingMessage {
    class func sendMessageTo(chatRoomId: String,text: String?, photo: UIImage?, video: String? , location: String?, audio: String?, audioDuration: Float = 0.0,memberIds : [String]){
        var lastMessage = ""
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatRoomId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.status = KSENT
        if photo != nil{
            sendPhotoMessage(message: message, photo: photo!)
            lastMessage = "Sent a picture"
        }
        else if text != nil{
            sendTextMessage(message: message, text: text!)
            lastMessage = text!
        }
        
        //Update recent chat
        startChat(message: lastMessage, memberIds: memberIds)
        
        //Send push notification
    }
    
    class func saveMessage(message : LocalMessage){
        FirebaseChatListeners.shared.addAMessage(message: message)
//        RealmManager.shared.saveToRealm(message)
        print("Save to realm success")
    }
}

func sendTextMessage(message : LocalMessage,text : String){
    message.message = text
    message.type = KTEXT
    OutComingMessage.saveMessage(message: message)
}

func sendPhotoMessage(message : LocalMessage,photo : UIImage){
    message.message = "Sent a picture"
    message.type = KPHOTO    
    let fileDirectory = "MediaMessage/photo/\(message.chatRoomId)/_\(UUID().uuidString).jpg"
    FireStorage.uploadImageFor(directory: fileDirectory, photo) { imageUrl in
        if (imageUrl != nil) {
            message.pictureUrl = imageUrl!
            OutComingMessage.saveMessage(message: message)
        }
    }
}
