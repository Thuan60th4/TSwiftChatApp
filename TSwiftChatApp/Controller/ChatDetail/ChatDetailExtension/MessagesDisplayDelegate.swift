//
//  MessagesDisplayDelegate.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 13/10/2023.
//

import Foundation
import MessageKit
import SDWebImage

extension ChatDetailViewController : MessagesDisplayDelegate {
    //MARK: - Cell label
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section == 0 || indexPath.section >= 1 && isNotTheSameDate(date1: mkMessages[indexPath.section - 1].sentDate, date2: mkMessages[indexPath.section].sentDate)
        {
            let text = MessageKitDateFormatter.shared.string(from: mkMessages[indexPath.section].sentDate)
            return NSAttributedString(string: text,attributes: [.font : UIFont.systemFont(ofSize: 13)])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let text = mkMessages[indexPath.section].sentDate.getTime()
        return NSAttributedString(string: text,attributes: [.font : UIFont.systemFont(ofSize: 11)])
    }
    
    //MARK: - avatar
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        avatarView.roundedImage(fromURL: URL(string : isFromCurrentSender(message: message) ? User.currentUser?.avatar as! String : chatAvatar), placeholderImage: UIImage(named: "avatar"))
//    }
    
    //MARK: - Load photo message
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let msg = message as? MKMessage , (msg.photoItem != nil || msg.videoItem != nil){
            let photoUrl = msg.photoItem?.url ?? msg.videoItem?.thumbnailUrl
            let placeholderImage = msg.photoItem?.placeholderImage ?? msg.videoItem?.placeholderImage
            
            imageView.sd_setImage(with: photoUrl, placeholderImage: placeholderImage)
        }
    }
    
    //MARK: - color message
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? MessageDefault.bubbleColorOutcoming! : MessageDefault.bubbleColorIncoming!
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .pointedEdge)
    }
}
