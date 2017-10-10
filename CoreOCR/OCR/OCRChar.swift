//
//  OCRChar.swift
//  CoreOCR
//
//  Copyright © 2017 DrNeurosurg. All rights reserved.
//

import Foundation
import CoreImage

class OCRchar
{
    var scaledBox: CGRect =  CGRect(x:0, y: 0, width:0, height:0)
    var orgBox: CGRect =  CGRect(x:0, y: 0, width:0, height:0)
    
    var detectedChar: String = ""

}
