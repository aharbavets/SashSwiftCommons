//
// Created by Alexander Gorbovets on 11.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation
import QuartzCore

enum TimingFunction {
    case Linear
    case EaseIn
    case EaseOut
    case EaseInEaseOut
    case Default
    
    var value: String {
        switch self {
            case Linear: return kCAMediaTimingFunctionLinear
            case EaseIn: return kCAMediaTimingFunctionEaseIn
            case EaseOut: return kCAMediaTimingFunctionEaseOut
            case EaseInEaseOut: return kCAMediaTimingFunctionEaseInEaseOut
            case Default: return kCAMediaTimingFunctionDefault
        }
    }
}

extension CABasicAnimation {

    convenience init(moveLayer layer: CALayer, horizontallyToCurrentPositionByOffset offset: CGFloat,
                     duration: Double, timing: TimingFunction) {
        self.init(keyPath: "position.x") // position is a position of center of layer. not view.frame.origin
        self.fromValue = layer.position.x - offset
        self.toValue = layer.position.x // to value should be equal to layer.position value. otherwise at end of animation it will be returned to original layer.position
        self.duration = duration
        self.timingFunction = CAMediaTimingFunction(name: timing.value)
    }

    convenience init(fadeLayer layer: CALayer, inWithDuration: Double, timing: TimingFunction) {
        self.init(keyPath: "opacity")
        self.fromValue = 0
        self.toValue = 1
        self.duration = duration
        self.timingFunction = CAMediaTimingFunction(name: timing.value)
    }

}
