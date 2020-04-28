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
    @IBOutlet weak var loginButton: UIButton!
    
    let loginVM = LoginViewModel()
    
    @IBAction func login(_ sender: UIButton) {
        let params = ["email": emailTF.text ?? "", "password": passwordTF.text ?? ""]
        loginVM.login(credentials: params, completion: {[weak self] response in
            
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                if let _ = response as? [String: Any] {
                    if let newRequestVC = self?.storyboard?.instantiateViewController(identifier: "RequestHistoryViewController") as? RequestHistoryViewController {
                        self?.loginVM.getAllRequests(completion: {response in
                            if let result = response {
                                newRequestVC.requests = result
                                newRequestVC.requestTable.reloadData()
                            }
                        })
                        self?.navigationController?.pushViewController(newRequestVC, animated: true)
                    }
                } else if let errorMsg = response as? String {
                    self?.showAlert(title: "Login Error!", message: errorMsg, completion: nil)
                }
            }
        })
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        let params = ["email": emailTF.text ?? "", "password": passwordTF.text ?? ""]
        loginVM.signUp(credentials: params, completion: {[weak self] response in
            
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                if let _ = response as? [String: Any] {
                    if let newRequestVC = self?.storyboard?.instantiateViewController(identifier: "RequestHistoryViewController") as? RequestHistoryViewController {
                        self?.loginVM.getAllRequests(completion: {response in
                            if let result = response {
                                newRequestVC.requests = result
                                newRequestVC.requestTable.reloadData()
                            }
                        })
                        self?.navigationController?.pushViewController(newRequestVC, animated: true)
                    }
                } else if let errorMsg = response as? String {
                    self?.showAlert(title: "Login Error!", message: errorMsg, completion: nil)
                }
            }
        })
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

