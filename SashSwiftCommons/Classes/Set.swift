//
// Created by Alexander Gorbovets on 01.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation

extension Set {

    public init(_ elements: Element?...) {
        self.init(minimumCapacity: elements.count)
        for element in elements {
            if let element = element {
                self.insert(element)
            }
        }
    }

}
