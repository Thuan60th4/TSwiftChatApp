//
//  ViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 22/08/2023.
//

import UIKit
import ProgressHUD

class AuthViewController: UIViewController {
    
    var isLogin = true {
        didSet{
            updateUIFor(login: isLogin)
        }
    }
    
    //MARK: - UI
    //Email UI
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var emailTextFieldOutlet: UITextField!
    
    // Password UI
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var passwordTextFieldOutlet: UITextField!
    
    //Confirm password UI
    @IBOutlet weak var confirmPasswordLabelOutlet: UILabel!
    @IBOutlet weak var confirmPasswordTextFieldOutlet: UITextField!
    @IBOutlet var confirmPasswordUnderlineOutlet: UIView!
    
    
    //Btn UI
    @IBOutlet weak var loginBtnOutlet: UIButton!
    @IBOutlet weak var signUpBtnOutlet: UIButton!
    
    
    //MARK: - Action
    @IBAction func forgotPasswBtnPressed(_ sender: Any) {
        FirebaseUserListeners.shared.ResetPasswordWith(email: emailTextFieldOutlet.text ?? "") { error in
            if error == nil {
                ProgressHUD.showSucceed("Please check your email to reset password", interaction: false, delay: 1)
            }
            else{
                ProgressHUD.showFailed(error)
            }
        }
    }

    @IBAction func loginBtnPressed(_ sender: UIButton) {
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
        isLogin ? loginUser() : registerUser()
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        isLogin = !isLogin
    }
    
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFieldDelegate()
        updateUIFor(login: isLogin)
        //extention inherit UIViewController
        self.hideKeyboardWhenTapArround()
    }
    
    //MARK: - Set up
    private func setupTextFieldDelegate(){
        // Khi bạn thêm target cho emailTextFieldOutlet, bạn đang nói với emailTextFieldOutlet rằng khi giá trị của nó thay đổi, hãy gọi hàm textFieldDidChange với tham số textField là emailTextFieldOutlet.
        emailTextFieldOutlet.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextFieldOutlet.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmPasswordTextFieldOutlet.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(textField : UITextField ){
        updatePlaceholderLabels(textField)
    }
    
    //MARK: - Animation
    private func updatePlaceholderLabels(_ textField : UITextField){
        switch textField {
            case emailTextFieldOutlet:
                emailLabelOutlet.text = emailTextFieldOutlet.hasText ? "Email" : ""
            case passwordTextFieldOutlet:
                passwordLabelOutlet.text = passwordTextFieldOutlet.hasText ? "Password" : ""
            default:
                confirmPasswordLabelOutlet.text = confirmPasswordTextFieldOutlet.hasText ? "Confirm password" : ""
        }
    }
    
    private func updateUIFor(login : Bool){
        loginBtnOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        
        signUpBtnOutlet.setTitle(login ? "Create a new account?" : "Log into existing account", for: .normal)
        
        UIView.animate(withDuration: 0.5) {
            self.confirmPasswordLabelOutlet.isHidden = login
            self.confirmPasswordTextFieldOutlet.isHidden = login
            self.confirmPasswordUnderlineOutlet.isHidden = login
            
        }
        
    }
    
    //MARK: - Action handle
    //Login btn action
    private func loginUser(){
        if !isValidationData(type: "Login") {
            return
        }
        FirebaseUserListeners.shared.LoginUserWith(email: emailTextFieldOutlet.text!, password: passwordLabelOutlet.text!) { error, verified in
            if error == nil{
                if verified {
                    self.goToApp()
                }
                else {
                    ProgressHUD.showFailed("Please verify your email")
                }
            }
            else {
                ProgressHUD.showFailed(error)
            }
        }
    }
    
    //Register btn action
    private func registerUser(){
        if !isValidationData(type: "Registaion") {
            return
        }
        FirebaseUserListeners.shared.RegisterUserWith(email: emailTextFieldOutlet.text!, password: passwordLabelOutlet.text!) { error in
            if error == nil {
                ProgressHUD.showSucceed("Verification email sent", interaction: false, delay: 1)
            }
            else {
                ProgressHUD.showFailed(error)
            }
        }
    }
    
    private func goToApp(){
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as! UITabBarController
        
        //nếu ui của chúng ta đc tạo từ code và ko liên quan gì đến main.storyboard thì chúng ta có thể khởi tạo trực tiếp ví dụ chatDetailViewController() còn nếu liên quan đến main.storyboard thì phải khởi tạo như trên
        
        //dùng push,pop các thứ là thêm,xoá 1 viewController khỏi stack còn present là hiển thỉ 1 màn mới lên thôi ko liên quan gì đến stack
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    //MARK: - Validate input
   private func isValidationData(type : String) -> Bool{
        switch type {
            case "Registaion","Login":
                if !isValidEmail(emailTextFieldOutlet.text ?? "")
                {
                    ProgressHUD.showFailed("Invalid email")
                    return false
                }
               else if !passwordTextFieldOutlet.hasText {
                    ProgressHUD.showFailed("Please type your password")
                    return false
                }
                else if !confirmPasswordTextFieldOutlet.hasText,type == "Registaion" {
                    ProgressHUD.showFailed("Please confirm your password")
                    return false
                }
                else if passwordTextFieldOutlet.text != confirmPasswordTextFieldOutlet.text,type == "Registaion" {
                    ProgressHUD.showFailed("Password not match")
                    return false
                }
                return true
            default :
                return false
        }
    }
    
    
}

