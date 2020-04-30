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
    
    @IBAction func agreeTnC(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        loadViewFromNib()
        
        let checkboxEmpty = UIImage(named: "checkbox-empty")
        let checkboxFill = UIImage(named: "checkbox-fill")
        
        checkboxButton.setImage(checkboxEmpty, for: .normal)
        checkboxButton.setImage(checkboxFill, for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
