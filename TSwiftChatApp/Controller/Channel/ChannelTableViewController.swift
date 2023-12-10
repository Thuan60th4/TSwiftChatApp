//
//  ChannelTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 06/12/2023.
//

import UIKit

class ChannelTableViewController: UITableViewController {

    //MARK: - Vars
    var listChannelData: [Channel] = []
    
    //MARK: - UI component
    let activityIndicator = UIActivityIndicatorView.create()
    
    //MARK: - IBAction
    @IBAction func channelSegmenAction(_ sender: Any) {
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = activityIndicator
        activityIndicator.start()
        loadListChannel()

    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listChannelData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCell, for: indexPath) as! ChannelTableViewCell
        cell.configure(channel: listChannelData[indexPath.row])

        return cell
    }
    //MARK: - load list channel
    func loadListChannel(){
        FirebaseChannelListeners.shared.fetchSubcribedChannels { allChannel in
            if !allChannel.isEmpty{
                self.listChannelData = allChannel
                self.tableView.reloadData()
            }
            self.activityIndicator.stop()
        }
    }
}
