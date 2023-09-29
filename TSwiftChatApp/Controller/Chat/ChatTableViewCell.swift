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
        chatImageOutlet.roundedImage(fromURL: URL(string: chat.avatarLink))
        chatNameOutlet.text = chat.senderName
        lastMessageOutlet.text = chat.lastMessage
        timeSentOutlet.text = convertDate(chat.date ?? Date())
        isReadViewOutlet.isHidden = chat.isReaded
    }
    
}
