//
//  RequestViewModel.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/20/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class RequestViewModel {
    
    var orderId: String?
    var clientUserId: String?
    var serviceUserId: String?
    var location: (Double, Double)?
    var address: String?
    var addressStr: String?
    var problem: String?
    var price: String?
    var cost: Float?
    var description: String?
    var statusImage: UIImage?
    var statusString: String?
    var status: RequestStatus?
    var locationImage: UIImage?
    var carDetails: CarDetails?
    var requestType: String?
    
    weak var interfaceDelegate: RequestVMInteractionProtocol?
    
    convenience init(data: RequestOrder) {
        self.init()
        
        clientUserId = data.clientUserId
        serviceUserId = data.serviceUserId
        orderId = data.id
        location = (data.lat, data.long)
        address = data.address
        addressStr = "Address: " + data.address
        problem = data.problem
        cost = data.cost
        price = "Cost: \(data.cost) KD"
        description = data.description
        status = data.status
        statusString = "Status: " + data.displayStatus.rawValue
        requestType = data.type.rawValue
        
        switch data.displayStatus {
        case .success:
            statusImage = UIImage(named: "success")
        case .processing:
            statusImage = UIImage(named: "process")
        case .accepted:
            statusImage = UIImage(named: "accept")
        case .cancelled:
            statusImage = UIImage(named: "cancel")
        default:
            statusImage = UIImage(named: "")
        }
        setLocationImage(lat: data.lat, long: data.long)
        setupCarDetails()
    }
    
    func newRequest(completion: @escaping ((Any?) -> Void)) {
        
        let geoLocation = GeoPoint(latitude: location?.0 ?? 0, longitude: location?.1 ?? 0)
        let orderDetail: [String: Any] = ["address": address ?? "", "cost": cost ?? 0, "description": description ?? "", "problem": problem ?? "", "location": geoLocation, "status": "confirmed"]
        
        WebService.shared.newWinchRequest(userId: "hRv1xrq940vADTH7tfr4", orderData: orderDetail, completionHandler: {[weak self] error in
            
            guard self != nil else { return }
            
            if let err = error as? Error {
                completion(err.localizedDescription)
            } else {
                completion(orderDetail)
            }
        })
    }
    
    func setupCarDetails() {
        WebService.shared.getCarDetails(userId: clientUserId ?? "", completionHandler: {(response) in
            if let result = response as? [String: Any] {
                self.carDetails = CarDetails(data: result)
            }
        })
    }
    
    func showRequest(vc: UIViewController?) {
        if let showRequestVC = vc?.storyboard?.instantiateViewController(identifier: "RequestConfirmationViewController") as? RequestConfirmationViewController {
            showRequestVC.requestVM = self
            showRequestVC.isActiveRequest = status == .active
            vc?.navigationController?.pushViewController(showRequestVC, animated: true)
        }
    }
    
    func setLocationImage(lat: Double, long: Double) {
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()

        // Set the region of the map that is rendered.
        let location = CLLocationCoordinate2DMake(37.332077, -122.02962) // Apple HQ
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 300, height: 300)

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.pointOfInterestFilter = .includingAll

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start(completionHandler: {[weak self] (snapshot, error) in
            self?.locationImage = snapshot?.image ?? UIImage()
            self?.interfaceDelegate?.setLocationImage(image: self?.locationImage)
        })
    }
    
    func validateAllFields() -> Bool {
        return validateAddress() && validateProblem()
    }
    
    func validateAddress() -> Bool {
        return address?.isEmpty ?? false
    }
    
    func validateProblem() -> Bool {
        return problem?.isEmpty ?? false
    }
    
    func getCarModel() -> String {
        return carDetails?.modelName ?? ""
    }
    
    func getCarPlate() -> String {
        return carDetails?.plate ?? ""
    }
    
    func getCarImageUrl() -> String {
        return carDetails?.imageUrlStr ?? ""
    }
    
    struct CarDetails {
        var modelName = ""
        var plate = ""
        var imageUrlStr = ""
        
        init(data: [String: Any]) {
            modelName = "\(data["manufacturer"] as? String ?? "") \(data["model"] as? String ?? "")"
            plate = data["licensePlate"] as? String ?? ""
        }
    }
}

public protocol RequestVMInteractionProtocol: class {
    func setLocationImage(image: UIImage?)
}
