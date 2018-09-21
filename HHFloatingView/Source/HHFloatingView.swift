//
//  HHFloatingView.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

@objc public protocol HHFloatingViewDatasource {    
    func floatingViewConfiguration(floatingView: HHFloatingView) -> HHFloatingViewConfiguration
}

@objc public protocol HHFloatingViewDelegate {
    func floatingView(floatingView: HHFloatingView, didSelectOption index: Int)
    
    @objc optional func floatingView(floatingView: HHFloatingView, willShowOption index: Int)
    @objc optional func floatingView(floatingView: HHFloatingView, didShowOption index: Int)
    @objc optional func floatingView(floatingView: HHFloatingView, willHideOption index: Int)
    @objc optional func floatingView(floatingView: HHFloatingView, didHideOption index: Int)
}

public final class HHFloatingView: UIView {
    
    //MARK: Datasource/Delegate
    /// Datasource for HHFloatingView.
    public weak var datasource: HHFloatingViewDatasource?
    /// Delegate for HHFloatingView.
    public weak var delegate: HHFloatingViewDelegate?
    /// Check whether HHFloatingView is open or closed.
    public private(set) var isOpen = false
    
    fileprivate var options = [HHFloatingViewButton]()
    fileprivate var openingCenters = [CGPoint]()
    fileprivate var currentButtonIndex = 0
    
    //MARK: Handler Button
    fileprivate var handlerButton: HHFloatingViewButton?
    
    //MARK: Configurations
    fileprivate var configurations: HHFloatingViewConfiguration!
    
    //MARK: Timer
    fileprivate var animationTimer: Timer!

    //MARK: Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Scale Animations
    fileprivate func scaleAnimateButton(button: HHFloatingViewButton?, scaleValue: CGFloat) {
        button?.transform = CGAffineTransform.init(scaleX: scaleValue, y: scaleValue)
    }

    //MARK: Setup
    fileprivate func fetchDatasource() {
        self.configurations = self.datasource?.floatingViewConfiguration(floatingView: self)
    }
    
