//
//  ViewController.swift
//  DNLocationManager
//
//  Created by mainone on 2018/4/4.
//  Copyright © 2018年 mainone. All rights reserved.
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DNLocationManager.shared.getLocationInfo { (error, locationModel) in
            print(error, locationModel?.latitude, locationModel?.longitude, locationModel?.placemark?.addressDictionary, locationModel?.placemark?.addressDictionary!["City"])
        }
    }


}

