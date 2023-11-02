//
//  EditProfileTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 10/09/2023.
//

import UIKit

let borderRadius = 10.0

class EditProfileTableViewController: UITableViewController,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var avatarUrl : String? = ""
    
    //MARK: - IBOutlet
    @IBOutlet weak var avatarImageOutlet: UIImageView!
    @IBOutlet weak var userNameTextFieldOutlet: UITextField!
    @IBOutlet weak var bioTextViewOutlet: UITextView!
    @IBOutlet weak var statusOutlet: UILabel!
    @IBOutlet weak var statusViewOutlet: UIView!
    
    //MARK: - IBAction
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        saveUserInfo()
    }
    @IBAction func setNewPhotoPressed(_ sender: UIButton) {
        //Action Sheet
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let option1Action = UIAlertAction(title: "Take a picture", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let option2Action = UIAlertAction(title: "Choose a picture", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Bạn đã chọn Hủy")
        }
        
        alertController.addAction(option1Action)
        alertController.addAction(option2Action)
        alertController.addAction(cancelAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - View lifcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bioTextViewOutlet.delegate = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        //extention inherit UIViewController
        self.hideKeyboardWhenTapArround()
        
        //style textInput
        style()
        //Auto resizing cell
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  section == 0 ? CGFloat.leastNormalMagnitude : 5
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            performSegue(withIdentifier: "goToStatusList", sender: self)
        }
    }
    
    //MARK: - load user info
    private func showUserInfo(){
        let currentUser = User.currentUser!
        if currentUser.avatar != "" {
            avatarImageOutlet.roundedImage(fromURL: URL(string: currentUser.avatar))
        }
        userNameTextFieldOutlet.text = currentUser.username
        bioTextViewOutlet.text = currentUser.description
        statusOutlet.text = currentUser.status
    }
    
    //MARK: - Save change data
    private func saveUserInfo(){
        var currentUser = User.currentUser!
        
        if avatarUrl != ""{
            currentUser.avatar = avatarUrl!
            //save image to local base on userId
            //            if let imageData = avatarImageOutlet.image?.jpegData(compressionQuality: 1) as NSData? {
            //                FireStorage.saveFileLocally(fileData: imageData, fileName: User.currentId)
            //            }
        }
        if userNameTextFieldOutlet.hasText,userNameTextFieldOutlet.text != currentUser.username {
            currentUser.username = userNameTextFieldOutlet.text!
        }
        
        if bioTextViewOutlet.hasText,bioTextViewOutlet.text != currentUser.description {
            currentUser.description = bioTextViewOutlet.text!
        }
        
        FirebaseUserListeners.shared.SaveUserToFirestore(currentUser)
        saveUserToLocalStorage(currentUser)
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - UIImagePickerControllerDelegate
extension EditProfileTableViewController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if  let userPickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            FireStorage.uploadImageFor(directory: "Avatars/_\(User.currentId).jpg", userPickerImage) { imageUrl in
                self.avatarUrl = imageUrl
            }
            avatarImageOutlet.image = userPickerImage.circleImage
            imagePicker.dismiss(animated: true, completion: nil)
        }
        
    }
}

//MARK: - UITextViewDelegate auto resize height when type bio( disable scroll property in interface builder)
extension EditProfileTableViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

//MARK: - Style
extension EditProfileTableViewController{
    func style(){
        //padding
        bioTextViewOutlet.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        userNameTextFieldOutlet.paddingForTextField(horizontal: 10, vertical: 5)
        //border
        statusViewOutlet.layer.cornerRadius = borderRadius
        bioTextViewOutlet.layer.cornerRadius = borderRadius
        userNameTextFieldOutlet.layer.cornerRadius = borderRadius
        
    }
}
