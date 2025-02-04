//
//  +Data.swift
//  Sodam
//
//  Created by EMILY on 23/01/2025.
//

import Foundation

/// CoreData에 Data 타입으로 저장되어 있는 imagePaths를 [String]으로 변환
extension Data {
    var toStringArray: [String]? {
        return try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSString.self, from: self) as? [String]
    }
}
