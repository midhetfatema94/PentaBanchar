//
//  RegisterPageThree.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RegisterPageThree: UIView {

    @IBOutlet weak var carTypeTF: UITextField!
    @IBOutlet weak var licenseTF: UITextField!
    @IBOutlet weak var checkboxButton: UIButton!
    
    weak var parentDelegate: PagesCommunicationDelegate?
    
    @IBAction func agreeTnC(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        parentDelegate?.updateVM(for: "agreeTnc", value: sender.isSelected)
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
        
        let checkboxEmpty = UIImage(named: "checkbox-empty")
        let checkboxFill = UIImage(named: "checkbox-fill")
        
        checkboxButton.setImage(checkboxEmpty, for: .normal)
        checkboxButton.setImage(checkboxFill, for: .selected)
        
        carTypeTF.tag = 0
        carTypeTF.delegate = self
        carTypeTF.text = parentDelegate?.getValue(for: "carModel") as? String
        
        licenseTF.tag = 1
        licenseTF.delegate = self
        licenseTF.text = parentDelegate?.getValue(for: "carPlate") as? String
        
        checkboxButton.isSelected = parentDelegate?.getValue(for: "agreeTnC") as? Bool ?? false
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "RegisterPageThree", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            self.addSubview(view)
        }
    }
}

extension RegisterPageThree: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let completeText = "\(textField.text ?? "")\(string)"
        switch textField.tag {
        case 0:
            parentDelegate?.updateVM(for: "carModel", value: completeText)
        case 1:
            parentDelegate?.updateVM(for: "carPlate", value: completeText)
        default:
            break
        }
        return true
    }
}
