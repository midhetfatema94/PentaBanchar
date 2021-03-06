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
    var clientLocation: (lat: Double, long: Double)?
    var serverLocation: (lat: Double, long: Double)?
    var address: String?
    var addressStr: String?
    var problem: String?
    var price: String?
    var cost: Float?
    var description: String?
    var statusImage: UIImage?
    var statusString: String?
    var dispStatus: DisplayStatus = .processing
    var reqStatus: RequestStatus = .processing
    var locationImage: UIImage?
    var carDetails: RequestCarDetails?
    var requestType: String?
    var userType: UserType?
    var declinedIds: [String] = []
    var rating: Float?
    var review: String?
    
    weak var interfaceDelegate: RequestVMInteractionProtocol?
    
    convenience init(data: RequestOrder) {
        self.init()
        
        clientUserId = data.clientUserId
        serviceUserId = data.serviceUserId
        orderId = data.id
        clientLocation = (data.lat, data.long)
        serverLocation = (data.serviceLat, data.serviceLong)
        address = data.address
        addressStr = "Address: " + data.address
        problem = data.problem
        cost = data.cost
        price = (cost ?? 0) > 0 ? "Cost: \(data.cost) KD" : "Not charged yet"
        description = data.description
        reqStatus = data.status
        dispStatus = data.displayStatus
        statusString = "Status: " + data.displayStatus.rawValue.capitalized
        requestType = data.type.rawValue
        declinedIds = data.declinedIds
        review = data.review
        
        if data.rating > 0 {
            rating = data.rating
        }
        
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
        var orderDetail: [String: Any] = ["address": address ?? "", "cost": cost ?? 0, "description": description ?? "", "problem": problem ?? "", "status": reqStatus.rawValue, "clientUserId": clientUserId ?? "", "serviceUserId": serviceUserId ?? "", "displayStatus": dispStatus.rawValue, "type": requestType ?? ""]
        
        if let clientLoc = clientLocation {
            let geoLocation = GeoPoint(latitude: clientLoc.lat, longitude: clientLoc.long)
            orderDetail["location"] = geoLocation
        }
        
        WebService.shared.newWinchRequest(orderData: orderDetail, completionHandler: {[weak self] error in
            
            guard let strongSelf = self else { return }
            
            if let err = error as? Error {
                completion(err.localizedDescription)
            } else {
                self?.reqStatus = .active
                orderDetail["status"] = strongSelf.reqStatus.rawValue
                completion(orderDetail)
            }
        })
    }
    
    func cancelRequest(completion: @escaping ((Any?) -> Void)) {
        WebService.shared.cancelServiceRequest(orderId: self.orderId ?? "", completionHandler: {[weak self] error in
            
            guard self != nil else { return }
            
            if let err = error as? Error {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
    
    func acceptRequest(completion: @escaping ((Any?) -> Void)) {
        WebService.shared.acceptServiceRequest(orderId: self.orderId ?? "", serverId: self.serviceUserId ?? "", completionHandler: {[weak self] error in
            
            guard self != nil else { return }
            
            if let err = error as? Error {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
    
    func declineRequest(winchId: String, completion: @escaping ((Any?) -> Void)) {
        self.declinedIds.append(winchId)
        WebService.shared.declineServiceRequest(orderId: self.orderId ?? "", declinedIds: self.declinedIds, completionHandler: {[weak self] error in
            
            guard self != nil else { return }
            
            if let err = error as? Error {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
    
    func requestCompleted(completion: @escaping ((Any?) -> Void)) {
        WebService.shared.winchRequestCompleted(orderId: self.orderId ?? "", completionHandler: {[weak self] error in
            
            guard self != nil else { return }
            
            if let err = error as? Error {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
    
    func submitRating(completion: @escaping ((Any?) -> Void)) {
        WebService.shared.updateRatingReview(orderId: self.orderId ?? "", rating: self.rating ?? 0, review: self.review ?? "", completionHandler: {[weak self] error in
            
            guard self != nil else { return }
            
            if let err = error as? Error {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
    
    func setupCarDetails() {
        WebService.shared.getCarDetails(userId: clientUserId ?? "", completionHandler: {(response) in
            if let result = response as? [String: Any] {
                self.carDetails = RequestCarDetails(data: result)
            }
        })
    }
    
    func updateServerLocation(lat: Double, long: Double) {
        let geoLocation = GeoPoint(latitude: lat, longitude: long)
        serverLocation = (lat: lat, long: long)
        WebService.shared.updateServerLocation(orderId: orderId ?? "", location: geoLocation, completionHandler: nil)
    }
    
    func getUpdatedServerLocation(completion: @escaping ((Bool) -> Void)) {
        WebService.shared.getUpdatedServerLocation(orderId: orderId ?? "", completionHandler: {updatedLocation in
            if let newLocation = updatedLocation as? GeoPoint, let serverLoc = self.serverLocation {
                if newLocation.latitude != serverLoc.lat || newLocation.longitude != serverLoc.long {
                    self.serverLocation = (newLocation.latitude, newLocation.longitude)
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        })
    }
    
    func setLocationImage(lat: Double, long: Double) {
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()

        // Set the region of the map that is rendered.
        let snapLocation = CLLocationCoordinate2DMake(lat, long)
        let region = MKCoordinateRegion(center: snapLocation,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 300, height: 300)
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 300))

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.pointOfInterestFilter = .includingAll

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start(completionHandler: {[weak self] (snapshot, error) in
            
            let snapshotImage = UIGraphicsImageRenderer(size: mapSnapshotOptions.size).image { _ in
                snapshot?.image.draw(at: .zero)

                let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                let pinImage = pinView.image

                if var point = snapshot?.point(for: snapLocation), rect.contains(point) {
                    point.x -= pinView.bounds.width / 2
                    point.y -= pinView.bounds.height / 2
                    point.x += pinView.centerOffset.x
                    point.y += pinView.centerOffset.y
                    pinImage?.draw(at: point)
                }
            }
            
            self?.locationImage = snapshotImage
            self?.interfaceDelegate?.setLocationImage(image: self?.locationImage)
        })
    }
    
    func validateAllFields() -> Bool {
        return validateAddress() && validateProblem()
    }
    
    func validateAddress() -> Bool {
        return !(address?.isEmpty ?? true)
    }
    
    func validateProblem() -> Bool {
        return !(problem?.isEmpty ?? true)
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
}

struct RequestCarDetails {
    var modelName = ""
    var plate = ""
    var imageUrlStr = ""
    
    init() { }
    
    init(data: [String: Any]) {
        modelName = "\(data["manufacturer"] as? String ?? "") \(data["model"] as? String ?? "")"
        plate = data["licensePlate"] as? String ?? ""
        imageUrlStr = data["imageUrl"] as? String ?? ""
    }
}

public protocol RequestVMInteractionProtocol: class {
    func setLocationImage(image: UIImage?)
}
