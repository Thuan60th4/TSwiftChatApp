//
//  MessagesLayoutDelegate.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 13/10/2023.
//

import Foundation
import MessageKit

extension ChatDetailViewController : MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 || indexPath.section >= 1 && isNotTheSameDate(date1: mkMessages[indexPath.section - 1].sentDate, date2: mkMessages[indexPath.section].sentDate)
        {
            return 18
        }
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
}
