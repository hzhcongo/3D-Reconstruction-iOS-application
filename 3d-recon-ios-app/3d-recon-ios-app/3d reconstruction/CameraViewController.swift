//
//  CameraViewController.swift
//  3d reconstruction
//
//  Created by jiasheng on 31/1/17.
//  Copyright © 2017 jiasheng. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate	 {

    let manager = CMMotionManager()
    var IPaddress = String()
    var viewAngle = Float(1)
    var photoq = Int(0)
    var flashOn = false
    var photoNumber = Int(1)
    var captureSession : AVCaptureSession?
    var capturePhotoOutput : AVCapturePhotoOutput!
//    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    let appDir = (NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as NSString).appendingPathComponent("/photos")
    var photoName=1
    var currentPhotoName=1
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var captureImageView: UIImageView!
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
        
        print("the photo quality level is ", photoq)
        switch(photoq){
        case 0:
            captureSession?.sessionPreset = AVCaptureSessionPreset352x288
        case 1:
            captureSession?.sessionPreset = AVCaptureSessionPreset640x480
        case 2:
            captureSession?.sessionPreset = AVCaptureSessionPreset1280x720
        case 3:
            captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        case 4:
            captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
            
        default:
            captureSession?.sessionPreset = AVCaptureSessionPreset1280x720
        }
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && captureSession!.canAddInput(input){
            captureSession!.addInput(input)
//            stillImageOutput = AVCaptureStillImageOutput()
//            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(capturePhotoOutput){
                captureSession!.addOutput(capturePhotoOutput)
//            if captureSession!.canAddOutput(stillImageOutput){
//                captureSession!.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                captureSession!.startRunning()
            }
        }
        

    }
    
//    @IBOutlet weak var pitch: UILabel!
    @IBOutlet weak var yaw: UILabel!
//    @IBOutlet weak var roll: UILabel!
    
    @IBOutlet weak var photoProgressBar: UIProgressView!
    @IBOutlet weak var nextDegreeText: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = cameraView.bounds
        
        print("viewAngle is ", viewAngle, " and photoNumber is ",photoNumber)
        var nextDegree = viewAngle/Float(photoNumber)
        print("nextDegree is ", nextDegree)
        let interval = nextDegree
        nextDegreeText.text = String(Int(nextDegree))
        

        
        manager.startDeviceMotionUpdates(to: OperationQueue.current!){
            (data,error) in
//            self.pitch.text = "\(self.degrees(radians: data!.attitude.pitch))"
            self.yaw.text = "\(self.degrees(radians: data!.attitude.yaw))"
//            self.roll.text = "\(self.degrees(radians: data!.attitude.roll))"
            var tolerance = Float(1.5);
            if(interval/Float(5)>tolerance){
                tolerance = interval/Float(5)
            }
            if (abs(Float(self.degrees(radians: data!.attitude.yaw))-nextDegree) < tolerance) {
                self.photoProgressBar.progress = nextDegree/self.viewAngle
                nextDegree = nextDegree + interval
                self.nextDegreeText.text = String(nextDegree)
                
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
//                if let videoConnection = self.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
//                    self.stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) in
//                        if sampleBuffer != nil {
//                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//                            let dataProvider = CGDataProvider.init(data: imageData as! CFData)
//                            let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
//                            
//                            let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
//                            self.captureImageView.image = image
//                            let imageFile = UIImageJPEGRepresentation(image,1)
//                            FileManager.default.createFile(atPath: self.appDir.appending("\(self.photoName).jpg"), contents: imageFile, attributes: nil)
//                            self.photoName += 1
//                        }
//                    })
                }
            }
        }
//    }


    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    
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
                    self.photoName += 1
                } else {
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

    func degrees(radians : Double) -> Int{
        if radians>0 {
            return Int(180/M_PI * radians)
        }
        else{
            return Int(180/M_PI * radians)+360
        }
        
    }
    @IBAction func showImage(_ sender: UIButton) {
        let photoPath=appDir.appending("\(self.currentPhotoName).jpg")
        if FileManager.default.fileExists(atPath: photoPath){
            self.captureImageView.image = UIImage(contentsOfFile: photoPath)
            self.currentPhotoName += 1
        }else{
            print("No image")
        }
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    @IBAction func uploadToServer(_ sender: UIButton) {
        let url = NSURL(string: "http://"+IPaddress+"/upload")
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using:String.Encoding.utf8)!)
        
        for i in 1...self.photoName{
            let photoPath = self.appDir.appending("\(i).jpg")
            if FileManager.default.fileExists(atPath: photoPath){
                let image = UIImage(contentsOfFile: photoPath)
                let imageData = UIImageJPEGRepresentation(image!, 1)
 
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(i).jpg\"\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(imageData!)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("******* response = \(response)")
            
        }
        
        task.resume()
        self.performSegue(withIdentifier: "backMain", sender: nil)
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
//        if let videoConnection = self.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
//            self.stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) in
//                if sampleBuffer != nil {
//                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//                    let dataProvider = CGDataProvider.init(data: imageData as! CFData)
//                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
//                    
//                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
//                    self.captureImageView.image = image
//                    let imageFile = UIImageJPEGRepresentation(image,1)
//                    FileManager.default.createFile(atPath: self.appDir.appending("\(self.photoName).jpg"), contents: imageFile, attributes: nil)
//                    self.photoName += 1
//                }
//            })
//        }
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
