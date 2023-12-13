//
//  ChannelTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 06/12/2023.
//

import UIKit

class ChannelTableViewController: UITableViewController {
    
    //MARK: - Vars
    var listSubcribedChannelData: [Channel] = []
    var listMyChannelData: [Channel] = []
    var listSeearchChannelData: [Channel] = []
    
    var timer = Timer()
    var isSearchBarActive = false
    
    //MARK: - UI component
    let activityIndicator = UIActivityIndicatorView.create()
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - IBOutlet
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    
    //MARK: - IBAction
    @IBAction func channelSegmentAction(_ sender: Any) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = activityIndicator
        activityIndicator.start()
        setUpSearchController()
        
        loadListSubcribedChannel()
        loadListMyChannel()
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchBarActive
        ? listSeearchChannelData.count
        : channelSegmentOutlet.selectedSegmentIndex == 1
        ? listMyChannelData.count
        : listSubcribedChannelData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCell, for: indexPath) as! ChannelTableViewCell
        
        let channelCellData =
        isSearchBarActive
        ? listSeearchChannelData[indexPath.row]
        : channelSegmentOutlet.selectedSegmentIndex == 1
        ? listMyChannelData[indexPath.row]
        : listSubcribedChannelData[indexPath.row]
        
        cell.configure(channel: channelCellData)
        return cell
    }
    
    //MARK: - Table view delegate
    
    //remove channel
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return channelSegmentOutlet.selectedSegmentIndex == 0
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var removeItem = listSubcribedChannelData[indexPath.row]
            self.listSubcribedChannelData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DispatchQueue.global().async {
                removeItem.memberIds = removeItem.memberIds.filter {$0 != User.currentId}
                FirebaseChannelListeners.shared.saveChannel(channel: removeItem)
            }
        }
    }
    
    //Navigate to channel chat
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let channelData =
        isSearchBarActive
        ? listSeearchChannelData[indexPath.row]
        : channelSegmentOutlet.selectedSegmentIndex == 1
        ? listMyChannelData[indexPath.row]
        : listSubcribedChannelData[indexPath.row]
        
        let chatDetailController = ChatDetailViewController(chatRoomId: channelData.id, memberChatIds: nil)
        chatDetailController.channelData = channelData
        chatDetailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatDetailController, animated: true)
    }
    
    //MARK: - load list channel
    func loadListSubcribedChannel(){
        DispatchQueue.global().async {
            FirebaseChannelListeners.shared.fetchSubcribedChannels { allChannel in
                self.listSubcribedChannelData = allChannel
                if self.channelSegmentOutlet.selectedSegmentIndex == 0 {
                    self.tableView.reloadData()
                    self.activityIndicator.stop()
                    
                }
            }
        }
    }
    func loadListMyChannel(){
        DispatchQueue.global().async {
            FirebaseChannelListeners.shared.fetchMyChannels { allChannel in
                self.listMyChannelData = allChannel
                if self.channelSegmentOutlet.selectedSegmentIndex == 1 {
                    self.tableView.reloadData()
                    self.activityIndicator.stop()
                }
            }
        }
    }
}


//MARK: - Search Controller delegate
extension ChannelTableViewController : UISearchControllerDelegate,UISearchBarDelegate {
    func setUpSearchController(){
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchBar.placeholder = "Search Channel"
        definesPresentationContext = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if searchBar.text?.count == 0 {
                self.listSeearchChannelData = []
                self.tableView.reloadData()
                return
            }
            self.activityIndicator.start()
            FirebaseChannelListeners.shared.FindChannelFromFirebaseWith(name: searchBar.text!) { searchList in
                self.listSeearchChannelData = searchList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stop()
                }
            }
        }
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isSearchBarActive=true
        tableView.reloadData()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        timer.invalidate()
        isSearchBarActive=false
        listSeearchChannelData = []
        tableView.reloadData()
    }
    
}
