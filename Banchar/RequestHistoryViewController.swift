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
    func declineRequest(requestId: String)
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
            showRequest(viewModel: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        if userVM?.userType == .client {
            barButton.image = UIImage(systemName: "plus")
        } else {
            barButton.title = "Show Requests"
        }
    }
    
    func updateTable() {
        requestTable.reloadData()
        barButton.isEnabled = requests.filter{ $0.reqStatus == .active }.count > 0 || userVM?.userType == .client
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
        if let showRequestVC = self.storyboard?.instantiateViewController(identifier: "RequestConfirmationViewController") as? RequestConfirmationViewController {
            showRequestVC.requestVM = viewModel
            showRequestVC.historyDelegate = self
            self.navigationController?.pushViewController(showRequestVC, animated: true)
        }
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
    
    func declineRequest(requestId: String) {
        requests = requests.filter { $0.orderId != requestId }
        updateTable()
    }
    
    func getUserId() -> String? {
        return userVM?.userId
    }
    
    func reloadRequestTable() {
        updateRequests()
    }
}
