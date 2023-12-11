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
            FirebaseChannelListeners.shared.FindChannelFromFirebaseWith(name: searchBar.text!) { searchList in
                self.listSeearchChannelData = searchList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
