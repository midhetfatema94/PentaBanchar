//
//  RequestConfirmationViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit
import MapKit

class RequestConfirmationViewController: UIViewController {
    
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestId: UILabel!
    @IBOutlet weak var clientAddress: UILabel!
    @IBOutlet weak var clientCarModel: UILabel!
    @IBOutlet weak var carPlate: UILabel!
    @IBOutlet weak var clientProblem: UILabel!
    @IBOutlet weak var problemDescription: UITextView!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var locationMap: MKMapView!
    
    weak var historyDelegate: RequestHistoryCommunicationProtocol?
    var requestVM: RequestViewModel?
    let locationManager = CLLocationManager()
    
    @IBAction func acceptRequest(_ sender: UIButton) {
        //Tag is 0: Server-side has accepted service request
        //Tag is 1: Client-side has completed service
        //Tag is 2: Client-side has completed service, but not given rating yet
        switch sender.tag {
        case 0:
            requestVM?.serviceUserId = historyDelegate?.getUserId()
            requestVM?.acceptRequest(completion: {[weak self] errorStr in
                
                guard self != nil else { return }
                
                if let error = errorStr as? String {
                    self?.showAlert(title: "Failure of cancelation!", message: error, completion: nil)
                } else {
                    self?.requestVM?.dispStatus = .accepted
                    self?.historyDelegate?.reloadRequestTable()
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        case 1:
            requestVM?.requestCompleted(completion: {[weak self] errorStr in
                
                guard self != nil else { return }
                
                if let error = errorStr as? String {
                    self?.showAlert(title: "Update Failure!", message: error, completion: nil)
                } else {
                    self?.requestVM?.dispStatus = .success
                    self?.requestVM?.reqStatus = .completed
                    self?.historyDelegate?.reloadRequestTable()
                    self?.gotoPayment()
                }
            })
        case 2:
            if let ratingVC = self.storyboard?.instantiateViewController(identifier: "RatingViewController") as? RatingViewController {
                ratingVC.requestVM = self.requestVM
                ratingVC.historyDelegate = self.historyDelegate
                self.navigationController?.pushViewController(ratingVC, animated: true)
            }
        default:
            break
        }
    }
    
    @IBAction func declineRequest(_ sender: UIButton) {
        //Tag is 1: Canceling from client-side
        //Tag is 0: Canceling from service-side
        if sender.tag == 1 {
            requestVM?.cancelRequest(completion: {[weak self] errorStr in
                
                guard self != nil else { return }
                
                if let error = errorStr as? String {
                    self?.showAlert(title: "Failure of cancelation!", message: error, completion: nil)
                } else {
                    self?.historyDelegate?.reloadRequestTable()
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            requestVM?.declineRequest(winchId: historyDelegate?.getUserId() ?? "", completion: {[weak self] errorStr in
                
                guard self != nil else { return }
                
                if let error = errorStr as? String {
                    self?.showAlert(title: "Request Failure!", message: error, completion: nil)
                } else if let requestModel = self?.requestVM {
                    self?.historyDelegate?.declineRequest(request: requestModel)
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        
        guard let requestModel = requestVM else { return }
        
        if requestModel.userType == .client {
            if requestModel.reqStatus == .completed {
                if requestModel.rating != nil {
                    buttonStack.isHidden = true
                } else {
                    acceptBtn.isHidden = false
                    acceptBtn.setTitle("Give Rating", for: .normal)
                    acceptBtn.tag = 2
                    declineBtn.isHidden = true
                    buttonStack.isHidden = false
                }
            } else {
                 if requestModel.reqStatus == .active {
                    acceptBtn.isHidden = false
                    acceptBtn.setTitle("Request Completed", for: .normal)
                    acceptBtn.tag = 1
                    declineBtn.isHidden = true
                    buttonStack.isHidden = false
                } else if requestModel.dispStatus != .accepted {
                    declineBtn.isHidden = false
                    declineBtn.setTitle("Cancel Request", for: .normal)
                    declineBtn.tag = 1
                    acceptBtn.isHidden = true
                    buttonStack.isHidden = false
                }
            }
        } else {
            buttonStack.isHidden = requestModel.reqStatus != .processing
        }
        
        requestId.text = "Ticket Id: \(requestModel.orderId ?? "")"
        clientAddress.text = requestModel.addressStr ?? ""
        clientCarModel.text = "Car: \(requestModel.getCarModel())"
        carPlate.text = "License Plate: \(requestModel.getCarPlate())"
        clientProblem.text = "Problem: \(requestModel.problem ?? "")"
        problemDescription.text = requestModel.description
        locationMap.delegate = self
        
        if let modelCoordinates = requestModel.clientLocation {
            let locationCoordinate = MKPointAnnotation()
            locationCoordinate.coordinate = CLLocationCoordinate2D(latitude: modelCoordinates.0, longitude: modelCoordinates.1)
            locationMap.addAnnotation(locationCoordinate)
            let region = MKCoordinateRegion(center: locationCoordinate.coordinate,
                                            latitudinalMeters: 5000,
                                            longitudinalMeters: 6000)
            locationMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region),
                                          animated: true)
            let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2000)
            locationMap.setCameraZoomRange(zoomRange, animated: true)
            locationMap.setCenter(locationCoordinate.coordinate, animated: true)
        }
        
        switch requestModel.reqStatus {
        case .active:
            requestTitle.text = "Active Request"
        case .processing:
            requestTitle.text = "Processing Request"
        default:
            requestTitle.text = "Completed Request"
        }
    }
    
    func gotoPayment() {
        if let paymentVC = self.storyboard?.instantiateViewController(identifier: "PaymentViewController") as? PaymentViewController {
            self.navigationController?.pushViewController(paymentVC, animated: true)
        }
    }
    
    func startLocationTracking() {
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
}

extension RequestConfirmationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "annotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
}

extension RequestConfirmationViewController: CLLocationManagerDelegate {

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
        updateServiceVehicleLocation(lat: newLocation.coordinate.latitude, long: newLocation.coordinate.longitude)
    }
    
    func updateServiceVehicleLocation(lat: Double, long: Double) {
        print("location coordinates: ", lat, long)
        requestVM?.updateServerLocation(lat: lat, long: long)
    }
}
