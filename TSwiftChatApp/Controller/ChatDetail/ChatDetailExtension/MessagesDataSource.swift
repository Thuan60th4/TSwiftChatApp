//
//  MessagesDataSource.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 13/10/2023.
//

import Foundation
import MessageKit

extension ChatDetailViewController : MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
}
