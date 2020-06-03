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
    
    var requests: [RequestViewModel] = []
    
    @IBAction func newRequest(_ sender: UIBarButtonItem) {
        if let newRequestVC = self.storyboard?.instantiateViewController(identifier: "NewRequestViewController") as? NewRequestViewController {
            self.navigationController?.pushViewController(newRequestVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
