//
//  BaseViewController.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    //Initialize HHFloatingView
    fileprivate var floatingView: HHFloatingView = {
        let floatingViewSize: CGFloat = 100.0
        let padding: CGFloat = 10.0
        let fv = HHFloatingView.init(frame: CGRect.init(origin: CGPoint.init(x: UIScreen.main.bounds.size.width - (floatingViewSize + padding), y: UIScreen.main.bounds.size.height - (floatingViewSize + padding)), size: CGSize.init(width: floatingViewSize, height: floatingViewSize)))
        return fv
    }()
    
    //MARK: Add Floating View.
    internal func addFloatingView() {
        self.floatingView.delegate = self
        self.floatingView.datasource = self
        self.view.addSubview(self.floatingView)
        self.floatingView.reload()
    }
}

//MARK: HHFloatingViewDatasource
extension BaseViewController: HHFloatingViewDatasource {
    func floatingViewConfiguration(floatingView: HHFloatingView) -> HHFloatingViewConfiguration {
        let configure = HHFloatingViewConfiguration.init()
        configure.animationTimerDuration = 0.3
        configure.internalAnimationTimerDuration = 0.2
        configure.position = .top
        configure.numberOfOptions = 5
        configure.handlerSize = CGSize.init(width: 90.0, height: 90.0)
        configure.optionsSize = CGSize.init(width: 60.0, height: 60.0)
        configure.initialMargin = 20.0
        configure.internalMargin = 10.0
        configure.handlerImage = #imageLiteral(resourceName: "icon-bird")
        configure.handlerColor = UIColor.blue.withAlphaComponent(0.5)
        configure.optionImages = [#imageLiteral(resourceName: "icon-ufo"), #imageLiteral(resourceName: "icon-gift"), #imageLiteral(resourceName: "icon-megaphone"), #imageLiteral(resourceName: "icon-rocket"), #imageLiteral(resourceName: "icon-umbrella")]
        configure.optionColors = [UIColor.red.withAlphaComponent(0.5),
                                  UIColor.purple.withAlphaComponent(0.5),
                                  UIColor.blue.withAlphaComponent(0.5),
                                  UIColor.cyan.withAlphaComponent(0.5),
                                  UIColor.magenta.withAlphaComponent(0.5)]
        configure.showShadowInButtons = false
        configure.showShadowInHandlerButton = false
        return configure
    }
}

//MARK: HHFloatingViewDelegate
extension BaseViewController: HHFloatingViewDelegate {
    func floatingView(floatingView: HHFloatingView, didSelectOption index: Int) {
        print("HHFloatingView: Button Selected: \(index)")
        self.floatingView.close()
    }
}
