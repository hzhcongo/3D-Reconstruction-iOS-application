//
//  ViewController.swift
//  3d reconstruction
//
//  Created by jiasheng on 21/12/16.
//  Copyright © 2016 jiasheng. All rights reserved.
//
//  Improved and refined by zehao since 20/2/18.
//  Copyright © 2018 zehao. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var IPaddress: UITextField!
    @IBOutlet weak var numbertext: UILabel!
    @IBOutlet weak var angletext: UILabel!
    @IBOutlet weak var qualitytext: UILabel!
    @IBOutlet weak var flashtext: UILabel!
    
    
    var photoNumber = Float(20)
    var viewAngle = Float(180)
    var ip = String()
    var photoq = Int(0)
    var flashOn = false
    @IBAction func changePhotoNumber(_ sender: UISlider) {
        photoNumber = sender.value
        numbertext.text = String(Int(photoNumber))
    }
    @IBAction func changeViewAngle(_ sender: UISlider) {
        viewAngle = sender.value
        angletext.text = String(Int(viewAngle))
    }
    @IBAction func changeIPaddress(_ sender: UIButton) {
        ip = IPaddress.text!
    }
    
    @IBAction func changePhotoQuality(_ sender: UIStepper) {
        switch(sender.value){
        case 0:
            qualitytext.text = "Resolution: 352x288"
            photoq=0
        case 1:
            qualitytext.text = "Resolution: 640x480"
            photoq=1
        case 2:
            qualitytext.text = "Resolution: 1280x720"
            photoq=2
        case 3:
            qualitytext.text = "Resolution: 1920x1080"
            photoq=3
        case 4:
            qualitytext.text = "Resolution: 3840x2160"
            photoq=4
        default:
            qualitytext.text = "Resolution: 352x288"
            photoq=0
        }
    }
    
    @IBAction func changeFlash(_ sender: UISwitch) {
        if(sender.isOn){
            flashtext.text = "Flash: On"
            flashOn = true
        }
        else{
            flashtext.text = "Flash: Off"
            flashOn = false
        }
    }
    
    @IBAction func cameraButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "camera", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var DestViewController :CameraViewController = segue.destination as! CameraViewController
        DestViewController.IPaddress = ip
        DestViewController.viewAngle = viewAngle
        DestViewController.photoNumber = Int(photoNumber)
        DestViewController.photoq = photoq
        DestViewController.flashOn = flashOn
        print("Angle photoNumber IPaddress ", viewAngle, ", ", photoNumber, ", ", ip)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //    Set Start btn radius
        cameraButton.layer.cornerRadius = 5
        cameraButton.layer.borderColor = self.view.tintColor.cgColor
        cameraButton.layer.borderWidth = 1

    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        captureSession = AVCaptureSession()
//        captureSession?.sessionPreset = AVCaptureSessionPreset640x480
//        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
//        var error: NSError?
//        var input: AVCaptureDeviceInput!
//        do {
//            input = try AVCaptureDeviceInput(device: backCamera)
//        } catch let error1 as NSError {
//            error = error1
//            input = nil
//            print(error!.localizedDescription)
//        }
//        
//        if error == nil && captureSession!.canAddInput(input){
//            captureSession!.addInput(input)
//            stillImageOutput = AVCaptureStillImageOutput()
//            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
//            if captureSession!.canAddOutput(stillImageOutput){
//                captureSession!.addOutput(stillImageOutput)
//                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
//                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//                cameraView.layer.addSublayer(previewLayer!)
//                captureSession!.startRunning()
//            }
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
