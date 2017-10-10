//
//  TheOCR.swift
//  CoreOCR
//
//  Copyright © 2017 DrNeurosurg. All rights reserved.
//

import Foundation
import Vision
import CoreImage
import UIKit
import CoreGraphics

class TheOCR
{
    var ocrRegions:[OCRRegion] = [OCRRegion]()
    var ocrModel = OCR()
    var mloptions = MLPredictionOptions()

    
    init(observation: [VNTextObservation], orgImage:CIImage)
    {
        ocrRegions = [OCRRegion]()
        
        for region:VNTextObservation in observation
        {
            guard let boxesIn = region.characterBoxes else {
                continue
            }

            //Every Region is treated as a "Line"
            
            let line:OCRRegion = OCRRegion()
            if(boxesIn.count > 0)
            {

                for boxrect in boxesIn
                {
                    let ocrChar:OCRchar = OCRchar()
                    ocrChar.orgBox = boxrect.boundingBox
                   
                    //SCALE TO ORGIMAGE
                    ocrChar.scaledBox = scaleRect(orgRect: boxrect.boundingBox, scaleTo: orgImage.extent)
                    line.chars.append(ocrChar)
                }
           
            }
            ocrRegions.insert(line, at: 0)
        }
    }
    
    func scaleRect(orgRect:CGRect, scaleTo:CGRect) -> CGRect
    {
        var scaledRect = CGRect()
        scaledRect.size.width = orgRect.size.width * scaleTo.size.width
        scaledRect.size.height = orgRect.size.height * scaleTo.size.height
        scaledRect.origin.y = (scaleTo.size.height) - (scaleTo.size.height * orgRect.origin.y)
        scaledRect.origin.y = scaledRect.origin.y - scaledRect.size.height
        scaledRect.origin.x = orgRect.origin.x * scaleTo.size.width
        
        return scaledRect
    }
            
    
    func doOCR(orgImage:CIImage, pixelBuffer: CVPixelBuffer)
    {
        var pb:CVPixelBuffer?
        
         mloptions.usesCPUOnly = false;
        for line in self.ocrRegions
        {
            for ocChar in line.chars
            {

                ///CROP + RESCALE + 8BitGray  //TOOOOO SLOOOOW !
                let img:CIImage = orgImage.cropped(to: ocChar.scaledBox)
                let pBuffer:CVPixelBuffer = img.convertToUIImage().pixelBufferGray(width: 28, height: 28)!
                
                //Predict !
                let output:OCROutput  = try! ocrModel.prediction(image: pBuffer )
                ocChar.detectedChar = output.classLabel
                
            }
            line.buildLine()
        }
    }
}
