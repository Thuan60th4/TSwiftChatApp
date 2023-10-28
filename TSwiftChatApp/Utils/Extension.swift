//
//  Extension.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 20/09/2023.
//
import UIKit
import SDWebImage


//MARK: - UIImage Extension
extension UIImage {
    //circle image
    var circleImage: UIImage? {
        let minSize = min(size.width, size.height)
        let cornerRadius = minSize / 2.0
        let imageSize = CGSize(width: minSize, height: minSize)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let imageRect = CGRect(origin: .zero, size: imageSize)
        UIBezierPath(roundedRect: imageRect, cornerRadius: cornerRadius).addClip()
        //self trong extention là cái đối tượng mà gọi property này
        self.draw(in: imageRect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage
    }
}

//MARK: - UIImageView Extension
extension UIImageView {
    func roundedImage(fromURL url: URL?,placeholderImage : UIImage? = nil) {
        self.sd_setImage(with: url,placeholderImage: placeholderImage
        ) { [weak self] (image, _, _, _) in
            if let roundedImage = image?.circleImage {
                self?.image = roundedImage
            }
        }
    }
}

//MARK: - UITextField Extension
extension UITextField {
    func paddingForTextField(horizontal : Int, vertical: Int){
        let paddingView = UIView.init(frame: CGRect(x: 0, y: 0, width: horizontal, height: vertical))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

//MARK: - UIViewController Extension
extension UIViewController {
    //Keyboard hiden when tap background
    func hideKeyboardWhenTapArround (){
        let tapGetsure = UITapGestureRecognizer(target: self, action:#selector(backgroundTap))
        tapGetsure.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGetsure)
    }
    @objc func backgroundTap(){
        view.endEditing(true)
    }
}

//MARK: - Date Extension
extension Date {
    func longDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    func getTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
}

//MARK: - UIActivityIndicatorView Extension
extension UIActivityIndicatorView {
    static func create() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
//        activityIndicator.frame = CGRect(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        return activityIndicator
    }
    func start() {
        self.startAnimating()
        self.isHidden = false
    }
    func stop() {
        self.stopAnimating()
        self.isHidden = true
    }
}
