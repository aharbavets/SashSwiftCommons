//
// Created by Alexander Gorbovets on 11.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation
import QuartzCore

extension CAAnimationGroup {

    convenience init(duration: Double, animations: [CAAnimation]) {
        self.init()
        self.duration = duration
        self.animations = animations
    }

}
