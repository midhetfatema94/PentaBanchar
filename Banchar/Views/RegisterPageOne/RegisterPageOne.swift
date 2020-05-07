//
//  RegisterPageOne.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RegisterPageOne: UIView {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet var radioButtons: [UIButton]!
    
    weak var parentDelegate: PagesCommunicationDelegate?
    
    @IBAction func selectUserType(_ sender: UIButton) {
        radioButtons.forEach {
            $0.isSelected = false
        }
        sender.isSelected = true
        
        let userTypeStr = sender.tag == 0 ? "client" : "service"
        parentDelegate?.updateVM(for: "userType", value: userTypeStr)
    }
    
    init(frame: CGRect, delegate: PagesCommunicationDelegate?) {
        super.init(frame: frame)
        loadViewFromNib()
        
        parentDelegate = delegate
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureUI() {
        
        emailTF.text = parentDelegate?.getValue(for: "email") as? String
        emailTF.delegate = self
        emailTF.tag = 0
        
        usernameTF.text = parentDelegate?.getValue(for: "username") as? String
        usernameTF.delegate = self
        usernameTF.tag = 1
        
        let radioEmptyImage = UIImage(named: "radio-empty")
        let radioFillImage = UIImage(named: "radio-fill")
        
        radioButtons.enumerated().forEach {(index, button) in
            button.setImage(radioEmptyImage, for: .normal)
            button.setImage(radioFillImage, for: .selected)
            button.tag = index
        }
        
        if let userType = parentDelegate?.getValue(for: "userType") as? String {
            if userType.lowercased() == "client" {
                radioButtons.first?.isSelected = true
            } else {
                radioButtons.last?.isSelected = true
            }
        }
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "RegisterPageOne", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            self.addSubview(view)
        }
    }
}

extension RegisterPageOne: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 0:
            parentDelegate?.updateVM(for: "email", value: string)
        case 1:
            parentDelegate?.updateVM(for: "username", value: string)
        default:
            break
        }
        return true
    }
}
