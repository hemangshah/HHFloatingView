//
//  BaseViewController.swift
//  HHFloatingView
//
//  Created by Hemang Shah on 10/18/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    //Image Icons for HHFloatingView
    fileprivate var floatingViewOptionsImages: Array<UIImage> = []
    //Colors for HHFloatingView
    fileprivate var floatingViewOptionsColors: Array<UIColor> = []
    //Initialize HHFloatingView
    fileprivate var floatingView: HHFloatingView = {
        let floatingViewSize: CGFloat = 100.0
        let padding: CGFloat = 10.0
        let fv = HHFloatingView.init(frame: CGRect.init(origin: CGPoint.init(x: UIScreen.main.bounds.size.width - (floatingViewSize + padding), y: UIScreen.main.bounds.size.height - (floatingViewSize + padding)), size: CGSize.init(width: floatingViewSize, height: floatingViewSize)))
        return fv
    }()
    
    //MARK: Add Floating View.
    internal func addFloatingView() {
        
        let fv = self.floatingView
        fv.delegate = self
        fv.datasource = self
        self.view.addSubview(floatingView)
        
        //Add Image Icons
        self.floatingViewOptionsImages.append(#imageLiteral(resourceName: "icon-ufo"))
        self.floatingViewOptionsImages.append(#imageLiteral(resourceName: "icon-gift"))
        self.floatingViewOptionsImages.append(#imageLiteral(resourceName: "icon-megaphone"))
        self.floatingViewOptionsImages.append(#imageLiteral(resourceName: "icon-rocket"))
        self.floatingViewOptionsImages.append(#imageLiteral(resourceName: "icon-umbrella"))
        
        //Add Colors
        self.floatingViewOptionsColors.append(UIColor.red.withAlphaComponent(0.5))
        self.floatingViewOptionsColors.append(UIColor.purple.withAlphaComponent(0.5))
        self.floatingViewOptionsColors.append(UIColor.blue.withAlphaComponent(0.5))
        self.floatingViewOptionsColors.append(UIColor.cyan.withAlphaComponent(0.5))
        self.floatingViewOptionsColors.append(UIColor.magenta.withAlphaComponent(0.5))
        
        self.floatingView.reload()
    }
}

extension BaseViewController: HHFloatingViewDatasource {
    func floatingViewConfiguration(floatingView: HHFloatingView) -> HHFloatingViewConfiguration {
        let configure = HHFloatingViewConfiguration.init()
        configure.optionColors = self.floatingViewOptionsColors
        configure.optionImages = self.floatingViewOptionsImages
        configure.handlerImage = #imageLiteral(resourceName: "icon-bird")
        configure.handlerColor = UIColor.blue.withAlphaComponent(0.5)
        configure.position = .top
        configure.numberOfOptions = 5
        configure.handlerSize = CGSize.init(width: 90.0, height: 90.0)
        configure.optionsSize = CGSize.init(width: 70.0, height: 70.0)
        configure.initialMargin = 20.0
        configure.internalMargin = 10.0
        configure.animationTimerDuration = 0.3
        configure.internalAnimationTimerDuration = 0.2
        return configure
    }
}

extension BaseViewController: HHFloatingViewDelegate {
    func floatingView(floatingView: HHFloatingView, tappedAtIndex index: Int) {
        self.floatingView.close()
    }
}
