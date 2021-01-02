//
//  PaymentViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 6/30/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var paymentCompletedBtn: RoundedRectangleButton!
    @IBAction func paymentCompleted(_ sender: UIButton) {
        if let ratingVC = self.storyboard?.instantiateViewController(identifier: "RatingViewController") as? RatingViewController {
            self.navigationController?.pushViewController(ratingVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}
