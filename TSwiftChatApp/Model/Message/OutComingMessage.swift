//
//  OutgoingMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 21/10/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import CoreLocation

class OutComingMessage {
    class func sendMessageTo(chatRoomId: String,text: String?, photo: UIImage?, video: URL? , location: CLLocationCoordinate2D?, audio: String?, audioDuration: Double = 0.0,memberIds : [String]?){
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
        else if video != nil{
            sendVideoMessage(message: message, videoUrl: video!)
            lastMessage = "Sent a video"
        }
        else if location != nil{
            sendLocationMessage(message: message, location: location!)
            lastMessage = "Sent a location"
        }
        else if audio != nil{
            message.audioDuration = audioDuration
            sendAudioMessage(message: message, audioFileName: audio!)
            lastMessage = "Sent a audio"
        }
        else if text != nil{
            sendTextMessage(message: message, text: text!)
            lastMessage = text!
        }
        
        //Update recent chat
        if memberIds != nil{
            startChat(message: lastMessage, memberIds: memberIds!)
        }
        
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
//    message.message = "Sent a picture"
    message.type = KPHOTO    
    let fileDirectory = "MediaMessage/photo/\(message.chatRoomId)/_\(UUID().uuidString).jpg"
    FireStorage.uploadImageFor(directory: fileDirectory, photo) { imageUrl in
        if (imageUrl != nil) {
            message.pictureUrl = imageUrl!
            OutComingMessage.saveMessage(message: message)
        }
    }
}

func sendVideoMessage(message : LocalMessage,videoUrl : URL){
//    message.message = "Sent a video"
    message.type = KVIEDEO
    
    let thumbnailImage = generateThumbnailVideo(for: videoUrl) ?? UIImage(named: "photoPlaceholder")!
    FireStorage.uploadVideoTo(chatRoomId : message.chatRoomId, videoURL: videoUrl, thumbnail: thumbnailImage) { thumbnailLink, videoLink in
        message.pictureUrl = thumbnailLink
        message.videoUrl = videoLink
        OutComingMessage.saveMessage(message: message)
    }
}

func sendLocationMessage(message : LocalMessage,location : CLLocationCoordinate2D){
//    message.message = "Sent a location"
    message.type = KLOCATION
    message.latitude = location.latitude
    message.longitude = location.longitude
    OutComingMessage.saveMessage(message: message)
}

func sendAudioMessage(message : LocalMessage,audioFileName: String){
//    message.message = "Sent a audio"
    message.type = KAUDIO
    FireStorage.uploadAudioTo(chatRoomId: message.chatRoomId, audioFileName: audioFileName) { audioUrl in
        message.audioUrl = audioUrl ?? ""
        OutComingMessage.saveMessage(message: message)
    }
}
