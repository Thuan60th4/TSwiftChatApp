//
//  StatusTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 22/09/2023.
//

import UIKit

class StatusTableViewController: UITableViewController {
    
    var statusList : [String] = []
    var currentUser = User.currentUser!
    var currentStatus = User.currentUser!.status
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStatusList()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusReusableCell", for: indexPath)
        let statusText = statusList[indexPath.row]
        cell.textLabel?.text = statusText
        cell.accessoryType = currentStatus == statusText ? .checkmark : .none
        return cell
    }
    
    //MARK: - Tableview delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateCellCheckFor(indexPath)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //load status
    func loadStatusList(){
        statusList = UserDefaults.standard.stringArray(forKey: KSTATUSLIST) ?? []
        tableView.reloadData()
    }
    
    //update status {
    func updateCellCheckFor(_ indexPath : IndexPath){
        currentStatus = statusList[indexPath.row]
        DispatchQueue(label: "update status to store").async {
            self.currentUser.status = self.currentStatus
            FirebaseUserListeners.shared.SaveUserToFirestore(self.currentUser)
            saveUserToLocalStorage(self.currentUser)
        }
    }
    
}
