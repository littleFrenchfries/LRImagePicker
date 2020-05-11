//
//  ViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/23.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func singalClick(_ sender: Any) {
        LRImagePicker.go(finish: { (assets, isOriginal) in
            print("\(assets)\(isOriginal)")
        })
    }
    
}

