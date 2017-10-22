//
//  HHFloatingViewConfiguration.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

@objc public enum HHFloatingViewPosition: Int {
    case top, left, right, bottom
}

@objc class HHFloatingViewConfiguration: NSObject {
    var numberOfOptions: Int = 0
    var optionImages = Array<UIImage>()
    var optionColors = Array<UIColor>()
    var handlerImage = UIImage.init()
    var handlerColor = UIColor.white
    var position = HHFloatingViewPosition.top
    var handlerSize = CGSize.init(width: 80.0, height: 80.0)
    var optionsSize = CGSize.init(width: 60.0, height: 60.0)
    var internalMargin: CGFloat = 10.0
    var initialMargin: CGFloat = 20.0
    var animationTimerDuration: TimeInterval = 0.3
    var internalAnimationTimerDuration: TimeInterval = 0.2
}
