//
//  EditProfileTableViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 10/09/2023.
//

import UIKit

class EditProfileTableViewController: UITableViewController,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    //MARK: - IBOutlet
    @IBOutlet weak var avatarImageOutlet: UIImageView!
    @IBOutlet weak var userNameTextFieldOutlet: UITextField!
    @IBOutlet weak var statusOutlet: UILabel!
    @IBOutlet weak var doneBtnOutlet: UIBarButtonItem!
    
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
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        showUserInfo()
        setupBackgroundTap()
    }
    //dissmis keyboard
    private func setupBackgroundTap(){
        let tapGetsure = UITapGestureRecognizer(target: self, action:#selector(backgroundTap))
        view.addGestureRecognizer(tapGetsure)
    }
    @objc func backgroundTap(){
        view.endEditing(false)
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO : show status
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Update UI
    private func showUserInfo(){
        let currentUser = User.currentUser!
        if currentUser.avatar != "" {
            //set image
        }
        userNameTextFieldOutlet.text = currentUser.username
        statusOutlet.text = currentUser.status
    }
    //MARK: - Save change data
    private func saveUserInfo(){
        var currentUser = User.currentUser!
        if userNameTextFieldOutlet.hasText,userNameTextFieldOutlet.text != currentUser.username {
            currentUser.username = userNameTextFieldOutlet.text!
            FirebaseUserListeners.shared.SaveUserToFirestore(currentUser)
            saveUserToLocalStorage(currentUser)
        }
        navigationController?.popViewController(animated: true)
    }
    
}

extension EditProfileTableViewController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let userPickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        avatarImageOutlet.image = userPickerImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
