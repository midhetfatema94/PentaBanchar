//
//  AverageRatingViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 7/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class AverageRatingViewController: UIViewController {
    
    @IBOutlet var starImageViews: [UIImageView]!
    @IBOutlet weak var reviewsTable: UITableView!
    
    var rateScore: Float?
    var reviews: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewsTable.tableFooterView = UIView()
        
        var count = 1
        for starImage in starImageViews {
            starImage.tag = count
            count += 1
        }
        
        let starEmptyImage = UIImage(systemName: "star")
        let starFilledImage = UIImage(systemName: "star.fill")
        let starHalfFillImage = UIImage(systemName: "star.leadinghalf.fill")
        
        for starImage in starImageViews {
            let floatStar = Float(starImage.tag)
            if floatStar <= (rateScore ?? 0) {
                starImage.image = starFilledImage
            } else if floatStar - 1 < (rateScore ?? 0) {
                starImage.image = starHalfFillImage
            } else {
                starImage.image = starEmptyImage
            }
        }
    }
}

extension AverageRatingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let reviewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? WinchReviewTableViewCell {
            reviewCell.reviewLabel.text = reviews[indexPath.row]
            return reviewCell
        }
        return UITableViewCell()
    }
}

extension AverageRatingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class WinchReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewLabel: UILabel!
}
