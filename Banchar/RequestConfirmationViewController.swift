//
//  RequestConfirmationViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RequestConfirmationViewController: UIViewController {

    @IBOutlet weak var requestId: UILabel!
    @IBOutlet weak var clientAddress: UILabel!
    @IBOutlet weak var clientCarModel: UILabel!
    @IBOutlet weak var carPlate: UILabel!
    @IBOutlet weak var clientProblem: UILabel!
    @IBOutlet weak var problemDescription: UITextView!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var buttonStack: UIStackView!
    
    @IBAction func acceptRequest(_ sender: UIButton) {
    }
    
    @IBAction func declineRequest(_ sender: UIButton) {
    }
    
    var requestVM: RequestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        
        guard let requestModel = requestVM else { return }
        
        if requestModel.userType == .client {
            if requestModel.dispStatus != .accepted {
                declineBtn.isHidden = false
                declineBtn.setTitle("Cancel Request", for: .normal)
                acceptBtn.isHidden = true
                buttonStack.isHidden = false
            } else {
                buttonStack.isHidden = true
            }
        } else {
            buttonStack.isHidden = requestModel.reqStatus == .completed
        }
        
        requestId.text = "Ticket Id: \(requestModel.orderId ?? "")"
        clientAddress.text = requestModel.addressStr ?? ""
        clientCarModel.text = "Car: \(requestModel.getCarModel())"
        carPlate.text = "License Plate: \(requestModel.getCarPlate())"
        clientProblem.text = "Problem: \(requestModel.problem ?? "")"
        problemDescription.text = requestModel.description
        locationImage.image = requestModel.locationImage
    }
}
