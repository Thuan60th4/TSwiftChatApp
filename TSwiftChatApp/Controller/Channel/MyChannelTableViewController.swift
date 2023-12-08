//
//  MyChannelTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 07/12/2023.
//

import UIKit

class MyChannelTableViewController: UITableViewController {
    
    //MARK: - Vars
    var listMyChannelData: [Channel] = []
    
    //MARK: - UI component
    let activityIndicator = UIActivityIndicatorView.create()
    
    //MARK: - IBAction
    @IBAction func addNewChannelBtn(_ sender: Any) {
       performSegue(withIdentifier: "myChannelToAddChannel", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = activityIndicator
        activityIndicator.start()
        
        loadMyListChannel()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listMyChannelData.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCell, for: indexPath) as! ChannelTableViewCell
        cell.configure(channel: listMyChannelData[indexPath.row])        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "myChannelToAddChannel", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    //MARK: - load my list channel
    func loadMyListChannel(){
        FirebaseChannelListeners.shared.fetchMyChannels { allChannel in
            if !allChannel.isEmpty{
                self.listMyChannelData = allChannel
                self.tableView.reloadData()
            }
            self.activityIndicator.stop()
 
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myChannelToAddChannel"{
            let destinationViewController = segue.destination as! AddChannelTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                //hoặc dùng sender ở đây thì perform ở trên chuyền data vào
                destinationViewController.paramToEdit = listMyChannelData[indexPath.row]
            }
        }
    }
}
