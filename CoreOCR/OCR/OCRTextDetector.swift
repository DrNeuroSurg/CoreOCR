//
//  TextDetector.swift
//  CoreOCR
//
//  Copyright © 2017 DrNeurosurg. All rights reserved.
//

import Foundation
import Vision
import CoreImage
import UIKit

class OCRTextDetector
{
    var requests = [VNRequest]()
    var result:[VNTextObservation]?
    
    func detectText(ciImage: CIImage) -> [VNTextObservation]
    {
        var result:[VNTextObservation]?
        let requestOptions:[VNImageOption : Any] = [:]
        
        //CGImagePropertyOrientation(rawValue: 4)  4 -> LandscapeRight (HomeButton on the right)
        
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: 4)!, options: requestOptions)
        let request:VNDetectTextRectanglesRequest = VNDetectTextRectanglesRequest.init(completionHandler: { (request, error) in
            if( (error) != nil){
                print("Got Error In Run Text Dectect Request");
                
            }else{
                guard let observations = request.results else {print("no result"); return}
                
                result = observations.map({($0 as? VNTextObservation)!})
            }
            
        })
        
        request.reportCharacterBoxes = true
        request.preferBackgroundProcessing = false
        do {
            try handler.perform([request])
            return result!;
        } catch {
            return result!;
        }
    }
    
}
