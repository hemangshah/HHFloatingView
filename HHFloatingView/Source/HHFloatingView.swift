//
//  HHFloatingView.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

@objc protocol HHFloatingViewDatasource {
    func floatingViewConfiguration(floatingView: HHFloatingView) -> HHFloatingViewConfiguration
}

@objc protocol HHFloatingViewDelegate {
    func floatingView(floatingView: HHFloatingView, tappedAtIndex index: Int)
}

class HHFloatingView: UIView {
    
    //MARK: Datasource/Delegate
    weak var datasource: HHFloatingViewDatasource?
    weak var delegate: HHFloatingViewDelegate?
    
    private(set) var isOpen: Bool = false
        
    fileprivate var options: Array<HHFloatingViewButton> = Array()
    
    fileprivate var openingCenters: Array<CGPoint> = Array()
    
    fileprivate var currentButtonIndex = 0
    
    //MARK: Handler Button
    fileprivate var handlerButton: HHFloatingViewButton?
    
    //MARK: Configurations
    fileprivate var configurations: HHFloatingViewConfiguration!
    
    //MARK: Timer
    fileprivate var animationTimer: Timer!

    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Setup
    fileprivate func fetchDatasource() {
        self.configurations = self.datasource?.floatingViewConfiguration(floatingView: self)
    }
    
    fileprivate func updateUI() {
        
        //Case: Reload
        
        //Update UI for Handler Button
        self.handlerButton?.backgroundColor = configurations.handlerColor
        self.handlerButton?.setImage(configurations.handlerImage, for: .normal)
        
        //Update UI for Option Button
        self.options.forEach { (optionButton) in
            optionButton.backgroundColor = configurations.handlerColor
            optionButton.setImage(configurations.handlerImage, for: .normal)
        }
        
        self.calculateOptionButtonsOpeningCenters()
    }
    
