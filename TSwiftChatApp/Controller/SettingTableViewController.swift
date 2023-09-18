//
//  SettingTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 08/09/2023.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImg.layer.cornerRadius = avatarImg.frame.width / 2
        avatarImg.contentMode = .scaleToFill

        tableView.tableFooterView = UIView()
        //remove separator trên dưới
        tableView.separatorColor = tableView.backgroundColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viết vào đây thì khi màn hình được focus thì nó sẽ chạy lại còn viewDidLoad thì chỉ chạy 1 lần
        showUserInfo()
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    //MARK: - IBAction
    @IBAction func tellAFriendPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func termConditionPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        FirebaseUserListeners.shared.LogoutUserListener { error in
            if error == nil{
                let authView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthView")
                
                DispatchQueue.main.async {
                    authView.modalPresentationStyle = .fullScreen
                    self.present(authView, animated: false, completion: nil
                    )
                }
            }
        }
    }
    
    //MARK: - Update UI
    private func showUserInfo(){
        let currentUser = User.currentUser!
        if currentUser.avatar != "" {
            FireStorage.downloadImageFrom(imageUrl: currentUser.avatar) { image in
                self.avatarImg.image = image
            }
        }
        usernameLabel.text = currentUser.username
        statusLabel.text = currentUser.status
        appVersionLabel.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"
    }
    
}
