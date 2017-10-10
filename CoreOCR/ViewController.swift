//
//  ViewController.swift
//  CoreOCR
//
//  Copyright © 2017 DrNeurosurg. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import Metal

class ViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate {

    
    var cameraView: CamPreView!
    let session = AVCaptureSession()
    var videoDevice:AVCaptureDevice?
    let sessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    let detector = OCRTextDetector()
    var ocr:TheOCR?
    var label:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupVideo()

    }
    
    //AS USUAL
    func setupVideo()
    {
        cameraView = CamPreView()
        view = cameraView
        
        session.beginConfiguration()
        
        // Choose the back dual camera if available, otherwise default to a wide angle camera.
        if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            self.videoDevice = dualCameraDevice
        } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            // If the back dual camera is not available, default to the back wide angle camera.
            self.videoDevice = backCameraDevice
        } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            /*
             In some cases where users break their phones, the back wide angle camera is not available.
             In this case, we should default to the front wide angle camera.
             */
            self.videoDevice = frontCameraDevice
        }
        
        if (self.videoDevice != nil) {
            let videoDeviceInput = try? AVCaptureDeviceInput(device: self.videoDevice!)
            
            if (videoDeviceInput != nil) {
                if (session.canAddInput(videoDeviceInput!)) {
                    session.addInput(videoDeviceInput!)
                }
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            
            if (session.canAddOutput(dataOutput)) {
                session.addOutput(dataOutput)
                dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
                dataOutput.alwaysDiscardsLateVideoFrames = true
                let queue = DispatchQueue(label: "de.DrNeurosurg.videosamplequeue")
                dataOutput.setSampleBufferDelegate(self, queue: queue)
                
            }
            
        }
        
        // HERE CHOOSE YOUR PRESET
        session.sessionPreset = AVCaptureSession.Preset.iFrame960x540
        //session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        //session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        //session.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
        
        session.commitConfiguration()
        
        
        cameraView.layer.session = session
        cameraView.layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.layer.connection?.videoOrientation = .landscapeRight

        setupLabel()

    }
    
    func setupLabel()
    {
        label = UILabel(frame: CGRect(x:0, y:0, width: 1, height: 1))
        label?.backgroundColor = UIColor.clear
        
        label?.font = UIFont.boldSystemFont(ofSize: 20.0)
        label?.numberOfLines = 30 //SHOULD BE ENOUGH
        label?.textColor = UIColor.green
        
        label?.text = ""
        
        self.cameraView.addSubview(label!)
    }
    
    
    // DO IT ON MAIN !!
    func setLabelText(ocrRegions: [OCRRegion])
    {
        if(ocrRegions.count > 0)
        {
            DispatchQueue.main.async {
                self.label?.text = ""
                for line in ocrRegions
                {
                    self.label?.text = self.label?.text?.appending(line.regionString)
                    self.label?.text = self.label?.text?.appending("\n")
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.label?.text = ""
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        // Get CVPixelBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // make CIImage
        let orgImage:CIImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        //TEXT - DETECTION
        let result = detector.detectText(ciImage: orgImage)
        
        //Prepare for OCR
        let ocr = TheOCR(observation: result, orgImage: orgImage)
        
        //DO THE OCR !
        ocr.doOCR(orgImage: orgImage, pixelBuffer: pixelBuffer)
        setLabelText(ocrRegions: ocr.ocrRegions)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            self.session.stopRunning()
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView?.frame = view.frame
        label?.frame = view.frame
        label?.textAlignment = .center
        label?.layer.zPosition = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

