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
//    var readDate: Date
    var status : String
    var incoming : Bool
    
    init(messages : LocalMessage){
        messageId = messages.id
        kind = MessageKind.text(messages.message)
//        switch messages.type {
//            case <#pattern#>:
//                <#code#>
//            default:
//                <#code#>
//        }
        mkSender = MKSender(senderId: messages.senderId, displayName: messages.senderName)
        sentDate = Date(timeIntervalSince1970 :messages.sentDate)
//        readDate = messages.readDate
        status = messages.status
        incoming = User.currentId != messages.senderId
    }
}
