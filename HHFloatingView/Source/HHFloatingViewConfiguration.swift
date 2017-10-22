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

 @objc public class HHFloatingViewConfiguration: NSObject {
    public var numberOfOptions: Int = 0
    public var optionImages: Array<UIImage> = []
    public var optionColors: Array<UIColor> = []
    public var handlerImage: UIImage = UIImage.init()
    public var handlerColor: UIColor = UIColor.white
    public var position: HHFloatingViewPosition = .top
    public var handlerSize: CGSize = .init(width: 80.0, height: 80.0)
    public var optionsSize: CGSize = .init(width: 60.0, height: 60.0)
    public var internalMargin: CGFloat = 10.0
    public var initialMargin: CGFloat = 20.0
    public var animationTimerDuration: TimeInterval = 0.3
    public var internalAnimationTimerDuration: TimeInterval = 0.2
    public var showShadowInButtons: Bool = true
    public var showShadowInHandlerButton: Bool = true
}
