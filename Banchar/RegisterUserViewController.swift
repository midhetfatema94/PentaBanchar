//
//  RegisterUserViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

protocol PagesCommunicationDelegate: class {
    func updateVM(for key: String, value: Any?)
    func getValue(for key: String) -> Any?
}

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var viewScroll: UIScrollView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var detailsPage: UIPageControl!
    @IBOutlet weak var uploadButton: UIButton!
    
    var loginVM: LoginViewModel!
    
    @IBAction func pageClicked(_ sender: UIPageControl) {
        var originPoint = CGPoint.zero
        originPoint.x = viewScroll.bounds.width * CGFloat(sender.currentPage)
        viewScroll.setContentOffset(originPoint, animated: true)
        uploadButton.isHidden = detailsPage.currentPage != 2
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
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
    
    func validateCurrentPage(page: Int) {
//        switch page {
//        case 0:
//        default:
//
//        }
    }
}

extension RegisterUserViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        switch scrollView.contentOffset.x {
        case scrollView.frame.width:
            detailsPage.currentPage = 1
        case scrollView.frame.width * 2:
            detailsPage.currentPage = 2
        default:
            detailsPage.currentPage = 0
        }
        uploadButton.isHidden = detailsPage.currentPage != 2
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
            loginVM.carModel = value as? String
        case "carplate":
            loginVM.carPlate = value as? String
        case "agreetnc":
            loginVM.agreeTnc = value as? Bool
        case "usertype":
            loginVM.userType = value as? String
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
            return loginVM.carModel
        case "carplate":
            return loginVM.carPlate
        case "agreetnc":
            return loginVM.agreeTnc
        case "usertype":
            return loginVM.userType
        default:
            return nil
        }
    }
}
