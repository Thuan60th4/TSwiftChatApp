//
//  ChannelTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 06/12/2023.
//

import UIKit

class ChannelTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    
    
    //MARK: - IBActions
    @IBAction func channelSegmenAction(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCell, for: indexPath) as! ChannelTableViewCell

        // Configure the cell...

        return cell
    }


}
