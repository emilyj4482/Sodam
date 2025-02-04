//
//  DataError.swift
//  Sodam
//
//  Created by EMILY on 22/01/2025.
//

import Foundation

enum DataError: Error {
    case containerLoadFailed
    case contextSaveFailed
    case fetchRequestFailed
    case searchEntityFailed
    case convertIDFailed
    case convertImagePathsFailed
    case noData
    
    // 디버깅용 print 구문
    var localizedDescription: String {
        switch self {
        case .containerLoadFailed: "[CoreData Error] container 로드 실패"
        case .contextSaveFailed: "[CoreData Error] context 저장 실패"
        case .fetchRequestFailed: "[CoreData Error] entity fetch 실패"
        case .searchEntityFailed: "[CoreData Error] entity search 실패"
        case .convertIDFailed: "[CoreData Error] DTO id >>> NSManagedObjectID 변환 실패"
        case .convertImagePathsFailed: "[CoreData Error] DTO [String] >>> Data 변환 실패"
        case .noData: "[Error] 옵셔널 바인딩 실패"
        }
    }
    
    // 사용자에게 띄울 alert에 넣을 구문
    var alertDescription: String {
        switch self {
        case .containerLoadFailed: "오류로 인해 행담이를 불러오지 못했어요🥲\n앱 종료 후 재실행하거나, 개발자에게 문의해주세요."
        case .contextSaveFailed: "변경 사항 저장에 실패했어요🥲\n 다시 시도하거나, 개발자에게 문의해주세요."
        case .fetchRequestFailed: "데이터를 불러오는 데 실패했어요🥲\n앱 종료 후 재실행하거나, 개발자에게 문의해주세요."
        case .searchEntityFailed, .convertIDFailed, .convertImagePathsFailed, .noData: "작업에 실패했어요🥲"
        }
    }
}
