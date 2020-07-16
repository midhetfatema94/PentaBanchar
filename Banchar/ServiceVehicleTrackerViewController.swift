//
//  ServiceVehicleTrackerViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit
import MapKit

class ServiceVehicleTrackerViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    weak var historyDelegate: RequestHistoryCommunicationProtocol?
    var requestVM: RequestViewModel?
    var locationUpdateTimer: Timer?
    let locationManager = CLLocationManager()
    
    @IBAction func serviceCompleted(_ sender: UIButton) {
        requestVM?.requestCompleted(completion: {[weak self] errorStr in
            
            guard self != nil else { return }
            
            if let error = errorStr as? String {
                self?.showAlert(title: "Update Failure!", message: error, completion: nil)
            } else {
                self?.locationUpdateTimer?.invalidate()
                self?.requestVM?.dispStatus = .success
                self?.requestVM?.reqStatus = .completed
                self?.historyDelegate?.reloadRequestTable()
                self?.gotoPayment()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationUpdateTimer?.invalidate()
    }
    
    func configureUI() {

        mapView.delegate = self
        
        setupLocation()
        
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.getUpdatedLocation), userInfo: nil, repeats: true)
        locationUpdateTimer?.fire()
    }
    
    func setupLocation() {
        if let modelCoordinates = requestVM?.serverLocation {
            let locationCoordinate = MKPointAnnotation()
            locationCoordinate.coordinate = CLLocationCoordinate2D(latitude: modelCoordinates.0, longitude: modelCoordinates.1)
            mapView.addAnnotation(locationCoordinate)
            let region = MKCoordinateRegion(center: locationCoordinate.coordinate,
                                            latitudinalMeters: 5000,
                                            longitudinalMeters: 6000)
            mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region),
                                          animated: true)
            let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2000)
            mapView.setCameraZoomRange(zoomRange, animated: true)
            mapView.setCenter(locationCoordinate.coordinate, animated: true)
        }
    }
    
    func gotoPayment() {
        if let paymentVC = self.storyboard?.instantiateViewController(identifier: "PaymentViewController") as? PaymentViewController {
            self.navigationController?.pushViewController(paymentVC, animated: true)
        }
    }
    
    @objc func getUpdatedLocation() {
        requestVM?.getUpdatedServerLocation(completion: {isUpdated in
            if isUpdated {
                self.setupLocation()
            }
        })
    }
}

extension ServiceVehicleTrackerViewController: MKMapViewDelegate {
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

