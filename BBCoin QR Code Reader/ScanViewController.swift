//
//  ScanViewController.swift
//  BBCoin QR Code Reader
//
//  Created by KP on 2018-03-24.
//  Copyright © 2018 KP. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ScanViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    private let systemSoundId: SystemSoundID = 1016
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let initialStatus: String = "Place camera near the BB Coin QR Code."
    private let validatingStatus: String = "Validating payment..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupStatusLabel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession?.startRunning()
    }
    
    func setupCaptureSession() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        if let captureDevice = captureDevice {
            do {
                captureSession = AVCaptureSession()
                let captureMetadataOutput = AVCaptureMetadataOutput()
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                captureSession?.addInput(input)
                captureSession?.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = [.qr]
                
                captureSession?.startRunning()
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                view.layer.addSublayer(videoPreviewLayer!)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func setupStatusLabel() {
        statusLabel.text = initialStatus
        view.bringSubview(toFront: statusLabel)
    }
    
    @IBAction func unwindBackToScan(segue:UIStoryboardSegue) {
        statusLabel.text = initialStatus
    }
}

// MARK: AV Capture Metadata Output Objects Delegate
extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            print("No objects are returned.")
            return
        }
        
        let metaDataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        guard let stringCodeValue = metaDataObject.stringValue else {
            return
        }
        
        print("Scanned following value: \(stringCodeValue)")
        
        AudioServicesPlayAlertSound(systemSoundId)
        statusLabel.text = validatingStatus
        
        performSegue(withIdentifier: "successfulValidation", sender: self)
        captureSession?.stopRunning()
    }
    
}

// MARK: Network Request
extension ScanViewController {
    let url = URL(string: "http://www.thisismylink.com/postName.php")!
    var request = URLRequest(url: url)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    let postString = "id=13&name=Jack"
    request.httpBody = postString.data(using: .utf8)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {                                                 // check for fundamental networking error
            print("error=\(error)")
            return
        }
        
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print("response = \(response)")
        }
        
        let responseString = String(data: data, encoding: .utf8)
        print("responseString = \(responseString)")
    }
    task.resume()
}

