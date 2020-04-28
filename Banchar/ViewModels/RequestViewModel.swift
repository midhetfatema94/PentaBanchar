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

class RequestViewModel {
    
    var userId: String!
    var location: (Double, Double)!
    var address: String!
    var problem: String!
    var price: String!
    var description: String!
    var statusImage: UIImage!
    var statusString: String!
    var locationImage: UIImage!
    
    weak var interfaceDelegate: RequestVMInteractionProtocol?
    
    convenience init(data: RequestOrder) {
        self.init()
        
        userId = data.id
        location = (data.lat, data.long)
        address = "Address: " + data.address
        problem = data.problem
        price = "Cost: \(data.cost) KD"
        description = data.description
        statusString = "Status: " + data.status.rawValue
        
        switch data.status {
        case .success:
            statusImage = UIImage(named: "success")
        case .processing:
            statusImage = UIImage(named: "process")
        case .failed:
            statusImage = UIImage(named: "fail")
        case .cancelled:
            statusImage = UIImage(named: "cancel")
        default:
            statusImage = UIImage(named: "")
        }
        setLocationImage(lat: data.lat, long: data.long)
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
}

public protocol RequestVMInteractionProtocol: class {
    func setLocationImage(image: UIImage?)
}
