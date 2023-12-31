//
//  MKMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 17/10/2023.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType{
    var messageId: String
    var kind: MessageKind
    var mkSender : MKSender
    var sender: SenderType {
        return mkSender
    }
    var sentDate: Date
    var status : String
    
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem : AudioMessage?
    
    init(messages : LocalMessage){
        messageId = messages.id
        switch messages.type {
            case KTEXT:
                kind = MessageKind.text(messages.message)
            case KPHOTO:
               let photo = PhotoMessage(path: messages.pictureUrl)
                kind = MessageKind.photo(photo)
                photoItem = photo
            case KVIEDEO:
                let video = VideoMessage(videoLink: messages.videoUrl, thumbnailLink: messages.pictureUrl)
                kind = MessageKind.video(video)
                videoItem = video
            case KLOCATION:
                let location = LocationMessage(location: CLLocation(latitude: messages.latitude, longitude: messages.longitude))
                kind = MessageKind.location(location)
                locationItem = location
            case KAUDIO:
                let audio = AudioMessage(audioLink: messages.audioUrl, duration: Float(messages.audioDuration))
                kind = MessageKind.audio(audio)
                audioItem = audio
            default:
                kind = MessageKind.text(messages.message)
        }
        mkSender = MKSender(senderId: messages.senderId, displayName: messages.senderName)
        sentDate = Date(timeIntervalSince1970: messages.sentDate)
        status = messages.status
    }
}
