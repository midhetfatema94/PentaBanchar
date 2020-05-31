//
//  RegisterUserViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit
import AVKit

protocol PagesCommunicationDelegate: class {
    func updateVM(for key: String, value: Any?)
    func getValue(for key: String) -> Any?
}

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var viewScroll: UIScrollView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var detailsPage: UIPageControl!
    @IBOutlet weak var uploadButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var loginVM: LoginViewModel!
    
    @IBAction func pageClicked(_ sender: UIPageControl) {
        var originPoint = CGPoint.zero
        originPoint.x = viewScroll.bounds.width * CGFloat(sender.currentPage)
        let previousPage: Int = Int((viewScroll.contentOffset.x/CGFloat(sender.numberOfPages))/130)
        if validateCurrentPage(page: previousPage) {
            viewScroll.setContentOffset(originPoint, animated: true)
            uploadButton.isHidden = detailsPage.currentPage != 2
        } else {
            sender.currentPage = previousPage
            showAlert(title: "Validation Error", message: "Please fill all fields correctly", completion: nil)
        }
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        imagePicker.delegate = self
        self.makeImagePickerActionSheet(imagePicker: imagePicker, isFront: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let registerStepOne = RegisterPageOne(frame: viewScroll.bounds, delegate: self)
        viewScroll.addSubview(registerStepOne)
        
        let registerStepTwo = RegisterPageTwo(frame: viewScroll.bounds, delegate: self)
        registerStepTwo.frame.origin.x += registerStepOne.frame.width
        viewScroll.addSubview(registerStepTwo)
        
        let registerStepThree = RegisterPageThree(frame: viewScroll.bounds, delegate: self)
        registerStepThree.frame.origin.x += registerStepOne.frame.width + registerStepTwo.frame.width
        viewScroll.addSubview(registerStepThree)
        
        viewScroll.delegate = self
        viewScroll.contentSize.width = viewScroll.bounds.width * 3
    }
    
    func validateCurrentPage(page: Int) -> Bool {
        switch page {
        case 0:
            return loginVM.validateUsername() && loginVM.validateEmail()
        case 1:
            return loginVM.validatePassword()
        default:
            return loginVM.validateLicensePlate() && loginVM.validateCarModel() && loginVM.validateTnC()
        }
    }
}

extension RegisterUserViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if validateCurrentPage(page: detailsPage.currentPage) {
            switch scrollView.contentOffset.x {
            case scrollView.frame.width:
                detailsPage.currentPage = 1
            case scrollView.frame.width * 2:
                detailsPage.currentPage = 2
            default:
                detailsPage.currentPage = 0
            }
            uploadButton.isHidden = detailsPage.currentPage != 2
        } else {
            let originPoint = CGPoint(x: viewScroll.bounds.width * CGFloat(detailsPage.currentPage), y: 0)
            viewScroll.setContentOffset(originPoint, animated: true)
            showAlert(title: "Validation Error", message: "Please fill all fields correctly", completion: nil)
       }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("dragging begun")
    }
}

extension RegisterUserViewController: PagesCommunicationDelegate {
    func updateVM(for key: String, value: Any?) {
        switch key.lowercased() {
        case "userid":
            loginVM.userId = value as? String
        case "email":
            loginVM.email = value as? String
        case "username":
            loginVM.username = value as? String
        case "carmodel":
            loginVM.primaryCarModel = value as? String
        case "carplate":
            loginVM.primaryCarPlate = value as? String
        case "agreetnc":
            loginVM.agreeTnc = value as? Bool
        case "usertype":
            loginVM.userType = UserType(rawValue: value as? String ?? "")
        case "password":
            loginVM.password = value as? String
        case "repeat":
            loginVM.repeatPassword = value as? String
        default:
            break
        }
    }
    
    func getValue(for key: String) -> Any? {
        switch key.lowercased() {
        case "userid":
            return loginVM.userId
        case "email":
            return loginVM.email
        case "username":
            return loginVM.username
        case "carmodel":
            return loginVM.primaryCarModel
        case "carplate":
            return loginVM.primaryCarPlate
        case "agreetnc":
            return loginVM.agreeTnc
        case "usertype":
            return loginVM.userType
        default:
            return nil
        }
    }
}

extension RegisterUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let cameraNotAccessTitle = "Camera Disabled"
        let cameraNotAccessSubTitle = "Please provide access to Camera to use this feature. Go to Settings and enable Camera access"
        
        if let pickedImage = info[.editedImage] as? UIImage, checkCameraAuthorise() {
            placeholderImageView.image = pickedImage
            imagePicker.dismiss(animated: true, completion: nil)
        } else {
            self.imagePicker.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.showAlert(title: cameraNotAccessTitle, message: cameraNotAccessSubTitle, completion: nil)
                }
            }
        }
    }
}
