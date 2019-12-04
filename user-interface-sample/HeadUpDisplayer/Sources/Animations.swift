//
//  Animations.swift
//  HeadUpDisplayer
//
//  Created by dumbass.cn on 9/26/19.
//  Copyright © 2019 dumbass.cn. All rights reserved.
//

import UIKit

class Animation {
    
    func fade(target view: UIView,
              from initial: CGFloat,
              to final: CGFloat,
              duration interval: TimeInterval = 0.25,
              completion handler: (() -> Void)? = nil) {
        
        view.alpha = initial
        UIView.animate(withDuration: interval,
                           delay: 0,
                           options: .init(rawValue: 7 << 16),
                           animations: { [weak view] in view?.alpha = final },
                           completion: { _ in handler?() })
    }
    
    func fadeIn(target view: UIView,
                from initial: CGFloat? = nil,
                to final: CGFloat? = nil,
                duration interval: TimeInterval = 0.25,
                completion handler: (() -> Void)? = nil) {
        
        fade(target: view,
             from: initial ?? view.alpha,
             to: final ?? 1,
             duration: interval,
             completion: handler)
    }
    
    func fadeOut(target view: UIView,
                from initial: CGFloat? = nil,
                to final: CGFloat? = nil,
                duration interval: TimeInterval = 0.25,
                completion handler: (() -> Void)? = nil) {
        
        fade(target: view,
             from: initial ?? view.alpha,
             to: final ?? 0,
             duration: interval,
             completion: handler)
    }
}

