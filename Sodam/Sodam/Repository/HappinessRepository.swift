//
//  HappinessRepository.swift
//  Sodam
//
//  Created by EMILY on 23/01/2025.
//

import Foundation
import UIKit

/// CoreDataManager와 ViewModel 사이에서 행복한 기억 데이터 처리를 맡는 객체
final class HappinessRepository {
    private let coreDataManager: CoreDataManager
    private let imageManager: ImageManager
    
    // 
    init(coreDataManager: CoreDataManager = CoreDataManager.shared, imageManager: ImageManager = ImageManager()) {
        self.coreDataManager = coreDataManager
        self.imageManager = imageManager
    }
    
    /// 행복한 기억 생성
    func createHappiness(_ happiness: HappinessDTO) {
        guard let hangdamID = IDConverter.toNSManagedObjectID(from: happiness.hangdamID, in: coreDataManager.context)
        else {
            print(DataError.convertIDFailed.localizedDescription)
            return
        }
        
        /// 날짜 업데이트 필요성 체크
        updateHangdamIfNeeded(hangdamID: happiness.hangdamID)
        
        /// 기억생성
        coreDataManager.createHappiness(happiness, to: hangdamID)
    }
    
    /// 행담이가 가진 기존 행복 개수 체크하여 경우에 따라 이벤트 발생 또는 데이터 업데이트
    private func updateHangdamIfNeeded(hangdamID: String) {
        guard let hangdamID = IDConverter.toNSManagedObjectID(from: hangdamID, in: coreDataManager.context),
              let count = coreDataManager.checkHappinessCount(with: hangdamID)
        else {
            print(DataError.convertIDFailed.localizedDescription)
            return
        }
        
        switch count {
        case 0:     // 행담이 startDate 업데이트, 레벨 1로 성장
            coreDataManager.updateHangdam(with: hangdamID, updateCase: .startDate(Date.now))
            postNotification(level: 1)
        case 3:     // 행담이 레벨 2로 성장
            postNotification(level: 2)
        case 10:    // 행담이 레벨 3으로 성장
            postNotification(level: 3)
        case 24:    // 행담이 레벨 4로 성장
            postNotification(level: 4)
        case 29:    // 행담이 endDate 업데이트, 최종 성장(보관함 이동)
            coreDataManager.updateHangdam(with: hangdamID, updateCase: .endDate(Date.now))
            postNotification(level: 5)
        default:
            return
        }
    }
    
    /// 행담이가 가진 기억들 호출
    func getHappinesses(of hangdamID: String) -> [HappinessDTO]? {
        guard let id = IDConverter.toNSManagedObjectID(from: hangdamID, in: coreDataManager.context) else { return nil }
        
        return coreDataManager.getHappinesses(of: id)?.compactMap { $0.toDTO }
    }
    
    /// 기억 삭제
    func deleteHappiness(with id: String?, path: String?) {
        guard let id = IDConverter.toNSManagedObjectID(from: id, in: coreDataManager.context) else { return }
        coreDataManager.deleteHappiness(with: id)
        print("[HappinessRepository] deleteHappiness - 행복 삭제 완료")
        
        guard let path = path else { return }
        imageManager.deleteImage(path)
        print("[HappinessRepository] deleteHappiness - 이미지 삭제 완료")
    }
    
    func getThumbnailImage(from path: String) -> UIImage {
        return imageManager.getThumbnailImage(with: path)
    }
    
    func getContentImage(from path: String) -> UIImage? {
        return imageManager.getImage(with: path)
    }
}

extension HappinessRepository {
    private func postNotification(level: Int) {
        NotificationCenter.default.post(name: Notification.levelUP, object: nil, userInfo: ["level": level])
    }
}
