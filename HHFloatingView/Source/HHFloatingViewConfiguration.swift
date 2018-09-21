//
//  HHFloatingViewConfiguration.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

@objc public enum HHFloatingViewOptionsDisplayDirection: Int {
    case top, left, right, bottom
}

 @objc public class HHFloatingViewConfiguration: NSObject {
    /// Total number of options will be display in HHFloatingView. Default: 0
    public var numberOfOptions: Int = 0
    /// Images to be display for each of the options.
    public var optionImages = [UIImage]()
    /// Colors to be display for each of the options.
    public var optionColors = [UIColor]()
    /// Handler Image to be display for HHFloatingView.
    public var handlerImage = UIImage.init()
    /// Handler Color to be display for HHFloatingView. Default: white
    public var handlerColor = UIColor.white
    /// Position for HHFloatingView. Default: top
    public var optionsDisplayDirection: HHFloatingViewOptionsDisplayDirection = .top
    /// Handler Button Size. Default: 80x80
    public var handlerSize: CGSize = .init(width: 80.0, height: 80.0)
    /// Options Button Size. Default: 60x60
    public var optionsSize: CGSize = .init(width: 60.0, height: 60.0)
    /// Internal Margins. Default: 10.0
    public var internalMargin: CGFloat = 10.0
    /// Initial Margin. Default: 20.0
    public var initialMargin: CGFloat = 20.0
    /// Animation Timer Duration. Default: 0.3
    public var animationTimerDuration: TimeInterval = 0.3
    /// Internal Animation Timer Duration. Default: 0.2
    public var internalAnimationTimerDuration: TimeInterval = 0.2
    /// Show Shadow for Options. Default: false
    public var showShadowInButtons = false
    /// Show Shadow for Handler Button. Default: false
    public var showShadowInHandlerButton = false
    /// Show Scale Animation for Buttons and Handler. Default: false
    public var showScaleAnimation = false
    /// Size for the Scale Animation. Default: 1.0
    public var scaleAnimationSize: CGFloat = 1.0
}
