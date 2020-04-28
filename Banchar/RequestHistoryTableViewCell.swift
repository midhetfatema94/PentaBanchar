//
//  RequestHistoryTableViewCell.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/20/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RequestHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var requestLocation: UILabel!
    @IBOutlet weak var requestPrice: UILabel!
    @IBOutlet weak var requestStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(data: RequestViewModel) {
        requestPrice.text = data.price
        requestStatus.text = data.statusString
        requestLocation.text = data.address
    }
}
