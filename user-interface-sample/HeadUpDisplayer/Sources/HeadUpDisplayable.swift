//
//  HeadUpDisplayable.swift
//  HeadUpDisplayer
//
//  Created by dumbass.cn on 9/26/19.
//  Copyright © 2019 dumbass.cn. All rights reserved.
//

import UIKit

public protocol HeadUpDisplayerContainer {
    var hudContainer: UIView { get }
}

public enum Style {
    
    public enum State { case success, failure, info, error }
    
    case text(State, String)
    case progress
    case progressWithTitle(String)
}

public protocol HeadUpDisplayable {
    
    typealias Container = HeadUpDisplayerContainer
    
    var container: Container { get }
    
    func show(style: Style)
}


public extension HeadUpDisplayable {
    
    func show(style: Style) {
        Displayer.instance.show(style: style, in: container.hudContainer)
    }
    
    func show(success text: String) {
        show(style: .text(.success, text))
    }
    
    func show(failure text: String) {
        show(style: .text(.failure, text))
    }
}

extension UIView : HeadUpDisplayerContainer {
    public var hudContainer: UIView { self }
}

extension UIViewController : HeadUpDisplayerContainer {
    public var hudContainer: UIView { view }
}

extension HeadUpDisplayerWrapper : HeadUpDisplayable where Base : HeadUpDisplayerContainer {
    public var container: Container { base }
}
