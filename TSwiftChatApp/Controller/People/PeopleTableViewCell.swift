//
//  PeopleTableViewCell.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 24/09/2023.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadGuestInfo(user : User){
        avatarImage.roundedImage(fromURL: URL(string: user.avatar),placeholderImage: UIImage(named: "avatar"))
        userNameLabel.text = user.username
        statusLabel.text = user.status
    }
    
}
