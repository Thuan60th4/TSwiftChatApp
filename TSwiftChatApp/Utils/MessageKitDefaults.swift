//
//  MessageKitDefaults.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 17/10/2023.
//

import Foundation
import UIKit
import MessageKit

struct MKSender : SenderType,Equatable{
    var senderId: String
    var displayName: String
}

enum MessageDefault {
    static let bubbleColorIncoming = UIColor(named : "chatIncomingBubble")
    static let bubbleColorOutcoming = UIColor(named : "chatOutgoingBubble")
}
