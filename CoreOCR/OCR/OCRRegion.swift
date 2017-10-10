//
//  OCRLine.swift
//  CoreOCR
//
//  Copyright © 2017 DrNeurosurg. All rights reserved.
//

import Foundation

class OCRRegion:NSObject
{
    var chars:[OCRchar] = [OCRchar]()
    var regionString: String = ""
    
    override init() {
        
        super.init()
        regionString = ""
    }
    
    func buildLine()
    {
        regionString = ""
        for s in chars
        {
            regionString = regionString.appending(s.detectedChar)
        }
    }
    
}
