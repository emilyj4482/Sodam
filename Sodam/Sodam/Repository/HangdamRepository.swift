//
//  HangdamRepository.swift
//  Sodam
//
//  Created by EMILY on 23/01/2025.
//

import Foundation

/// CoreDataManager와 ViewModel 사이에서 행담이 데이터 처리를 맡는 객체
final class HangdamRepository {
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    /// 현재 키우는 행담이 불러오기
    func getCurrentHangdam() -> HangdamDTO {
        guard !coreDataManager.fetchHangdams().isEmpty,
              let currentHangdam = coreDataManager.fetchHangdams().last,
              currentHangdam.endDate == nil
        else {
            /// context에 저장된 행담이가 없을 경우(첫 접속) 또는 행담이가 기억 30개를 채운 경우 새로운 행담이 생성
            return createNewHangdam()
        }
        
        return currentHangdam.toDTO
    }
    
    /// 보관된 행담이들 불러오기 : 현재 키우는 행담이 제외하고 다 큰 행담이들
    func getSavedHangdams() -> [HangdamDTO] {
        guard coreDataManager.fetchHangdams().count > 1 else { return [] }
        
        return coreDataManager.fetchHangdams().dropLast().compactMap { $0.toDTO }
    }
    
    /// 새로운 행담이 생성
    private func createNewHangdam() -> HangdamDTO {
        return coreDataManager.createHangdam().toDTO
    }
    
    /// 행담이 이름 짓기
    func nameHangdam(id: String, name: String) {
        guard let id = IDConverter.toNSManagedObjectID(from: id, in: coreDataManager.context) else { return }
        
        coreDataManager.updateHangdam(with: id, updateCase: .name(name))
    }
}
