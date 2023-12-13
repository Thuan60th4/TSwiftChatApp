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
    var adminlId : String?
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
                        adminlId = channelData.adminId
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
        configureTableHeaderView()
        if adminlId == User.currentId{
            configureRightButtonNavigation()
        }
        aboutInfoOutlet.text = aboutInfo
    }
    
    //MARK: - Configure
    func configureTableHeaderView(){
        //transparent header
        tableView.contentInsetAdjustmentBehavior = .never
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        navigationItem.standardAppearance = appearance

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
       let editChannelView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addChannelView") as! AddChannelTableViewController
        switch detailInfo {
            case .channel(let channelData):
                editChannelView.paramToEdit = channelData
            default:
                return
        }
        navigationController?.pushViewController(editChannelView, animated: true)
    }

}
