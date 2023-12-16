//
//  AddChannelTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 07/12/2023.
//

import UIKit
import ProgressHUD

class AddChannelTableViewController: UITableViewController {
    
    //MARK: - Vars
    var avatarUrl : String? = ""
    var channelId = UUID().uuidString
    var paramToEdit : Channel?
    
    //MARK: - UI component
    lazy var alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    lazy var imagePicker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        return controller
    }()
    
    //MARK: - IBOutlet
    @IBOutlet weak var avatarImageViewOutlet: UIImageView!
    @IBOutlet weak var nameTextFieldOutlet: UITextField!
    @IBOutlet weak var descriptionTextViewOutlet: UITextView!
    
    //MARK: - IBAction
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func saveChannelBtn(_ sender: Any) {
        if nameTextFieldOutlet.text != ""{
            saveChannel()
        }
        else{
            ProgressHUD.showError("Channel name is emty!")
        }
    }
    @IBAction func deleteChannelBtn(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
        if paramToEdit != nil {
            FirebaseChannelListeners.shared.deleteChannel(paramToEdit!)
            RealmManager.shared.removeToRealm(LocalMessage.self, chatRoomId: paramToEdit!.id)
        }
    }
    
    @IBAction func addImageBtn(_ sender: Any) {
        //Action Sheet
        let option1Action = UIAlertAction(title: "Take a picture", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let option2Action = UIAlertAction(title: "Choose a picture", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        alertController.addAction(option1Action)
        alertController.addAction(option2Action)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        //MARK: - style descriptionTextViewOutlet
        descriptionTextViewOutlet.layer.borderWidth = 1
        descriptionTextViewOutlet.layer.borderColor = UIColor.gray.cgColor
        descriptionTextViewOutlet.layer.cornerRadius = 8.0
        descriptionTextViewOutlet.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        
        if paramToEdit != nil{
            configureEditChannel(channel: paramToEdit!)
        }
    }
    
    //MARK: -  Tableview method
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return paramToEdit != nil ? 2 : 1
    }
    
    //MARK: -  Save channel
    func saveChannel(){
        navigationController?.popToRootViewController(animated: true)

        let channel = Channel(id: channelId, groupName: nameTextFieldOutlet.text!, adminId: User.currentId, memberIds: [], avatarLink: avatarUrl!, descriptionChannel: descriptionTextViewOutlet.text,createDate: paramToEdit?.createDate,lastMessageDate: paramToEdit?.lastMessageDate)
        FirebaseChannelListeners.shared.saveChannel(channel: channel)
    }
    
    //MARK: - Edit channel
    func configureEditChannel(channel : Channel){
        title = "Edit channel"
        channelId = channel.id
        avatarImageViewOutlet.roundedImage(fromURL: URL(string: channel.avatarLink))
        avatarUrl = channel.avatarLink
        nameTextFieldOutlet.text = channel.groupName
        descriptionTextViewOutlet.text = channel.descriptionChannel
    }
    
}

//MARK: - UIImagePickerControllerDelegate
extension AddChannelTableViewController : UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let channelPickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            FireStorage.uploadImageFor(directory: "Avatars/_\(channelId).jpg", channelPickerImage) { imageUrl in
                self.avatarUrl = imageUrl
            }
            avatarImageViewOutlet.image = channelPickerImage.circleImage
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

