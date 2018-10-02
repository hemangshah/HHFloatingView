//
//  HHFloatingView.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

public protocol HHFloatingViewDatasource: class {
    func floatingViewConfiguration(floatingView: HHFloatingView) -> HHFloatingViewConfiguration
}

public protocol HHFloatingViewDelegate: class {
    func floatingView(floatingView: HHFloatingView, didSelectOption index: Int)
    
    func floatingView(floatingView: HHFloatingView, willShowOption index: Int)
    func floatingView(floatingView: HHFloatingView, didShowOption index: Int)
    func floatingView(floatingView: HHFloatingView, willHideOption index: Int)
    func floatingView(floatingView: HHFloatingView, didHideOption index: Int)
}

public extension HHFloatingViewDelegate {
    func floatingView(floatingView: HHFloatingView, willShowOption index: Int) {}
    func floatingView(floatingView: HHFloatingView, didShowOption index: Int) {}
    func floatingView(floatingView: HHFloatingView, willHideOption index: Int) {}
    func floatingView(floatingView: HHFloatingView, didHideOption index: Int) {}
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
        configurations = datasource?.floatingViewConfiguration(floatingView: self)
    }
    
    fileprivate func updateUI() {
        handlerButton?.backgroundColor = configurations.handlerColor
        handlerButton?.setImage(configurations.handlerImage, for: .normal)

        self.options.forEach { (optionButton) in
            optionButton.backgroundColor = configurations.handlerColor
            optionButton.setImage(configurations.handlerImage, for: .normal)
        }
        
        calculateOptionButtonsOpeningCenters()
        
        if configurations.showScaleAnimation {
            scaleAnimateButton(button: handlerButton, scaleValue: 0.0)
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
        optionButton.backgroundColor = configurations.handlerColor
        optionButton.setImage(configurations.handlerImage, for: .normal)
        optionButton.addTarget(self, action: #selector(actionOpenOrCloseOptionsView), for: .touchUpInside)
        optionButton.frame = CGRect.init(origin: CGPoint.zero, size: configurations.handlerSize)
        self.dropShadow(onView: optionButton, withRadius: optionButton.layer.cornerRadius, withColor: optionButton.backgroundColor!.cgColor, isHandlerButton: true)
        superView.addSubview(optionButton)
        optionButton.center = self.center
        handlerButton = optionButton
        
        if configurations.showScaleAnimation {
            scaleAnimateButton(button: handlerButton, scaleValue: 0.0)
        }

        for index in 0..<configurations.numberOfOptions {
            let optionButton = HHFloatingViewButton()
            optionButton.backgroundColor = configurations.optionColors[index]
            optionButton.setImage(configurations.optionImages[index], for: .normal)
            optionButton.tag = (index + 1)
            optionButton.alpha = 0.0
            optionButton.addTarget(self, action: #selector(actionOptionsTapped), for: .touchUpInside)
            optionButton.frame = CGRect.init(origin: CGPoint.zero, size: configurations.optionsSize)
            self.dropShadow(onView: optionButton, withRadius: optionButton.layer.cornerRadius, withColor: optionButton.backgroundColor!.cgColor, isHandlerButton: false)
            superView.addSubview(optionButton)
            optionButton.center = self.center
            options.append(optionButton)
        }

        calculateOptionButtonsOpeningCenters()
        
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
            if !configurations.showShadowInHandlerButton {
                return
            }
        } else {
            if !configurations.showShadowInButtons {
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
        animationTimer.invalidate()
        animationTimer = nil
    }
    
    @objc fileprivate func optionsOpenAnimation() {
        guard currentButtonIndex <= maxOptions() else {
            enableOptionButtons()
            resetTimer()
            return
        }

        let optionButton = options[currentButtonIndex]
        delegate?.floatingView(floatingView: self, willShowOption: optionButton.tag)
        
        let optionButtonCenter = openingCenters[currentButtonIndex]
        optionButton.alpha = 0.0
        scaleAnimateButton(button: optionButton, scaleValue: 0.0)

        UIView.animate(withDuration: configurations.internalAnimationTimerDuration, animations: {
            optionButton.alpha = 1.0
            optionButton.center = optionButtonCenter
            self.scaleAnimateButton(button: optionButton, scaleValue: self.configurations.scaleAnimationSize)
        }, completion: { (isCompleted) in
            if isCompleted {
                self.delegate?.floatingView(floatingView: self, didShowOption: optionButton.tag)
            }
        })
        
        currentButtonIndex += 1
    }
    
    @objc fileprivate func optionsCloseAnimation() {
        guard currentButtonIndex >= 0 else {
            enableOptionButtons()
            currentButtonIndex = 0
            resetTimer()
            return
        }

        let optionButton = options[currentButtonIndex]
        delegate?.floatingView(floatingView: self, willHideOption: optionButton.tag)
        
        UIView.animate(withDuration: configurations.internalAnimationTimerDuration, animations: {
            self.scaleAnimateButton(button: optionButton, scaleValue: self.configurations.scaleAnimationSize)
            optionButton.center = self.center
        }, completion: { (isCompleted) in
            if isCompleted {
                optionButton.alpha = 0.0
                self.delegate?.floatingView(floatingView: self, didHideOption: optionButton.tag)
            }
        })
        
        currentButtonIndex -= 1
    }
    
    //MARK: UI Helpers
    fileprivate func disableOptionButtons() {
        handlerButton?.isUserInteractionEnabled = false
        _ = options.map{ $0.isUserInteractionEnabled = false }
    }
    
    fileprivate func enableOptionButtons() {
        handlerButton?.isUserInteractionEnabled = true
        _ = options.map{ $0.isUserInteractionEnabled = true }
    }
    
    fileprivate func maxOptions() -> Int {
        return (options.count - 1)
    }
    
    //MARK: Calculate Option Buttons Origins
    fileprivate func calculateOptionButtonsOpeningCenters() {
        
        openingCenters.removeAll()
        
        var lastCenter: CGPoint = center
        let initialMargin: CGFloat = configurations.initialMargin
        let internalMargin: CGFloat = configurations.internalMargin
        let topButtonSize: CGSize = configurations.handlerSize
        let optionsButtonSize: CGSize = configurations.optionsSize
        var index: Int = 0
        
        if configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.top {
            self.options.forEach({ (optionButton) in
                lastCenter.y -= (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                openingCenters.append(lastCenter)
                index += 1
            })
        } else if configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.left {
            self.options.forEach({ (optionButton) in
                lastCenter.x -= (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                openingCenters.append(lastCenter)
                index += 1
            })
        } else if configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.right {
            self.options.forEach({ (optionButton) in
                lastCenter.x += (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                openingCenters.append(lastCenter)
                index += 1
            })
        } else if configurations.optionsDisplayDirection == HHFloatingViewOptionsDisplayDirection.bottom {
            self.options.forEach({ (optionButton) in
                lastCenter.y += (index == 0) ? (topButtonSize.height + initialMargin) : (optionsButtonSize.height + internalMargin)
                openingCenters.append(lastCenter)
                index += 1
            })
        }
    }
    
    //MARK: Actions
    @objc fileprivate func actionOptionsTapped(sender: HHFloatingViewButton) {
        delegate?.floatingView(floatingView: self, didSelectOption: sender.tag)
    }
    
    @objc fileprivate func actionOpenOrCloseOptionsView(sender: HHFloatingViewButton?) {
        disableOptionButtons()
        if isOpen {
            currentButtonIndex = maxOptions()
            isOpen = false
            animationTimer = Timer.scheduledTimer(timeInterval: configurations.animationTimerDuration, target: self, selector: #selector(self.optionsCloseAnimation), userInfo: nil, repeats: true)
        } else {
            currentButtonIndex = 0
            isOpen = true
            animationTimer = Timer.scheduledTimer(timeInterval: configurations.animationTimerDuration, target: self, selector: #selector(self.optionsOpenAnimation), userInfo: nil, repeats: true)
        }
    }
    
    /// Reload HHFloatingView.
    public func reload() {
        if isDatasourceSet() {
            if isDelegateSet() {
                fetchDatasource()
                if isValidConfiguration() {
                    if (handlerButton != nil) {
                        updateUI()
                    } else {
                        setupUI()
                    }
                }
            }
        }
    }
    
    /// Close HHFloatingView.
    public func close() {
        if isOpen {
            actionOpenOrCloseOptionsView(sender: handlerButton)
        }
    }
    
    //MARK: Validations
    fileprivate func isDatasourceSet() -> Bool {
        if datasource != nil {
            return true
        } else {
            fatalError("HHFloatingView: Datasource should be set.")
        }
    }
    
    fileprivate func isDelegateSet() -> Bool {
        if delegate != nil {
            return true
        } else {
            fatalError("HHFloatingView: Delegate should be set.")
        }
    }
    
    fileprivate func isValidConfiguration() -> Bool {
        let isOptionIsNotZero = (configurations.numberOfOptions > 0)
        let isOptionsNotEmpty = (!configurations.optionImages.isEmpty && !configurations.optionColors.isEmpty)
        let isNumberOfOptionsAreEqualsToOptionsImages = (configurations.numberOfOptions == configurations.optionImages.count)
        let isNumberOfOptionsAreEqualsToOptionsColors = (configurations.numberOfOptions == configurations.optionColors.count)
        
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
