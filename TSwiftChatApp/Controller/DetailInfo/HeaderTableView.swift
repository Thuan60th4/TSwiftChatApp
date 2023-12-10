//
//  HeaderTableView.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 10/12/2023.
//

import UIKit

class HeaderTableView: UIView {

    //MARK: - Var
    var imageLink: String?{
        didSet{
            self.avatarImageView.loadImage(fromURL: URL(string: imageLink!),placeholderImage: UIImage(named: "photoPlaceholder"))
        }
    }
    var name: String?{
        didSet{
            nameLabel.text = name
        }
    }

    //MARK: - UI Component
   private let avatarImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
        
    }()
    
   private let nameLabel: UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
       label.textColor = .white
       label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(avatarImageView)
        addGradient()
        addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.frame = bounds
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -45),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 20),
        ])
    }
    
    func addGradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor,UIColor.black.cgColor]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }

}
