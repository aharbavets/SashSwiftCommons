//
// Created by Alexander Gorbovets on 13.04.16.
// Copyright (c) 2016 robinclough. All rights reserved.
//

import Foundation

extension CollectionType {

    func genericArray<T>(type: T.Type) -> [T] {
        return self.filter{ $0 is T }.map{ $0 as! T }
    }

}