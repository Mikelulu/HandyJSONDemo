//
//  ViewController.swift
//  HandyJSONDemo
//
//  Created by admin on 2017/5/22.
//  Copyright © 2017年 LK. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clicked(_ sender: UIButton) {

        present(TestController(), animated: true, completion: nil)
        
    }


}

