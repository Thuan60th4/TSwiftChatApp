//
//  UserTableViewCell.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 16/12/2023.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    static let identifier = "UserTableViewCell"
    
    let avatarImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    let userStackContain: UIStackView = {
        let userStackContain = UIStackView()
        userStackContain.axis = .horizontal
        userStackContain.translatesAutoresizingMaskIntoConstraints = false
        userStackContain.spacing = 10
        return userStackContain
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.addSubview(userStackContain)
        userStackContain.addArrangedSubview(avatarImageView)
        userStackContain.addArrangedSubview(nameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            userStackContain.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 15),
            userStackContain.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -15),
            userStackContain.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            userStackContain.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant:-10),
        ])
        
    }
    func configure(avatarLink: String, name: String) {
        avatarImageView.roundedImage(fromURL: URL(string : avatarLink),placeholderImage: UIImage(named: "avatar"))
        nameLabel.text = name
    }
    
}
