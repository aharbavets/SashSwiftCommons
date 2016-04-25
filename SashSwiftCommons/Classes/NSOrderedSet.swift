//
// Created by Alexander Gorbovets on 13.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation

extension NSOrderedSet {

    func array() -> [Any] {
        var result = [Any]()
        result.reserveCapacity(self.count)
        self.enumerateObjectsUsingBlock {
            elem, idx, stop in
            result.append(elem)
        }
        return result
    }

}
