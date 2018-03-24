//
//  PaymentApprovalViewController.swift
//  BBCoin QR Code Reader
//
//  Created by KP on 2018-03-24.
//  Copyright © 2018 KP. All rights reserved.
//

import UIKit

class PaymentApprovalViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var approvalLabel: UILabel!
    @IBOutlet weak var scanAgainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeAlphaValue(alpha: 0)
        loadingIndicator.startAnimating()
        
        Timer.scheduledTimer(timeInterval: 1.5,
                             target: self,
                             selector: #selector(finishedLoading),
                             userInfo: nil,
                             repeats: false)
    }
    
    @objc func finishedLoading() {
        loadingIndicator.stopAnimating()
        changeAlphaValue(alpha: 1.0)
    }
    
    func changeAlphaValue(alpha: CGFloat) {
        logoImageView.alpha = alpha
        approvalLabel.alpha = alpha
        scanAgainButton.alpha = alpha
    }
}
