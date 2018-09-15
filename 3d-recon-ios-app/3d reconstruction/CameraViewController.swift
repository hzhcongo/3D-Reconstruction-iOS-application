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

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate	 {

    @objc let manager = CMMotionManager()
    @objc var IPaddress = String()
    @objc var modelname = String()
    @objc var viewAngle = Float(1)
    @objc var photoq = Int(0)
    @objc var modelq = Int(0)
    @objc var flashOn = false
    @objc var photoNumber = Int(1)
    @objc var captureSession : AVCaptureSession?
    @objc var capturePhotoOutput : AVCapturePhotoOutput!
//    var stillImageOutput : AVCaptureStillImageOutput?
    @objc var previewLayer : AVCaptureVideoPreviewLayer?
    @objc let appDir = (NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as NSString).appendingPathComponent("/photos")
    @objc var photoName=1
    @objc var currentPhotoName=1
    @objc var photosTaken=0
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var takeTopPhotobtn: UIButton!
    @IBOutlet weak var uploadPhotosbtn: UIButton!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var loaderCircle: UIActivityIndicatorView!
    
    ////FOR UPLOADING
    @objc var url = NSURL(string: "")
    @objc var request = NSMutableURLRequest()
    @objc var boundary = ""
    @objc var body = NSMutableData()
    ////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photoName=1
        currentPhotoName=1
        manager.deviceMotionUpdateInterval=0.2
        
        if FileManager.default.fileExists(atPath: appDir){
            do {
                try FileManager.default.createDirectory(atPath: appDir, withIntermediateDirectories: false, attributes: nil)
            }catch{
                print("Error: filemanager operation has issue")
            }
        }
    
        captureSession = AVCaptureSession()
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled=true
        
        print("Photo quality level is ", photoq)
        print("Model quality level is ", modelq)
        switch(photoq){
        case 0:
            captureSession?.sessionPreset = AVCaptureSession.Preset.cif352x288
        case 1:
            captureSession?.sessionPreset = AVCaptureSession.Preset.vga640x480
        case 2:
            captureSession?.sessionPreset = AVCaptureSession.Preset.hd1280x720
        case 3:
            captureSession?.sessionPreset = AVCaptureSession.Preset.hd1920x1080
//        case 4:
//            captureSession?.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
        default:
            captureSession?.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        /////FOR UPLOADING
        url = NSURL(string: "http://"+IPaddress+":5000/upload")
        request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("Content-Disposition:form-data; name=\"modelname\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(modelname)\r\n".data(using:String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("Content-Disposition:form-data; name=\"quality\"\r\n\r\n".data(using:  String.Encoding.utf8)!)
        body.append("\(modelq)\r\n".data(using:String.Encoding.utf8)!)
        /////
        
        if error == nil && captureSession!.canAddInput(input){
            captureSession!.addInput(input)
            if captureSession!.canAddOutput(capturePhotoOutput){
                captureSession!.addOutput(capturePhotoOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession!.startRunning()
            }
        }
    }
    
    @IBOutlet weak var yaw: UILabel!
    
    @IBOutlet weak var photoProgressBar: UIProgressView!
    @IBOutlet weak var nextDegreeText: UILabel!

    var starttaking = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loaderCircle.isHidden = true;
        
        switch(photoq){
        case 0:
            let xyz = CGRect(x: 0, y: 30, width: 375, height: 605)
            previewLayer!.frame = xyz
        default:
            let xyz = CGRect(x: 0, y: 104, width: 375, height: 461)
            previewLayer!.frame = xyz
        }
        
        ////ALERT DIALOG BOX
        // create the alert
        let alert2 = UIAlertController(title: "Prepare for image-taking", message: "Position the camera at a 20-35 degrees angle and allow as much detail and surface area of the object to be captured. Automatic image-taking will be done after selecting OK.", preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert2.addAction(UIAlertAction(title: "Start", style: UIAlertActionStyle.default, handler: {
            action in self.startTaking();
        }))
        // show the alert
        self.present(alert2, animated: true, completion: nil)
    }

    func startTaking(){
        self.starttaking = true;
        print("viewAngle is ", viewAngle, " and photoNumber is ",photoNumber)
        var nextDegree = viewAngle/Float(photoNumber)
        print("nextDegree is ", nextDegree)
        let interval = nextDegree
        nextDegreeText.text?.removeAll()
        nextDegreeText.text = String(Int(nextDegree))
        
        manager.startDeviceMotionUpdates(to: OperationQueue.current!){
            (data,error) in
            self.yaw.text?.removeAll()
            self.yaw.text = "\(self.degrees(radians: data!.attitude.yaw))"
            var tolerance = Float(1.5);
            if(interval/Float(5)>tolerance){
                tolerance = interval/Float(5)
            }
            if(self.photosTaken == self.photoNumber){
                self.manager.stopDeviceMotionUpdates();
                self.starttaking = false
                
                ////ALERT DIALOG BOX
                // create the alert
                let alert2 = UIAlertController(title: "Top view", message: "Please position the camera above the object and take a photo", preferredStyle: UIAlertControllerStyle.alert)
                // add an action (button)
                alert2.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                // show the alert
                self.present(alert2, animated: true, completion: nil)
                self.takeTopPhotobtn.isHidden = false;
            }
            else if (abs(Float(self.degrees(radians: data!.attitude.yaw))-nextDegree) < tolerance && self.starttaking) {
                self.photoProgressBar.progress = nextDegree/self.viewAngle
                
                if(self.photoName != self.photoNumber){
                    nextDegree = nextDegree + interval
                    self.nextDegreeText.text?.removeAll()
                    self.nextDegreeText.text = String(nextDegree)
                }
                
                let settings = AVCapturePhotoSettings()
                let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
                let previewFormat = [
                    kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                    kCVPixelBufferWidthKey as String: 160,
                    kCVPixelBufferHeightKey as String: 160
                ]
                settings.previewPhotoFormat = previewFormat
                settings.isAutoStillImageStabilizationEnabled = true
                if(self.photoq == 4){
                    settings.isHighResolutionPhotoEnabled = true
                }
                if(self.flashOn){
                    settings.flashMode = .on
                }
                self.capturePhotoOutput.capturePhoto(with: settings, delegate: self)
                self.photosTaken = self.photosTaken + 1;
            }
        }
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
    
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
                    print(UIImage(data: dataImage)?.size as Any)
        
                    let dataProvider = CGDataProvider(data: dataImage as CFData)
                    let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    let image = UIImage(cgImage: cgImageRef, scale: 1, orientation: UIImageOrientation.right)
                    captureImageView.image = image
                    let imageFile = UIImageJPEGRepresentation(image,1)
                    FileManager.default.createFile(atPath: self.appDir.appending("\(self.photoName).jpg"), contents: imageFile, attributes: nil)
                    print("Saved image \(self.photoName)")
            
                    let photoPath = self.appDir.appending("\(self.photoName).jpg")
                    if FileManager.default.fileExists(atPath: photoPath){
                        let image = UIImage(contentsOfFile: photoPath)
                        let imageData = UIImageJPEGRepresentation(image!, 1)
                        
                        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(self.photoName).jpg\"\r\n".data(using: String.Encoding.utf8)!)
                        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
                        body.append(imageData!)
                        body.append("\r\n".data(using: String.Encoding.utf8)!)
                    }
                    else{ print("error finding and coverting image \(self.photoName)") }
            
                    self.photoName += 1
        }
        else {
            print("some error here")
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 160,
                kCVPixelBufferHeightKey as String: 160
            ]
            settings.previewPhotoFormat = previewFormat
            settings.isAutoStillImageStabilizationEnabled = true
            if(self.photoq == 4){
                settings.isHighResolutionPhotoEnabled = true
            }
            if(self.flashOn){
                settings.flashMode = .on
            }
            self.capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    
        }
    }

    @objc func degrees(radians : Double) -> Int{
        if radians>0 {
            return Int(180/Double.pi * radians)
        }
        else{
            return Int(180/Double.pi * radians)+360
        }
    }
    
    @IBAction func takeTopPhoto(_ sender: Any) {
        //TAKE IMAGE
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        settings.isAutoStillImageStabilizationEnabled = true
        if(self.photoq == 4){
            settings.isHighResolutionPhotoEnabled = true
        }
        if(self.flashOn){
            settings.flashMode = .on
        }
        
        self.capturePhotoOutput.capturePhoto(with: settings, delegate: self)
        
        ////ALERT DIALOG BOX
        // create the alert
        let alert = UIAlertController(title: "All images taken", message: "Please  select the 'Upload' button to submit taken images to the web server to generate the model", preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
        self.uploadPhotosbtn.isHidden = false;
        self.takeTopPhotobtn.isHidden = true;
    }
    
    @IBAction func showImage(_ sender: UIButton) {
        let photoPath=appDir.appending("\(self.currentPhotoName).jpg")
        print(photoPath)
        if FileManager.default.fileExists(atPath: photoPath){
            self.captureImageView.image = UIImage(contentsOfFile: photoPath)
            self.currentPhotoName += 1
        }
        else{
            print("No image")
        }
    }
    
    @objc func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    @IBAction func uploadToServer(_ sender: Any) {
        if(photosTaken >= 10){
            
            self.uploadPhotosbtn.isHidden = true;
            self.loaderCircle.isHidden=false;
            self.loaderCircle.startAnimating();
            
            //////////
//            url = NSURL(string: "http://"+IPaddress+"/upload")
//            request = NSMutableURLRequest(url: url! as URL)
//            request.httpMethod = "POST"
//            boundary = generateBoundaryString()
//            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//
//            body.append("Content-Disposition:form-data; name=\"modelname\"\r\n\r\n".data(using: String.Encoding.utf8)!)
//            body.append("\(modelname)\r\n".data(using:String.Encoding.utf8)!)
//            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//
//            body.append("Content-Disposition:form-data; name=\"quality\"\r\n\r\n".data(using:  String.Encoding.utf8)!)
//            body.append("\(modelq)\r\n".data(using:String.Encoding.utf8)!)
//
//            for i in 1...self.photoName{
//                let photoPath = self.appDir.appending("\(i).jpg")
//                if FileManager.default.fileExists(atPath: photoPath){
//                    let image = UIImage(contentsOfFile: photoPath)
//                    let imageData = UIImageJPEGRepresentation(image!, 1)
//
//                    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//                    body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(i).jpg\"\r\n".data(using: String.Encoding.utf8)!)
//                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
//                    body.append(imageData!)
//                    body.append("\r\n".data(using: String.Encoding.utf8)!)
//                }
//            }
//
//            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            ////////////////
            
            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
            request.httpBody = body as Data
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 99999999
            sessionConfig.timeoutIntervalForResource = 99999999
            let session = URLSession(configuration: sessionConfig)
            
            print("start upload")
            let task = session.dataTask(with: request as URLRequest) {
                data, response, error in

                if error != nil {
                    print("error=\(String(describing: error))")
                    print("end")
                }

                print("******* response = \(String(describing: response))")
                ///ALERT DIALOG BOX
                // create the alert
                let alert = UIAlertController(title: "Upload complete", message: "Please view the web app to process the images", preferredStyle: UIAlertControllerStyle.alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                // show the alert
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async { // Correct
                    self.loaderCircle.stopAnimating();
                    self.loaderCircle.isHidden=true;
                    self.captureSession!.stopRunning();
                }
            }
            task.resume()
        }
        else{
            // create the alert
            let alert = UIAlertController(title: "Not enough images", message: "Please take at least 10 images to upload", preferredStyle: UIAlertControllerStyle.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manager.stopDeviceMotionUpdates()
        captureSession!.stopRunning()
        for i in 1...self.photoName{
            let photoPath = self.appDir.appending("\(i).jpg")
            if FileManager.default.fileExists(atPath: photoPath){
                do{
                    try FileManager.default.removeItem(atPath: photoPath)
                }catch{
                    print("Folder deletion not successful")
                }
            }
        }
        print("Done photo deletion")
    }
}
