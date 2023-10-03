//
//  ChatTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 28/09/2023.
//

import UIKit

class ChatTableViewController: UITableViewController {
    
    let activityIndicator = UIActivityIndicatorView.create()
    var listChatData: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = activityIndicator
        activityIndicator.start()
        loadListRecentChat()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listChatData.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCell, for: indexPath) as! ChatTableViewCell
        cell.loadChatInfoFor(chat: listChatData[indexPath.row])
        return cell
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Go to chat detail
    }
    
    func loadListRecentChat(){
        FirebaseChatListeners.shared.fetchNewChat { allchat in
            if !allchat.isEmpty {
                self.listChatData = Array(allchat.values)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator.stop()
            }
        }
    }
    
    
}
