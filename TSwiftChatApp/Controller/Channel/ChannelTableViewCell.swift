//
//  ChannelTableViewCell.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 07/12/2023.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    //MARK: - IBOutlet
    @IBOutlet weak var channelImageOutlet: UIImageView!
    @IBOutlet weak var channelNameOutlet: UILabel!
    
    @IBOutlet weak var descriptionOutlet: UILabel!
    @IBOutlet weak var numberMembersOutlet: UILabel!
    @IBOutlet weak var timeSentOutlet: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(channel : Channel){
        channelImageOutlet.roundedImage(fromURL: URL(string: channel.avatarLink), placeholderImage: UIImage(named: "avatar"))
        channelNameOutlet.text = channel.groupName
        descriptionOutlet.text = channel.descriptionChannel
        numberMembersOutlet.text = "\(channel.memberIds.count) member"
        timeSentOutlet.text = "\(convertDate(channel.lastMessageDate ?? Date()))"
    }

}
