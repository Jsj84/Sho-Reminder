//
//  CustomTabBarControllerViewController.swift
//  Sho Reminder
//
//  Created by Jesse on 1/8/18.
//  Copyright © 2018 JNJ Apps. All rights reserved.
//

import UIKit

class CustomTabBarControllerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        
        
        super.viewWillLayoutSubviews()
        var tabFrame:CGRect = self.tabBar.frame
        let place = UIApplication.shared.statusBarFrame.maxY + tabFrame.size.height
        tabFrame.origin.y = place
        self.tabBar.frame = tabFrame
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
