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
    
    @IBAction func acceptRequest(_ sender: UIButton) {
        if sender.tag == 1 {
            requestVM?.requestCompleted(completion: {[weak self] errorStr in
                
                guard self != nil else { return }
                
                if let error = errorStr as? String {
                    self?.showAlert(title: "Update Failure!", message: error, completion: nil)
                } else {
                    self?.requestVM?.dispStatus = .success
                    self?.requestVM?.reqStatus = .completed
                    self?.historyDelegate?.reloadRequestTable()
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        } else {
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
            self.historyDelegate?.declineRequest(requestId: self.requestVM?.orderId ?? "")
            self.navigationController?.popViewController(animated: true)
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
                buttonStack.isHidden = true
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
        
        if let modelCoordinates = requestModel.location {
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
