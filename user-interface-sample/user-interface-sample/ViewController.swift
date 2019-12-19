//
//  ViewController.swift
//  user-interface-sample
//
//  Created by dumbass.cn on 9/26/19.
//  Copyright © 2019 dumbass.cn. All rights reserved.
//

import UIKit
import HeadUpDisplayer

class ViewController: UIViewController {

    @IBAction func tap(_ sender: Any) {

        view.addSubview(UIView())
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        hud.show(success: "xxx")
    }

}
