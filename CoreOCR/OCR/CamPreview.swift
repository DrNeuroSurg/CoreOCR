//
//  CamPreView.swift
//  CoreOCR
//
//  Copyright © 2017 DrNeurosurg. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import Metal


class CamPreView: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    override var layer: AVCaptureVideoPreviewLayer {
        get {
            return super.layer as! AVCaptureVideoPreviewLayer
        }
    }
}
