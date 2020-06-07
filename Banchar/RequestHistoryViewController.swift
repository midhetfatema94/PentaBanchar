//
//  RequestHistoryViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RequestHistoryViewController: UIViewController {
    
    @IBOutlet weak var requestTable: UITableView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    var requests: [RequestViewModel] = []
    var isClient = true
    
    @IBAction func newRequest(_ sender: UIBarButtonItem) {
        if isClient {
            if let newRequestVC = self.storyboard?.instantiateViewController(identifier: "NewRequestViewController") as? NewRequestViewController {
                self.navigationController?.pushViewController(newRequestVC, animated: true)
            }
        } else {
            if let showRequestVC = self.storyboard?.instantiateViewController(identifier: "RequestConfirmationViewController") as? RequestConfirmationViewController {
                showRequestVC.requestVM = requests.first
                self.navigationController?.pushViewController(showRequestVC, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        if isClient {
            barButton.image = UIImage(systemName: "plus")
        } else {
            barButton.title = "Show Requests"
        }
    }
}

extension RequestHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let orderCell = tableView.dequeueReusableCell(withIdentifier: "requestCell") as? RequestHistoryTableViewCell {
            orderCell.configure(data: requests[indexPath.row])
            return orderCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
}
