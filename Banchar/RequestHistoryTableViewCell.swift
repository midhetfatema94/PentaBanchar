//
//  RequestHistoryTableViewCell.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/20/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit
import MapKit

class RequestHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var requestLocation: UILabel!
    @IBOutlet weak var requestPrice: UILabel!
    @IBOutlet weak var requestStatus: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.borderColor = UIColor.black.cgColor
        mainView.layer.borderWidth = 2.0
        mainView.layer.cornerRadius = 5.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(data: RequestViewModel) {
        requestPrice.text = data.price
        requestStatus.text = data.statusString
        requestLocation.text = data.address
        statusImage.image = data.statusImage
        locationImage.image = data.locationImage
        data.interfaceDelegate = self
    }
}

extension RequestHistoryTableViewCell: RequestVMInteractionProtocol {
    func setLocationImage(image: UIImage?) {
        locationImage.image = image
    }
}