    fileprivate func setupUI() {
        let superView = self.superview!
        
        //Add Handler Button
        let optionButton = HHFloatingViewButton()
        optionButton.backgroundColor = configurations.handlerColor
        optionButton.setImage(configurations.handlerImage, for: .normal)
        optionButton.addTarget(self, action: #selector(actionOpenOrCloseOptionsView), for: .touchUpInside)
        optionButton.frame = CGRect.init(origin: CGPoint.zero, size: configurations.handlerSize)
        self.dropShadow(onView: optionButton, withRadius: optionButton.layer.cornerRadius, withColor: optionButton.backgroundColor!.cgColor)
        superView.addSubview(optionButton)
        optionButton.center = self.center
        self.handlerButton = optionButton
        
        //Add Option Buttons
        for index in 0..<self.configurations.numberOfOptions {
            let optionButton = HHFloatingViewButton()
            optionButton.backgroundColor = configurations.optionColors[index]
            optionButton.setImage(configurations.optionImages[index], for: .normal)
            optionButton.tag = (index + 1)
            optionButton.alpha = 0.0
            optionButton.addTarget(self, action: #selector(actionOptionsTapped), for: .touchUpInside)
            optionButton.frame = CGRect.init(origin: CGPoint.zero, size: configurations.optionsSize)
            self.dropShadow(onView: optionButton, withRadius: optionButton.layer.cornerRadius, withColor: optionButton.backgroundColor!.cgColor)
            superView.addSubview(optionButton)
            optionButton.center = self.center
            self.options.append(optionButton)
        }
        
        //Calculate the Opening positions for the buttons.
        self.calculateOptionButtonsOpeningCenters()
    }
    
    //MARK: UI Helpers
    func dropShadow(onView view: UIView, withRadius radius: CGFloat, withColor color: CGColor) {
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
    @objc internal func optionsOpenAnimation() {
        
        //Handling Timer.
        guard self.currentButtonIndex <= self.maxOptions() else {
            self.enableOptionButtons()
            self.animationTimer.invalidate()
            self.animationTimer = nil
            return
        }
        
        //Get the current Button.
        let optionButton = self.options[self.currentButtonIndex]
        let optionButtonCenter = self.openingCenters[self.currentButtonIndex]
        optionButton.alpha = 0.0
        
        UIView.animate(withDuration: self.configurations.internalAnimationTimerDuration, animations: {
            optionButton.alpha = 1.0
            optionButton.center = optionButtonCenter
        }, completion: { (isCompleted) in
            if isCompleted {
                
            }
        })
        
        self.currentButtonIndex = self.currentButtonIndex + 1
    }
    
    @objc internal func optionsCloseAnimation() {
        
        //Handling Timer.
        guard self.currentButtonIndex >= 0 else {
            self.enableOptionButtons()
            self.currentButtonIndex = 0
            self.animationTimer.invalidate()
            self.animationTimer = nil
            return
        }
        
        //Get the current Button.
        let optionButton = self.options[self.currentButtonIndex]
        
        UIView.animate(withDuration: self.configurations.internalAnimationTimerDuration, animations: {
            optionButton.alpha = 0.0
            optionButton.center = self.center
        }, completion: { (isCompleted) in
            if isCompleted {
                
            }
        })
        
        self.currentButtonIndex = self.currentButtonIndex - 1
    }
    
    //MARK: UI Helpers
    fileprivate func disableOptionButtons() {

        if (self.handlerButton != nil) {
            self.handlerButton?.isUserInteractionEnabled = false
        }
        
        self.options.forEach { (optionButton) in
            optionButton.isUserInteractionEnabled = false
        }
    }
    
    fileprivate func enableOptionButtons() {
        
        if (self.handlerButton != nil) {
            self.handlerButton?.isUserInteractionEnabled = true
        }
        
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
        
        var lastCenter = self.center
        let initialMargin: CGFloat = self.configurations.initialMargin
        let internalMargin: CGFloat = self.configurations.internalMargin
        let topButtonSize = self.configurations.handlerSize
        let optionsButtonSize = self.configurations.optionsSize
        var index = 0
        
        if self.configurations.position == HHFloatingViewPosition.top {

            self.options.forEach({ (optionButton) in
                if index == 0 {
                    lastCenter.y -= (topButtonSize.height + initialMargin)
                } else {
                    lastCenter.y -= (optionsButtonSize.height + internalMargin)
                }
                self.openingCenters.append(lastCenter)
                index += 1
            })
            
        } else if configurations.position == HHFloatingViewPosition.left {
            
            self.options.forEach({ (optionButton) in
                if index == 0 {
                    lastCenter.x -= (topButtonSize.height + initialMargin)
                } else {
                    lastCenter.x -= (optionsButtonSize.height + internalMargin)
                }
                self.openingCenters.append(lastCenter)
                index += 1
            })
            
        } else if configurations.position == HHFloatingViewPosition.right {
            
            self.options.forEach({ (optionButton) in
                if index == 0 {
                    lastCenter.x += (topButtonSize.height + initialMargin)
                } else {
                    lastCenter.x += (optionsButtonSize.height + internalMargin)
                }
                self.openingCenters.append(lastCenter)
                index += 1
            })
            
        } else if configurations.position == HHFloatingViewPosition.bottom {
            
            self.options.forEach({ (optionButton) in
                if index == 0 {
                    lastCenter.y += (topButtonSize.height + initialMargin)
                } else {
                    lastCenter.y += (optionsButtonSize.height + internalMargin)
                }
                self.openingCenters.append(lastCenter)
                index += 1
            })
            
        }
        
    }
    
    //MARK: Actions
    @objc fileprivate func actionOptionsTapped(sender: HHFloatingViewButton) {
        self.delegate?.floatingView(floatingView: self, tappedAtIndex: sender.tag)
    }
    
    @objc fileprivate func actionOpenOrCloseOptionsView(sender: HHFloatingViewButton) {
        
        self.disableOptionButtons()
        
        if self.isOpen {
            
            self.currentButtonIndex = maxOptions()
            self.isOpen = false
            self.animationTimer = Timer.scheduledTimer(timeInterval: configurations.animationTimerDuration, target: self, selector: #selector(optionsCloseAnimation), userInfo: nil, repeats: true)
            
        } else {
            
            self.currentButtonIndex = 0
            self.isOpen = true
            self.animationTimer = Timer.scheduledTimer(timeInterval: configurations.animationTimerDuration, target: self, selector: #selector(optionsOpenAnimation), userInfo: nil, repeats: true)
        }
    }
    
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
    
    internal func close() {
        if self.isOpen {
            self.actionOpenOrCloseOptionsView(sender: self.handlerButton!)
        }
    }
    
    //MARK: Validations
    fileprivate func isDatasourceSet() -> Bool {
        if self.datasource != nil {
            return true
        } else {
            fatalError("HHFloatingView: Datasource can't be empty.")
        }
    }
    
    fileprivate func isDelegateSet() -> Bool {
        if self.delegate != nil {
            return true
        } else {
            fatalError("HHFloatingView: Delegate can't be empty.")
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
