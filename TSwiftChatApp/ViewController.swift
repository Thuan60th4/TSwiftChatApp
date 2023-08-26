//
//  ViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 22/08/2023.
//

import UIKit

class ViewController: UIViewController {
    
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
    @IBOutlet weak var resendPasswBtnOutlet: UIButton!
    @IBOutlet weak var loginBtnOutlet: UIButton!
    @IBOutlet weak var signUpBtnOutlet: UIButton!
    
    
    //MARK: - Action
    @IBAction func forgotPasswBtnPressed(_ sender: Any) {
    }
    
    @IBAction func resendPasswBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        isLogin = !isLogin
    }
    
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFieldDelegate()
        updateUIFor(login: isLogin)
        setupBackgroundTap()
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
    //dissmis keyboard
    private func setupBackgroundTap(){
        let tapGetsure = UITapGestureRecognizer(target: self, action:#selector(backgroundTap))
        view.addGestureRecognizer(tapGetsure)
    }
    @objc func backgroundTap(){
        //kết thúc chỉnh sửa ở view hiện tại là nó sẽ tự tắt bàn phím
        view.endEditing(false)
    }
    
    //MARK: - Animation
    private func updateUIFor(login : Bool){
        loginBtnOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        
        signUpBtnOutlet.setTitle(login ? "Create a new account?" : "Log into existing account", for: .normal)
        
        UIView.animate(withDuration: 0.5) {
            self.confirmPasswordLabelOutlet.isHidden = login
            self.confirmPasswordTextFieldOutlet.isHidden = login
            self.confirmPasswordUnderlineOutlet.isHidden = login
            
        }
        
    }
    
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
    
    
    
}

