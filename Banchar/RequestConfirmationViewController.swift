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
    
    @IBAction func acceptRequest(_ sender: UIButton) {
    }
    
    @IBAction func declineRequest(_ sender: UIButton) {
    }
    
    var requestVM: RequestViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        requestId.text = "Ticket Id: \(requestVM.orderId ?? "")"
        clientAddress.text = requestVM.addressStr ?? ""
        clientCarModel.text = "Car: \(requestVM.getCarModel())"
        carPlate.text = "License Plate: \(requestVM.getCarPlate())"
        clientProblem.text = "Problem: \(requestVM.problem ?? "")"
        problemDescription.text = requestVM.description
        locationImage.image = requestVM.locationImage
    }
}
