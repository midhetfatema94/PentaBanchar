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
    
    @IBAction func selectUserType(_ sender: UIButton) {
        radioButtons.forEach {
            $0.isSelected = false
        }
        sender.isSelected = true
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        
        let radioEmptyImage = UIImage(named: "radio-empty")
        let radioFillImage = UIImage(named: "radio-fill")
        
        radioButtons.forEach {
            $0.setImage(radioEmptyImage, for: .normal)
            $0.setImage(radioFillImage, for: .selected)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
