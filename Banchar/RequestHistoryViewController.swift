//
//  RequestHistoryViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

protocol RequestHistoryCommunicationProtocol: class {
    func reloadRequestTable()
    func getUserId() -> String?
    func declineRequest(request: RequestViewModel)
    func updateRequest(requestId: String, updatedRequest: RequestViewModel)
}

class RequestHistoryViewController: UIViewController {
    
    @IBOutlet weak var requestTable: UITableView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    var requests: [RequestViewModel] = []
    var userVM: LoginViewModel?
    
    @IBAction func newRequest(_ sender: UIBarButtonItem) {
        if userVM?.userType == .client {
            if let newRequestVC = self.storyboard?.instantiateViewController(identifier: "NewRequestViewController") as? NewRequestViewController {
                newRequestVC.requestVM.clientUserId = userVM?.userId ?? ""
                newRequestVC.historyDelegate = self
                self.navigationController?.pushViewController(newRequestVC, animated: true)
            }
        } else {
            if let reviewsVC = self.storyboard?.instantiateViewController(identifier: "AverageRatingViewController") as? AverageRatingViewController {
                reviewsVC.rateScore = self.getAverageRating()
                reviewsVC.reviews = self.getAllReviews()
                self.navigationController?.pushViewController(reviewsVC, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        requestTable.tableFooterView = UIView()
    }
    
    func configureUI() {
        if userVM?.userType == .client {
            barButton.image = UIImage(systemName: "plus")
        } else {
            barButton.title = "Show Reviews"
        }
        barButton.isAccessibilityElement = true
        barButton.accessibilityIdentifier = "requestButton"
    }
    
    func updateTable() {
        requestTable.reloadData()
    }
    
    func updateRequests() {
        userVM?.getAllRequests(completion: {[weak self] response in
            
            guard self != nil else { return }
            
            if let result = response {
                self?.requests = result
                DispatchQueue.main.async {
                    self?.updateTable()
                }
            }
        })
    }
    
    func showRequest(viewModel: RequestViewModel?) {
        if viewModel?.reqStatus == .active && userVM?.userType == .client {
            if let serviceTrackingVC = self.storyboard?.instantiateViewController(identifier: "ServiceVehicleTrackerViewController") as? ServiceVehicleTrackerViewController {
                serviceTrackingVC.requestVM = viewModel
                serviceTrackingVC.historyDelegate = self
                self.navigationController?.pushViewController(serviceTrackingVC, animated: true)
            }
        } else {
            if let showRequestVC = self.storyboard?.instantiateViewController(identifier: "RequestConfirmationViewController") as? RequestConfirmationViewController {
                showRequestVC.requestVM = viewModel
                showRequestVC.historyDelegate = self
                self.navigationController?.pushViewController(showRequestVC, animated: true)
            }
        }
    }
    
    func getAverageRating() -> Float {
        var score: Float = 0
        var ratingCount: Float = 0
        self.requests.forEach {
            if let ratingNotNil = $0.rating {
                score += ratingNotNil
                ratingCount += 1
            }
        }
        return score/ratingCount
    }
    
    func getAllReviews() -> [String] {
        var reviews: [String] = []
        self.requests.forEach {
            reviews.append($0.review ?? "")
        }
        return reviews
    }
}

extension RequestHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let orderCell = tableView.dequeueReusableCell(withIdentifier: "requestCell") as? RequestHistoryTableViewCell {
            requests[indexPath.row].userType = userVM?.userType
            orderCell.configure(data: requests[indexPath.row])
            orderCell.selectionStyle = .none
            return orderCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
}

extension RequestHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showRequest(viewModel: requests[indexPath.row])
    }
}

extension RequestHistoryViewController: RequestHistoryCommunicationProtocol {
    func updateRequest(requestId: String, updatedRequest: RequestViewModel) {
        requests = requests.map {
            if $0.orderId == requestId {
                return updatedRequest
            }
            return $0
        }
        updateTable()
    }
    
    func declineRequest(request: RequestViewModel) {
        requests = requests.filter { $0.orderId != request.orderId }
        updateTable()
    }
    
    func getUserId() -> String? {
        return userVM?.userId
    }
    
    func reloadRequestTable() {
        updateRequests()
    }
}
