//
//  DictionaryAppendOperator.swift
//  UIKitTest
//
//  Created by Kris Penney on 2016-03-18.
//  Copyright © 2016 Kris Penney. All rights reserved.
//

import Foundation

// Allow two dictionaries to be appended together
func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
