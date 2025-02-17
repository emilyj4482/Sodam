//
//  +Date.swift
//  Sodam
//
//  Created by EMILY on 21/01/2025.
//

import Foundation

/// Date 타입을 view에 바인딩하기 위해 "2025-01-01" String으로 변환
extension Date {
    var toFormattedString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
