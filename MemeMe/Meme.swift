//
//  Meme.swift
//  MemeMe
//
//  Created by Wouter de Vos on 2015/09/19.
//  Copyright (c) 2015 Wouter. All rights reserved.
//

import Foundation
import UIKit

class Meme: NSObject {
    var topText : String!
    var bottomText : String!
    var sourceImage : UIImage!
    var targetImage :UIImage!
    
    init(topText : String, bottomText : String, sourceImage : UIImage, targetImage : UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.sourceImage = sourceImage
        self.targetImage = sourceImage
    }
}