//
//  LoginViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 3/26/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var bancharImage: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: RoundedRectangleButton!
    
    let loginVM = LoginViewModel()
    
    @IBAction func login(_ sender: UIButton) {
        let params = ["email": emailTF.text ?? "", "password": passwordTF.text ?? ""]
        loginVM.login(credentials: params, completion: {[weak self] response in
            
            guard self != nil else { return }
            
            DispatchQueue.main.async {
                if let _ = response as? [String: Any] {
                    self?.loginVM.userLoggedInSuccess(vc: self)
                } else if let errorMsg = response as? String {
                    self?.showAlert(title: "Login Error!", message: errorMsg, completion: nil)
                }
            }
        })
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        let params = ["email": emailTF.text ?? "", "password": passwordTF.text ?? ""]
        loginVM.setupViewModel(details: params)
        if let newRequestVC = self.storyboard?.instantiateViewController(identifier: "RegisterUserViewController") as? RegisterUserViewController {
            newRequestVC.loginVM = loginVM
            self.navigationController?.pushViewController(newRequestVC, animated: true)
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

class RoundedRectangleButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setStyle()
    }
    
    func setStyle() {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        if let title = self.currentTitle, !title.isEmpty {
            self.setTitle("    \(title)    ", for: .normal)
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle("    \(title ?? "")    ", for: state)
    }
}

