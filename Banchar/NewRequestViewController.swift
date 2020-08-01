//
//  NewRequestViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NewRequestViewController: UIViewController {
    
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet var issueCheckboxes: [UIButton]!
    @IBOutlet var issueReasons: [UILabel]!
    @IBOutlet weak var othersDescription: UITextField!
    @IBOutlet weak var extraDetails: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    let requestVM = RequestViewModel()
    let locationManager = CLLocationManager()
    var blinkingTimer: Timer?
    
    weak var historyDelegate: RequestHistoryCommunicationProtocol?
    
    @IBAction func selectReason(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.tag == issueCheckboxes.count - 1 {
            othersDescription.isHidden = !sender.isSelected
            if !sender.isSelected {
                updateVM(for: "problem", value: "Others: \(othersDescription.text ?? "")", remove: true)
            }
        } else {
            updateVM(for: "problem", value: issueReasons[sender.tag].text, remove: !sender.isSelected)
        }
    }
    
    @IBAction func refreshLocation(_ sender: UIButton) {
        startUpdatingLocation()
    }
    
    @IBAction func requestWinch(_ sender: UIButton) {
        if !othersDescription.isHidden && !(requestVM.problem?.contains("Others") ?? false) {
            if requestVM.problem != nil {
                requestVM.problem?.append("Others: \(othersDescription.text ?? "")")
            } else {
                requestVM.problem = "Others: \(othersDescription.text ?? "")"
            }
        }
        if requestVM.validateAllFields() {
            requestVM.newRequest(completion: {[weak self] response in
                
                guard self != nil else { return }
                
                DispatchQueue.main.async {
                    if let _ = response as? [String: Any] {
                        print("success")
                        self?.historyDelegate?.reloadRequestTable()
                        self?.navigationController?.popViewController(animated: true)
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
        
        self.locationManager.delegate = self
    }
    
    func configureUI() {
        issueCheckboxes.enumerated().forEach{(index, element) in
            element.tag = index
            let checkboxEmpty = UIImage(named: "checkbox-empty")
            let checkboxFill = UIImage(named: "checkbox-fill")
            element.setImage(checkboxEmpty, for: .normal)
            element.setImage(checkboxFill, for: .selected)
            element.isAccessibilityElement = true
            element.accessibilityIdentifier = "\(index)"
        }
        othersDescription.tag = 1
        othersDescription.delegate = self
        addressTF.delegate = self
        extraDetails.delegate = self
        submitButton.accessibilityIdentifier = "submitButton"
        addressTF.accessibilityIdentifier = "addressField"
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        blinkingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.animateLocationButton), userInfo: nil, repeats: true)
        blinkingTimer?.fire()
    }
    
    func updateVM(for key: String, value: Any?, remove: Bool?) {
        switch key.lowercased() {
        case "address":
            requestVM.address = value as? String
        case "location":
            requestVM.clientLocation = value as? (Double, Double)
        case "problem":
            if requestVM.problem == nil { requestVM.problem = "" }
            
            if let serviceProblem = value as? String {
                if remove ?? false {
                    requestVM.problem = requestVM.problem?.replacingOccurrences(of: ", \(serviceProblem)", with: "")
                } else if !(requestVM.problem?.contains(serviceProblem) ?? true) {
                    requestVM.problem?.append(", \(serviceProblem)")
                }
            }
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
            updateVM(for: "address", value: completeText, remove: nil)
        default:
            break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1:
            updateVM(for: "problem", value: "Others: \(textField.text ?? "")", remove: false)
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressTF.resignFirstResponder()
        othersDescription.resignFirstResponder()
        extraDetails.resignFirstResponder()
        return true
    }
}

extension NewRequestViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let completeText = "\(textView.text ?? "")\(text)"
        updateVM(for: "description", value: completeText, remove: nil)
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
//        self.locationManager.stopUpdatingLocation()
        let coordinates: (Double, Double) = (newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        updateVM(for: "location", value: coordinates, remove: nil)
        reverseGeocoding(lat: newLocation.coordinate.latitude, long: newLocation.coordinate.longitude)
    }
    
    func reverseGeocoding(lat: Double, long: Double) {
        
        let location = CLLocation(latitude: lat, longitude: long)
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if let locationAddress = placemarks?.first {
                let addressStr = "\(locationAddress.subLocality ?? ""), \(locationAddress.locality ?? ""), \(locationAddress.administrativeArea ?? ""), \(locationAddress.country ?? "")"
                self.addressTF.text = addressStr
                self.updateVM(for: "address", value: addressStr, remove: nil)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
}

