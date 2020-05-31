//
//  Alerts.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/20/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation
import UIKit
import AVKit

extension UIViewController {
    func showAlert(title: String?, message: String?, completion: ((Any?) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPermissionAlert(title: String?, message: String?, cancelSelector: ((Any?) -> Void)?, completion: ((Any?) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: cancelSelector))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: completion))
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeImagePickerActionSheet(imagePicker: UIImagePickerController, isFront: Bool) {
        
        let takePhoto = "Take Photo"
        let chooseImage = "Choose from Library"
        
        var isCamera = true
        
        if UIImagePickerController.availableCaptureModes(for: .rear) == nil {
            isCamera = false
        }
        
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraOption = UIAlertAction(title: takePhoto, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            if isFront {
                imagePicker.cameraDevice = .front
            }
            if self.checkCameraAuthorise() {
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        })
        if isCamera {
            options.addAction(cameraOption)
        }
        let libraryOption = UIAlertAction(title: chooseImage, style: .default, handler: {(alert: UIAlertAction!) -> Void in
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        })
        options.addAction(libraryOption)
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        options.addAction(cancelOption)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = options.popoverPresentationController {
                popoverController.sourceView = view.superview
                popoverController.sourceRect = view.frame
                popoverController.permittedArrowDirections = []
            }
        }
        
        imagePicker.navigationController?.navigationBar.barStyle = .black
        self.present(options, animated: true, completion: nil)
    }
    
    func checkCameraAuthorise() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("Camera: Auth status-\(status.rawValue)")
        if status == .denied || status == .restricted {
           return false
        }
        return true
    }
}
