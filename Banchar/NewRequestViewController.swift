//
//  NewRequestViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit
import MapKit

class NewRequestViewController: UIViewController {
    
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet var issueCheckboxes: [UIButton]!
    @IBOutlet var issueReasons: [UILabel]!
    @IBOutlet weak var othersDescription: UITextField!
    @IBOutlet weak var extraDetails: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    
    let requestVM = RequestViewModel()
    let locationManager = CLLocationManager()
    var blinkingTimer: Timer?
    
    @IBAction func selectReason(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            if sender.tag == issueCheckboxes.count - 1 {
                othersDescription.isHidden = false
            } else {
                othersDescription.isHidden = true
                updateVM(for: "problem", value: issueReasons[sender.tag].text)
            }
        }
    }
    
    @IBAction func refreshLocation(_ sender: UIButton) {
        startUpdatingLocation()
    }
    
    @IBAction func requestWinch(_ sender: UIButton) {
        if requestVM.validateAllFields() {
            requestVM.newRequest(completion: {[weak self] response in
                
                guard self != nil else { return }
                
                DispatchQueue.main.async {
                    if let _ = response as? [String: Any] {
                        print("success")
                    } else if let errorMsg = response as? String {
                        self?.showAlert(title: "Login Error!", message: errorMsg, completion: nil)
                    }
                }
            })
        } else {
            showAlert(title: "Validation Error", message: "Please fill all fields correctly", completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        issueCheckboxes.enumerated().forEach{(index, element) in
            element.tag = index
            let checkboxEmpty = UIImage(named: "checkbox-empty")
            let checkboxFill = UIImage(named: "checkbox-fill")
            element.setImage(checkboxEmpty, for: .normal)
            element.setImage(checkboxFill, for: .selected)
        }
        othersDescription.tag = 1
        othersDescription.delegate = self
        addressTF.delegate = self
        extraDetails.delegate = self
    }
    
    func startUpdatingLocation() {
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        blinkingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.animateLocationButton), userInfo: nil, repeats: true)
        blinkingTimer?.fire()
    }
    
    func updateVM(for key: String, value: Any?) {
        switch key.lowercased() {
        case "address":
            requestVM.address = value as? String
        case "location":
            requestVM.location = value as? (Double, Double)
        case "problem":
            requestVM.problem = value as? String
        case "price":
            requestVM.price = value as? String
        case "description":
            requestVM.description = value as? String
        case "status":
            requestVM.statusString =  value as? String
        default:
            break
        }
    }
    
    @objc func animateLocationButton() {
        UIView.animate(withDuration: 0.5) {
            self.locationButton.alpha = self.locationButton.alpha > 0 ? 0 : 1
        }
    }
}

extension NewRequestViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let completeText = "\(textField.text ?? "")\(string)"
        switch textField.tag {
        case 0:
            updateVM(for: "address", value: completeText)
        case 1:
            updateVM(for: "problem", value: completeText)
        default:
            break
        }
        return true
    }
}

extension NewRequestViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let completeText = "\(textView.text ?? "")\(text)"
        updateVM(for: "description", value: completeText)
        return true
    }
}

extension NewRequestViewController: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        blinkingTimer?.invalidate()
        self.locationManager.stopUpdatingLocation()
        let coordinates: (Double, Double) = (newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        updateVM(for: "location", value: coordinates)
    }
}

