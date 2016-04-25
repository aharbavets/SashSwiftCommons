//
// Created by Alexander Gorbovets on 10.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {

    func getStatusbarAndNavbarHeight() -> CGFloat {
        let statusHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let navbarHeight = navigationBar.frame.size.height ?? 0
        return statusHeight + navbarHeight
    }
    
    func getViewportHeight() -> CGFloat {
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let statusHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let navbarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        let toolbarHeight = navigationController?.toolbar.frame.size.height ?? 0
        return screenHeight - statusHeight - navbarHeight - toolbarHeight
    }

}
