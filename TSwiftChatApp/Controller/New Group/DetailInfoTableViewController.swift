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
    var channelInfo: Channel?
    var listMembers: [User] = []
    
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
                        channelInfo = channelData
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
    var headerTableView: HeaderTableView!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableHeaderView()
        if channelInfo?.adminId == User.currentId{
            configureRightButtonNavigation()
        }
        aboutInfoOutlet.text = aboutInfo
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        loadMembers()        
    }
    
    //MARK: - Configure
    func configureTableHeaderView(){
        //transparent header
        tableView.contentInsetAdjustmentBehavior = .never
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        navigationItem.standardAppearance = appearance
        
        headerTableView = HeaderTableView(frame: CGRect(x: 0, y: tableView.contentOffset.y, width: view.bounds.width, height: 300))
        headerTableView.imageLink = imageAvatar
        headerTableView.name = name
        headerTableView.moreInfo = moreInfo
        tableView.tableHeaderView = headerTableView
    }
    
    func configureRightButtonNavigation(){
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    //MARK: - Tableview dataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listMembers.isEmpty ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : listMembers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
        let user = listMembers[indexPath.row]
        var name = user.username
        if user.id == User.currentId{
            name = "You"
            cell.isUserInteractionEnabled = false
        }
        cell.configure(avatarLink: user.avatar, name: name)
        return cell
        
    }
    
    //Phải có cái này ms insertRow đc
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : 55
    }
    //MARK: - Tableview delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Action Sheet
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let option1Action = UIAlertAction(title: "Message", style: .default) { (action) in
            self.navigateToChat(indexPath)
        }
        alertController.addAction(option1Action)
        if channelInfo?.adminId == User.currentId{
            let option2Action = UIAlertAction(title: "Remove", style: .default) { (action) in
                self.removeUser(at: indexPath)
            }
            option2Action.setValue(UIColor.red, forKey: "titleTextColor")
            alertController.addAction(option2Action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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
    
    func navigateToChat(_ indexPath: IndexPath){
        let userInfo = listMembers[indexPath.row]
        let memberIds = [userInfo.id,User.currentId]
        let chatDetailController = ChatDetailViewController(chatRoomId: getChatRoomIdFrom(memberIds:memberIds), memberChatIds: memberIds)
        chatDetailController.guestData = userInfo
        navigationController?.pushViewController(chatDetailController, animated: true)
    }
    
    func removeUser(at indexPath: IndexPath){
        if channelInfo == nil {return}
        let userRemove = listMembers[indexPath.row]
        channelInfo!.memberIds = channelInfo!.memberIds.filter {$0 != userRemove.id}
        listMembers.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if listMembers.isEmpty{
            tableView.deleteSections(IndexSet(integer: 1), with: .automatic)
        }
        headerTableView.moreInfo = "\(channelInfo!.memberIds.count) members"
        tableView.endUpdates()
        DispatchQueue.global().async {
            FirebaseChannelListeners.shared.saveChannel(channel: self.channelInfo!)
        }
    }
    func loadMembers(){
        if !(channelInfo?.memberIds.isEmpty ?? true){
            FirebaseUserListeners.shared.FetchListUserIDFromFirebase(userIds: channelInfo!.memberIds) { listUser in
                self.listMembers = listUser
                if listUser.isEmpty {return}
                
                self.tableView.beginUpdates()
                var listIndexpath:[IndexPath] = []
                for i in 0 ..< listUser.count{
                    listIndexpath.append(IndexPath(row: i, section: 1))
                }
                self.tableView.insertSections(IndexSet(integer: 1), with: .automatic)
                self.tableView.insertRows(at: listIndexpath, with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
}
