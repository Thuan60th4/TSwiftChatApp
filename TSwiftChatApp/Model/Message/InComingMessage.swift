//
//  InComingMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 22/10/2023.
//

import Foundation
import MessageKit
import CoreLocation

class InComingMessage {
    var messageViewController : MessagesViewController
    init(messageViewController : MessagesViewController){
        self.messageViewController = messageViewController
    }
    
    //MARK: - convert a message
    func convertMessage(message : LocalMessage) -> MKMessage?{
        //multimedia message
        return MKMessage(messages: message)
    }
}
