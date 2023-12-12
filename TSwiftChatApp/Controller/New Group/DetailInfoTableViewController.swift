//
//  DetailInfoTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 10/12/2023.
//

import UIKit

enum DetailInfo {
    case chat(User?)
    case channel(Channel?)
}

class DetailInfoTableViewController: UITableViewController {
    
    //MARK: - Vars
    var imageAvatar: String = ""
    var name: String = "N/A"
    var moreInfo: String = "N/A"
    var aboutInfo : String = "No bio yet"
    var detailInfo: DetailInfo?{
        didSet{
            switch detailInfo {
                case .chat(let guestUser):
                    if let guestUserData = guestUser{
                        imageAvatar = guestUserData.avatar
                        name = guestUserData.username
                        moreInfo = guestUserData.email
                        if guestUserData.description != "" {
                            aboutInfo = guestUserData.description
                        }
                    }
                case .channel(let channelData):
                    if let channelData = channelData{
                        imageAvatar = channelData.avatarLink
                        name = channelData.groupName
                        moreInfo = "\(channelData.memberIds.count) members"
                        if channelData.descriptionChannel != "" {
                            aboutInfo = channelData.descriptionChannel
                        }
                    }
                default:
                    print("No detail info")
            }
        }
    }

    //MARK: - IBOutlet
    @IBOutlet weak var aboutInfoOutlet: UILabel!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white

        configureRightButtonNavigation()
        configureTableHeaderView()
        
        aboutInfoOutlet.text = aboutInfo
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = nil
        navigationController?.navigationBar.standardAppearance = UINavigationBarAppearance()
    }
    
    //MARK: - Configure
    func configureTableHeaderView(){
        
        //transparent header
        tableView.contentInsetAdjustmentBehavior = .never
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        navigationController?.navigationBar.standardAppearance = appearance

        
        let headerTableView = HeaderTableView(frame: CGRect(x: 0, y: tableView.contentOffset.y, width: view.bounds.width, height: 300))
        headerTableView.imageLink = imageAvatar
        headerTableView.name = name
        headerTableView.moreInfo = moreInfo
        tableView.tableHeaderView = headerTableView
    }
    
    func configureRightButtonNavigation(){
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    //MARK: - Action
    @objc func editButtonTapped() {
        print("Edit button tapped!")
    }

}
