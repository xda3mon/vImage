//
//  HeadUpDisplayer.swift
//  HeadUpDisplayer
//
//  Created by dumbass.cn on 9/26/19.
//  Copyright © 2019 dumbass.cn. All rights reserved.
//

public struct HeadUpDisplayerWrapper<Base> {
    public let base: Base
    public init(base: Base) {
        self.base = base
    }
}

public protocol HeadUpDisplayerCompatible : class {
}

public extension HeadUpDisplayerCompatible {
    var hud: HeadUpDisplayerWrapper<Self> {
        get { .init(base: self) }
        set {}
    }
}

import UIKit.UIViewController

extension UIViewController : HeadUpDisplayerCompatible {
}

extension UIView : HeadUpDisplayerCompatible {
}
