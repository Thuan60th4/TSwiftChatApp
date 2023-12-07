//
//  Channel.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 07/12/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Channel : Codable{
    var id = ""
    var groupName = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var descriptionChannel = ""
    @ServerTimestamp var createDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
}
