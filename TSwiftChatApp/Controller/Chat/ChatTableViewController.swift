//
//  ChatTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 28/09/2023.
//

import UIKit

class ChatTableViewController: UITableViewController {
    
    var listChatData: [Chat] = []
    var listSearchUser : [User] = []
    var timer = Timer()
    var isSearchBarActive = false
    
    let activityIndicator = UIActivityIndicatorView.create()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = activityIndicator
        activityIndicator.start()
        
        loadListRecentChat()
        
        setUpSearchController()
        searchController.searchBar.delegate = self
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !isSearchBarActive ? listChatData.count : listSearchUser.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCell, for: indexPath) as! ChatTableViewCell
        if !isSearchBarActive {
            cell.messageContainOutlet.isHidden = false
            cell.loadChatInfoFor(chat: listChatData[indexPath.row])
        }
        else{
            cell.messageContainOutlet.isHidden = true
            cell.loadSearchUserFor(user: listSearchUser[indexPath.row])
        }
        return cell
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Go to chat detail
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSearchBarActive
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removeItem = listChatData[indexPath.row]
            self.listChatData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DispatchQueue.global().async {
                FirebaseChatListeners.shared.removeUserFromchat(userId: User.currentId, chatRoomId: removeItem.chatRoomId, newMemberIds: removeItem.memberIds.filter{$0 != User.currentId})
            }
        }
    }
    
    
    
    
    
    //MARK: - Load list caht

    func loadListRecentChat(){
        FirebaseChatListeners.shared.fetchNewChat { allchat in
            if !allchat.isEmpty {
                self.listChatData = Array(allchat.values).sorted {
                    $0.date! >  $1.date!
                }
                self.tableView.reloadData()
            }
            self.activityIndicator.stop()
        }
    }
}

//MARK: - Search Controller delegate
extension ChatTableViewController : UISearchBarDelegate {
    
    func setUpSearchController(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchBar.placeholder = "Search User"
        definesPresentationContext = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearchBarActive=true
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if searchBar.text?.count == 0 {
                self.listSearchUser = []
                self.tableView.reloadData()
                return
            }
            FirebaseUserListeners.shared.FindUserFromFirebaseWith(name: searchBar.text!) { listUser in
                self.listSearchUser = listUser
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        timer.invalidate()
        isSearchBarActive=false
        self.listSearchUser = []
        tableView.reloadData()
    }
}
