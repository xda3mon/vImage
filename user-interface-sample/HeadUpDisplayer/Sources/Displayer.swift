//
//  Displayer.swift
//  HeadUpDisplayer
//
//  Created by What on 2019/9/26.
//  Copyright © 2019 dumbass.cn. All rights reserved.
//

import UIKit.UIView

class Displayer {
    
    private init() {}
    
    static let instance: Displayer = .init()
        
    func show(style: Style, in container: UIView) {
        
        container.subviews.forEach {
            if $0 is HUD.Content { $0.removeFromSuperview() }
        }
        
        switch style {
        case .progressWithTitle(let string): break
        case .progress: break
        case .text(.success, let text):
                        
            let content = HUD.Content()
            container.addSubview(content)
            let animation = Animation()
            animation.fadeIn(target: content, from: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak content] in
                if let _content = content { animation.fadeOut(target: _content) {
                        content?.removeFromSuperview()
                } }
            }
            
        case .text(.failure, let text): break
        case .text(.info, let text): break
        case .text(.error, let text): break
        }
    }
    
}
