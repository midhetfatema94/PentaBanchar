//
//  RegisterPageTwo.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RegisterPageTwo: UIView {

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var repeatPasswordTF: UITextField!
    
    weak var parentDelegate: PagesCommunicationDelegate?
    
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
        passwordTF.text = parentDelegate?.getValue(for: "password") as? String
        passwordTF.tag = 0
        passwordTF.delegate = self
        
        repeatPasswordTF.text = parentDelegate?.getValue(for: "repeat") as? String
        repeatPasswordTF.tag = 1
        repeatPasswordTF.delegate = self
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "RegisterPageTwo", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            self.addSubview(view)
        }
    }
}

extension RegisterPageTwo: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 0:
            parentDelegate?.updateVM(for: "password", value: string)
        case 1:
            parentDelegate?.updateVM(for: "repeat", value: string)
        default:
            break
        }
        return true
    }
}
