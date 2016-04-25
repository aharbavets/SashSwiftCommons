//
// Created by Alexander Gorbovets on 11.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation
import QuartzCore

extension CAAnimation {

    // if it is persistent, then changes are not rolled back when animation ends.
    // otherwise they are rolled back.
    // this property is ignored for animations which are added to groups
    // in this case groups persistence matters.
    func setPersistent(persistent: Bool) -> Self {
        removedOnCompletion = !persistent
        fillMode = persistent ? kCAFillModeForwards : kCAFillModeRemoved
        return self
    }

}
