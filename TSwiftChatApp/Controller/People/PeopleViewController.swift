//
//  PeopleViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 24/09/2023.
//

import UIKit

class PeopleViewController: UIViewController {
    
    var listUser : [User] = []
    
    //MARK: - IBOutelets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var offlineView: UIStackView!
    
    @IBAction func turnOnlineStatusBtn(_ sender: Any) {
        tableView.isHidden = false
        offlineView.isHidden = true
        DispatchQueue.global().async {
            var currentUser = User.currentUser!
            currentUser.status = Status.Online.rawValue
            FirebaseUserListeners.shared.SaveUserToFirestore(currentUser)
            saveUserToLocalStorage(currentUser)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupResfreshControl()
        tableView.dataSource = self
        tableView.delegate = self
        loadListUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isOnline = User.currentUser?.status == Status.Online.rawValue
        tableView.isHidden = !isOnline
        offlineView.isHidden = isOnline
    }
    
    //MARK: - SetUp RefreshControl
    func setupResfreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    @objc private func refreshData(_ sender: UIRefreshControl) {
        //refresh user list
        loadListUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sender.endRefreshing()
        }
    }
    
    //Load list user
    func loadListUser(){
        FirebaseUserListeners.shared.FetchListOnlineUserFromFirebase { userArray in
            self.listUser = userArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

// MARK: - Table view data source
extension PeopleViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUser.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: peopleCell, for: indexPath) as! PeopleTableViewCell
        cell.loadGuestInfo(user: listUser[indexPath.row])
        return cell
    }
}

//MARK: - Table view delegate
extension PeopleViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = listUser[indexPath.row]
        let memberIds = [userInfo.id,User.currentId]
        //Go to chat
        let chatDetailController = ChatDetailViewController(chatRoomId: getChatRoomIdFrom(memberIds:memberIds), memberChatIds: memberIds)
        chatDetailController.guestData = userInfo
        chatDetailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatDetailController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

