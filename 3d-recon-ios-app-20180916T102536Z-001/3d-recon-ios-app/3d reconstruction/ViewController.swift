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
    @IBOutlet weak var numberinput: UITextField!
    @IBOutlet weak var numbertext: UILabel!
    @IBOutlet weak var angleinput: UITextField!
    @IBOutlet weak var angletext: UILabel!
    @IBOutlet weak var qualityInput: UILabel!
    @IBOutlet weak var dimensioninput: UISegmentedControl!
    @IBOutlet weak var flashswitch: UISwitch!
    @IBOutlet weak var modelQControl: UISegmentedControl!
    @IBOutlet weak var photoNumSlider: UISlider!
    @IBOutlet weak var viewAngleSlider: UISlider!
    
    @objc var photoNumber = Int(60)
    @objc var viewAngle = Int(360)
    @objc var ip = String("192.168.0.157:5000")
    @objc var modelname = String()
    @objc var photoq = Int(3)
    @objc var modelq = Int(2)
    @objc var flashOn = false
    
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Menu"
        
        setUpReachability();
        
        if(reachability.connection == .none){////ALERT DIALOG BOX
            // create the alert
            let alert = UIAlertController(title: "Not connected", message: "Please connect to the internet first", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                action in self.setUpReachability();
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpReachability()
    {
        //declare this property where it won't go out of scope relative to your listener
        DispatchQueue.main.async {
            
            self.reachability.whenReachable = { reachability in
                if reachability.connection == .wifi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
            self.self.reachability.whenUnreachable = { _ in
                print("Not reachable")
                
            }
            
            do {
                try self.reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
            
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func changePhotoNumber(_ sender: UISlider) {
        photoNumber = Int(sender.value)
        numberinput.text = String(photoNumber)
        print(String(sender.value))
    }
    
    @IBAction func photoNumChange(_ sender: UITextField) {
        let newNum = Int(sender.text!)
        if(newNum == nil || newNum! < 0 || newNum! > 90){
            sender.text = String(photoNumber)
            
            ////ALERT DIALOG BOX
            // create the alert
            let alert = UIAlertController(title: "Invalid number of photos", message: "Please enter an integer value between 0 and 60", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else{
            photoNumber = newNum!
        }
        photoNumSlider.setValue(Float(photoNumber), animated: true)
    }
    
    @IBAction func changeViewAngle(_ sender: UISlider) {
        viewAngle = Int(sender.value)
        angleinput.text = String(viewAngle)
        print(String(sender.value))
    }
    
    @IBAction func viewAngleChange(_ sender: UITextField) {
        let newNum = Int(sender.text!)
        if(newNum == nil || newNum! < 90 || newNum! > 360){
            sender.text = String(viewAngle)
            
            ////ALERT DIALOG BOX
            // create the alert
            let alert = UIAlertController(title: "Invalid viewing angle", message: "Please enter an integer value between 90 and 360", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else{
            viewAngle = newNum!
        }
        viewAngleSlider.setValue(Float(viewAngle), animated: true)
    }
    
    @IBAction func changePhotoDims(_ sender: UISlider) {
        photoq = Int(sender.value)
        print(photoq)
        
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
    @IBAction func changeDims(_ sender: UISegmentedControl) {
        photoq = Int(sender.selectedSegmentIndex)
        print(photoq)
    }
    
//    func verifyUrl (urlString: String?) -> Bool {
//        //Check for nil
//        if let urlString = urlString {
//            // create NSURL instance
//            if let url = NSURL(string: urlString) {
//                // check if your application can open the NSURL instance
//                print("url valid", UIApplication.shared.canOpenURL(url as URL))
//                return UIApplication.shared.canOpenURL(url as URL)
//            }
//        }
//        return false
//    }
    
    @IBAction func changeIPaddress(_ sender: Any) {
//        if(verifyUrl(urlString: ("http://" + IPaddress.text!)) == false){
//            IPaddress.text! = ip
//            ////ALERT DIALOG BOX
//            // create the alert
//            let alert = UIAlertController(title: "Unreachable IP address", message: "The IP address is unreachable. Check your internet connection and the IP address again.", preferredStyle: UIAlertControllerStyle.alert)
//
//            // add an action (button)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//                action in self.setUpReachability();
//            }))
//            // show the alert
//            self.present(alert, animated: true, completion: nil)
//        }
//        else{
            ip = IPaddress.text!
//        }
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
        else if(reachability.connection == .none){
            ////ALERT DIALOG BOX
            // create the alert
            let alert = UIAlertController(title: "Not connected", message: "Please connect to the internet first", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                action in self.setUpReachability();
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let DestViewController :CameraViewController = segue.destination as! CameraViewController
            DestViewController.IPaddress = ip
            DestViewController.modelname = modelname
            DestViewController.viewAngle = Float(viewAngle)
            DestViewController.photoNumber = Int(photoNumber)
            DestViewController.photoq = photoq
            DestViewController.flashOn = flashOn
            DestViewController.modelq = modelq
            print("Angle ", viewAngle, ", photoNumber ", photoNumber, ", IPaddress ", ip, ", modelname ", modelname)
        }
    }
}
