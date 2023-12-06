//
//  ChatTableViewCell.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 28/09/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlet
    @IBOutlet weak var chatImageOutlet: UIImageView!
    @IBOutlet weak var chatNameOutlet: UILabel!
    
    @IBOutlet weak var messageContainOutlet: UIStackView!
    @IBOutlet weak var lastMessageOutlet: UILabel!
    @IBOutlet weak var timeSentOutlet: UILabel!
    @IBOutlet weak var isReadViewOutlet: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isReadViewOutlet.layer.cornerRadius = isReadViewOutlet.frame.width/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func loadChatInfoFor(chat : Chat){
        if let guestId = chat.memberIds.first(where: { $0 != User.currentId}), let guestData = FirebaseChatListeners.shared.listUser[guestId]
        {
            chatImageOutlet.roundedImage(fromURL: URL(string: guestData.avatar), placeholderImage: UIImage(named: "avatar"))
            chatNameOutlet.text = guestData.username
            lastMessageOutlet.text = chat.lastMessage
            timeSentOutlet.text = "• \(convertDate(chat.date ?? Date()))"
        }
    }
    func loadSearchUserFor(user : User){
        chatImageOutlet.roundedImage(fromURL: URL(string: user.avatar), placeholderImage: UIImage(named: "avatar"))
        chatNameOutlet.text = user.username
        isReadViewOutlet.isHidden = true
    }
}
