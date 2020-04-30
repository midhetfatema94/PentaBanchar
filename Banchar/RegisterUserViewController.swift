//
//  RegisterUserViewController.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/1/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var viewScroll: UIScrollView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var detailsPage: UIPageControl!
    @IBOutlet weak var uploadButton: UIButton!
    
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

        let registerStepOne = RegisterPageOne(frame: viewScroll.bounds)
        viewScroll.addSubview(registerStepOne)
        
        let registerStepTwo = RegisterPageTwo(frame: viewScroll.bounds)
        registerStepTwo.frame.origin.x += registerStepOne.frame.width
        viewScroll.addSubview(registerStepTwo)
        
        let registerStepThree = RegisterPageThree(frame: viewScroll.bounds)
        registerStepThree.frame.origin.x += registerStepOne.frame.width + registerStepTwo.frame.width
        viewScroll.addSubview(registerStepThree)
        
        viewScroll.delegate = self
        
        viewScroll.contentSize.width = viewScroll.bounds.width * 3
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
}
