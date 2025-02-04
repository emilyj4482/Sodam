//
//  HangdamDTO.swift
//  Sodam
//
//  Created by EMILY on 23/01/2025.
//

import Foundation

struct HangdamDTO {
    let id: String              // 행담이는 DTO가 먼저 생성될 일이 없고, Entity에서 변환될 일만 있기 때문에 상수
    var name: String?
    var happinessCount: Int
    var startDate: String?
    var endDate: String?
    
    var level: Int {
        if endDate != nil {
            return 5
        } else {
            switch happinessCount {
            case 1...3: return 1    // 애기담이 : 3개 작성 필요
            case 4...10: return 2   // 초딩담이 : 7개 작성 필요
            case 11...24: return 3  // 중딩담이 : 14개 작성 필요
            case 25...29: return 4  // 킹담이 : 5개 작성해야 성장 완료
            case 30: return 5       // 성장완료 보관 ㄱ
            default: return 0       // 알담이 : 1개 작성 필요
            }
        }
    }
    
    var levelName: String {
        switch level {
        case 1: "애기 행담이"
        case 2: "초딩 행담이"
        case 3: "중딩 행담이"
        case 4, 5: "킹담이"
        default: "알 속 행담이"
        }
    }
}

extension HangdamEntity {
    var toDTO: HangdamDTO {
        return HangdamDTO(
            id: self.objectID.uriRepresentation().absoluteString,
            name: self.name,
            happinessCount: self.happinesses?.count ?? 0,
            startDate: self.startDate?.toFormattedString,
            endDate: self.endDate?.toFormattedString
        )
    }
}
