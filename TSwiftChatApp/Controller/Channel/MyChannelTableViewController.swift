//
//  MyChannelTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 07/12/2023.
//

import UIKit

class MyChannelTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCell, for: indexPath)

        // Configure the cell...

        return cell
    }
}
