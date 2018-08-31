//
//  ViewController.swift
//  3D Reconstruction
//
//  Created by jiasheng on 21/12/16.
//  Improved by Heng Ze Hao on 19/5/18.
//  Copyright © 2016 jiasheng. All rights reserved.
//  Copyright © 2018 Heng Ze Hao. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc var captureSession : AVCaptureSession?
    @objc var stillImageOutput : AVCaptureStillImageOutput?
    @objc var previewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var IPaddress: UITextField!
    @IBOutlet weak var modelName: UITextField!
    @IBOutlet weak var numbertext: UILabel!
    @IBOutlet weak var angletext: UILabel!
    @IBOutlet weak var qualityInput: UILabel!
    @IBOutlet weak var flashswitch: UISwitch!
    @IBOutlet weak var modelQControl: UISegmentedControl!
    
    @objc var photoNumber = Float(30)
    @objc var viewAngle = Float(180)
    @objc var ip = String("192.168.0.157:5000")
    @objc var modelname = String()
    @objc var photoq = Int(3)
    @objc var modelq = Int(0)
    @objc var flashOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    @IBAction func changePhotoNumber(_ sender: UISlider) {
        photoNumber = sender.value
        numbertext.text = String(Int(photoNumber))
    }
    
    @IBAction func changeViewAngle(_ sender: UISlider) {
        viewAngle = sender.value
        angletext.text = String(Int(viewAngle))
    }
    
    @IBAction func changePhotoDims(_ sender: UISlider) {
        photoq = Int(sender.value)
        
        switch(photoq){
            case 0:
            qualityInput.text = "352x288"
            case 1:
            qualityInput.text = "640x480"
            case 2:
            qualityInput.text = "1280x720"
            case 3:
            qualityInput.text = "1920x1080"
//            case 4:
//            qualityInput.text = "3840x2160"
            default:
            qualityInput.text = "352x288"
        }
    }
    
    @IBAction func changeIPaddress(_ sender: Any) {
        ip = IPaddress.text!
        
//        ////ALERT DIALOG BOX
//        // create the alert
//        let alert = UIAlertController(title: "IP", message: ip, preferredStyle: UIAlertControllerStyle.alert)
//
//        // add an action (button)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//
//        // show the alert
//        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func modelNamechanged(_ sender: Any) {
        modelname = modelName.text!
        print(modelname)
    }
    
    @IBAction func modelQualityChanged(_ sender: Any) {
        modelq = modelQControl.selectedSegmentIndex
    }
    
    @IBAction func editFlash(_ sender: Any) {
        flashOn = flashswitch.isOn
    }
    
    @IBAction func cameraButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "camera", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if ip.elementsEqual("") {
            ////ALERT DIALOG BOX
            // create the alert
            let alert = UIAlertController(title: "Incomplete configuration", message: "Please enter the server's IP address", preferredStyle: UIAlertControllerStyle.alert)
    
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else if modelname.elementsEqual("") || modelname.contains(" ") {
            ////ALERT DIALOG BOX
            // create the alert
            let alert = UIAlertController(title: "Missing or invalid name", message: "Please enter a name that contains no spaces", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let DestViewController :CameraViewController = segue.destination as! CameraViewController
            DestViewController.IPaddress = ip
            DestViewController.modelname = modelname
            DestViewController.viewAngle = viewAngle
            DestViewController.photoNumber = Int(photoNumber)
            DestViewController.photoq = photoq
            DestViewController.flashOn = flashOn
            DestViewController.modelq = modelq
            print("Angle photoNumber IPaddress modelname", viewAngle, ", ", photoNumber, ", ", ip, ", ", modelname)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Menu"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