    fileprivate func updateUI() {
        self.handlerButton?.backgroundColor = self.configurations.handlerColor
        self.handlerButton?.setImage(self.configurations.handlerImage, for: .normal)

        self.options.forEach { (optionButton) in
            optionButton.backgroundColor = configurations.handlerColor
            optionButton.setImage(configurations.handlerImage, for: .normal)
        }
        
        self.calculateOptionButtonsOpeningCenters()
        
        if self.configurations.showScaleAnimation {
            self.scaleAnimateButton(button: self.handlerButton, scaleValue: 0.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            UIView.animate(withDuration: self.configurations.internalAnimationTimerDuration) {
                if self.configurations.showScaleAnimation {
                    self.scaleAnimateButton(button: self.handlerButton, scaleValue: self.configurations.scaleAnimationSize)
                }
            }
        }
    }
    
    fileprivate func setupUI() {
        let superView = self.superview!

        let optionButton = HHFloatingViewButton()
        optionButton.backgroundColor = self.configurations.handlerColor
        optionButton.setImage(self.configurations.handlerImage, for: .normal)
        optionButton.addTarget(self, action: #selector(actionOpenOrCloseOptionsView), for: .touchUpInside)
        optionButton.frame = CGRect.init(origin: CGPoint.zero, size: self.configurations.handlerSize)
        self.dropShadow(onView: optionButton, withRadius: optionButton.layer.cornerRadius, withColor: optionButton.backgroundColor!.cgColor, isHandlerButton: true)
        superView.addSubview(optionButton)
        optionButton.center = self.center
        self.handlerButton = optionButton
        
        if self.configurations.showScaleAnimation {
            self.scaleAnimateButton(button: self.handlerButton, scaleValue: 0.0)
        }

        for index in 0..<self.configurations.numberOfOptions {
            let optionButton = HHFloatingViewButton()
            optionButton.backgroundColor = self.configurations.optionColors[index]
            optionButton.setImage(self.configurations.optionImages[index], for: .normal)
            optionButton.tag = (index + 1)
            optionButton.alpha = 0.0
            optionButton.addTarget(self, action: #selector(actionOptionsTapped), for: .touchUpInside)
            optionButton.frame = CGRect.init(origin: CGPoint.zero, size: configurations.optionsSize)
            self.dropShadow(onView: optionButton, withRadius: optionButton.layer.cornerRadius, withColor: optionButton.backgroundColor!.cgColor, isHandlerButton: false)
            superView.addSubview(optionButton)
            optionButton.center = self.center
            self.options.append(optionButton)
        }

        self.calculateOptionButtonsOpeningCenters()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            UIView.animate(withDuration: self.configurations.internalAnimationTimerDuration) {
                if self.configurations.showScaleAnimation {
                    self.scaleAnimateButton(button: self.handlerButton, scaleValue: self.configurations.scaleAnimationSize)
                }
            }
        }
    }
    
    //MARK: UI Helpers
    fileprivate func dropShadow(onView view: UIView, withRadius radius: CGFloat, withColor color: CGColor, isHandlerButton: Bool) {
        if isHandlerButton {
            if !self.configurations.showShadowInHandlerButton {
                return
            }
        } else {
            if !self.configurations.showShadowInButtons {
                return
            }
        }
        view.layer.masksToBounds = false
        view.layer.shadowColor = color
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowRadius = radius
        view.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }

    //MARK: Animation Open/Close
    fileprivate func resetTimer() {
        self.animationTimer.invalidate()
        self.animationTimer = nil
    }
    
    @objc fileprivate func optionsOpenAnimation() {
        guard self.currentButtonIndex <= self.maxOptions() else {
            self.enableOptionButtons()
            self.resetTimer()
            return
        }

        let optionButton = self.options[self.currentButtonIndex]
        self.delegate?.floatingView?(floatingView: self, willShowOption: optionButton.tag)
        
        let optionButtonCenter = self.openingCenters[self.currentButtonIndex]
        optionButton.alpha = 0.0
        self.scaleAnimateButton(button: optionButton, scaleValue: 0.0)

        UIView.animate(withDuration: self.configurations.internalAnimationTimerDuration, animations: {
            optionButton.alpha = 1.0
            optionButton.center = optionButtonCenter
            self.scaleAnimateButton(button: optionButton, scaleValue: self.configurations.scaleAnimationSize)
        }, completion: { (isCompleted) in
            if isCompleted {
                self.delegate?.floatingView?(floatingView: self, didShowOption: optionButton.tag)
            }
        })
        
        self.currentButtonIndex = self.currentButtonIndex + 1
    }
    
    @objc fileprivate func optionsCloseAnimation() {
        guard self.currentButtonIndex >= 0 else {
            self.enableOptionButtons()
            self.currentButtonIndex = 0
            self.resetTimer()
            return
        }

        let optionButton = self.options[self.currentButtonIndex]
        self.delegate?.floatingView?(floatingView: self, willHideOption: optionButton.tag)
        
        UIView.animate(withDuration: self.configurations.internalAnimationTimerDuration, animations: {
            self.scaleAnimateButton(button: optionButton, scaleValue: self.configurations.scaleAnimationSize)
            optionButton.center = self.center
        }, completion: { (isCompleted) in
            if isCompleted {
                optionButton.alpha = 0.0
                self.delegate?.floatingView?(floatingView: self, didHideOption: optionButton.tag)
            }
        })
        
        self.currentButtonIndex = self.currentButtonIndex - 1
    }
    
    //MARK: UI Helpers
    fileprivate func disableOptionButtons() {
        self.handlerButton?.isUserInteractionEnabled = false
        self.options.forEach { (optionButton) in
            optionButton.isUserInteractionEnabled = false
        }
    }
    
    fileprivate func enableOptionButtons() {
        self.handlerButton?.isUserInteractionEnabled = true
        self.options.forEach { (optionButton) in
            optionButton.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func maxOptions() -> Int {
        return (self.options.count - 1)
    }
    
    //MARK: Calculate Option Buttons Origins
    fileprivate func calculateOptionButtonsOpeningCenters() {
        
        self.openingCenters.removeAll()
        
        var lastCenter: CGPoint = self.center
        let initialMargin: CGFloat = self.configurations.initialMargin
        let internalMargin: CGFloat = self.configurations.internalMargin
        let topButtonSize: CGSize = self.configurations.handlerSize
        let optionsButtonSize: CGSize = self.configurations.optionsSize
        var index: Int = 0
        
        if self.configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.top {
            self.options.forEach({ (optionButton) in
                lastCenter.y -= (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                self.openingCenters.append(lastCenter)
                index += 1
            })
        } else if configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.left {
            self.options.forEach({ (optionButton) in
                lastCenter.x -= (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                self.openingCenters.append(lastCenter)
                index += 1
            })
        } else if configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.right {
            self.options.forEach({ (optionButton) in
                lastCenter.x += (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                self.openingCenters.append(lastCenter)
                index += 1
            })
        } else if configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.bottom {
            self.options.forEach({ (optionButton) in
                lastCenter.y += (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                self.openingCenters.append(lastCenter)
                index += 1
            })
        }
    }
    
    //MARK: Actions
    @objc fileprivate func actionOptionsTapped(sender: HHFloatingViewButton) {
        self.delegate?.floatingView(floatingView: self, didSelectOption: sender.tag)
    }
    
    @objc fileprivate func actionOpenOrCloseOptionsView(sender: HHFloatingViewButton?) {
        self.disableOptionButtons()
        if self.isOpen {
            self.currentButtonIndex = self.maxOptions()
            self.isOpen = false
            self.animationTimer = Timer.scheduledTimer(timeInterval: self.configurations.animationTimerDuration, target: self, selector: #selector(self.optionsCloseAnimation), userInfo: nil, repeats: true)
        } else {
            self.currentButtonIndex = 0
            self.isOpen = true
            self.animationTimer = Timer.scheduledTimer(timeInterval: self.configurations.animationTimerDuration, target: self, selector: #selector(self.optionsOpenAnimation), userInfo: nil, repeats: true)
        }
    }
    
    /// Reload HHFloatingView.
    internal func reload() {
        if self.isDatasourceSet() {
            if self.isDelegateSet() {
                self.fetchDatasource()
                if self.isValidConfiguration() {
                    if (self.handlerButton != nil) {
                        self.updateUI()
                    } else {
                        self.setupUI()
                    }
                }
            }
        }
    }
    
    /// Close HHFloatingView.
    internal func close() {
        if self.isOpen {
            self.actionOpenOrCloseOptionsView(sender: self.handlerButton)
        }
    }
    
    //MARK: Validations
    fileprivate func isDatasourceSet() -> Bool {
        if self.datasource != nil {
            return true
        } else {
            fatalError("HHFloatingView: Datasource should be set.")
        }
    }
    
    fileprivate func isDelegateSet() -> Bool {
        if self.delegate != nil {
            return true
        } else {
            fatalError("HHFloatingView: Delegate should be set.")
        }
    }
    
    fileprivate func isValidConfiguration() -> Bool {
        let isOptionIsNotZero = (self.configurations.numberOfOptions > 0)
        let isOptionsNotEmpty = (!self.configurations.optionImages.isEmpty && !self.configurations.optionColors.isEmpty)
        let isNumberOfOptionsAreEqualsToOptionsImages = (self.configurations.numberOfOptions == self.configurations.optionImages.count)
        let isNumberOfOptionsAreEqualsToOptionsColors = (self.configurations.numberOfOptions == self.configurations.optionColors.count)
        
        if isOptionIsNotZero {
            if (isOptionsNotEmpty && (isNumberOfOptionsAreEqualsToOptionsColors && isNumberOfOptionsAreEqualsToOptionsImages)) {
                return true
            } else {
                fatalError("HHFloatingView: HHFloatingViewConfiguration.optionImages and HHFloatingViewConfiguration.optionColors should be equals to the numberOfOptions.")
            }
        } else {
            fatalError("HHFloatingView: numberOfOptions should not be Zero.")
        }
    }
}
