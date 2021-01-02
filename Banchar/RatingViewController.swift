//
//  RatingViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 6/30/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {

    @IBOutlet weak var starStackView: UIStackView!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var reviewTF: UITextView!
    @IBOutlet weak var submitBtn: RoundedRectangleButton!
    
    var requestVM: RequestViewModel?
    
    weak var historyDelegate: RequestHistoryCommunicationProtocol?
    
    @IBAction func rateButtonClicked(_ sender: UIButton) {
        starButtons.forEach { $0.isSelected = false }
        for i in 0 ..< sender.tag {
            starButtons[i].isSelected = true
            requestVM?.rating = Float(starButtons[i].tag)
        }
    }
    
    @IBAction func submitRating(_ sender: UIButton) {
        requestVM?.review = reviewTF.text
        requestVM?.submitRating(completion: {[weak self] errorStr in
            
            guard self != nil else { return }
            
            if let error = errorStr as? String {
                self?.showAlert(title: "Submission Failure", message: error, completion: nil)
            } else {
                if let requestModel = self?.requestVM {
                    self?.historyDelegate?.updateRequest(requestId: requestModel.orderId ?? "", updatedRequest: requestModel)
                }
                if let controllerStack = self?.navigationController?.viewControllers {
                    for vc in controllerStack {
                        if let requestHistoryVC = vc as? RequestHistoryViewController {
                            self?.navigationController?.popToViewController(requestHistoryVC, animated: true)
                        }
                    }
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let starEmptyImage = UIImage(named: "star")
        let starFilledImage = UIImage(named: "star_fill")
        
        for (i, starBtn) in starButtons.enumerated() {
            starBtn.tag = i + 1
            starBtn.setImage(starEmptyImage, for: .normal)
            starBtn.setImage(starFilledImage, for: .selected)
        }
    }
}
