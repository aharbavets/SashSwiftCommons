//
// Created by Alexander Gorbovets on 11.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

typealias Callback = () -> Void

class BasicAnimationListItem {
    func execute() {
    }
}

class DelayAnimationListItem: BasicAnimationListItem {
    private var delayInSeconds: Double
    private weak var list: AnimationList?
    init(delayInSeconds: Double, list: AnimationList) {
        self.delayInSeconds = delayInSeconds
        self.list = list
    }
    override func execute() {
        Utils.delayBy(delayInSeconds) {
            [weak self] in self?.list?.next()
        }
    }
}

class AnimationListItem: BasicAnimationListItem {
    var animation: CAAnimation
    var layer: CALayer
    init(animation: CAAnimation, layer: CALayer) {
        self.animation = animation
        self.layer = layer
    }
    override func execute() {
        layer.addAnimation(animation, forKey: nil)
    }
}

class CallbackAnimationListItem: BasicAnimationListItem {
    private var callback: Callback
    private weak var list: AnimationList?
    init(callback: Callback, list: AnimationList) {
        self.callback = callback
        self.list = list
    }
    override func execute() {
        callback()
        list?.next()
    }
}

// Sic! Instead of creating CAAnimationDelegate protocol
// authors of CoreAnimation require delegate to be instance of UIView.
// Otherwise animationDidStop does not gets called
class AnimationList: UIView  {

    private var currentItemIndex = 0

    private var items = [BasicAnimationListItem]()

    private var started = false

    func animateLayer(layer: CALayer, usingAnimation animation: CAAnimation) {
        if !started {
            animation.delegate = self
            let item = AnimationListItem(animation: animation, layer: layer)
            items.append(item)
        }
    }

    func animateLayer(layer: CALayer, during duration: Double, persistently persistent: Bool, usingAnimations animations: [CAAnimation]) {
        let group = CAAnimationGroup(duration: duration, animations: animations)
        group.setPersistent(persistent)
        animateLayer(layer, usingAnimation: group)
    }

    func addCallback(callback: Callback) {
        if !started {
            let item = CallbackAnimationListItem(callback: callback, list: self)
            items.append(item)
        }
    }

    func addDelayInSeconds(delay: Double) {
        if !started {
            let item = DelayAnimationListItem(delayInSeconds: delay, list: self)
            items.append(item)
        }
    }

    func start() {
        if !started {
            started = true
            runCurrentAnimation()
        }
    }

    func runCurrentAnimation() {
        if currentItemIndex < items.count {
            let item = items[currentItemIndex]
            item.execute()
        }
    }

    override func animationDidStop(theAnimation: CAAnimation, finished flag: Bool) {
        next()
    }

    func next() {
        currentItemIndex += 1
        runCurrentAnimation()
    }

}
