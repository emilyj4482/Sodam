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
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared, imageManager: ImageManager = ImageManager()) {
        self.coreDataManager = coreDataManager
        self.imageManager = imageManager
    }
    
    /// 행복한 기억 생성
    func createHappiness(_ happiness: HappinessDTO) -> Result<Void, DataError> {
        guard let hangdamID = IDConverter.toNSManagedObjectID(from: happiness.hangdamID, in: coreDataManager.context)
        else {
            print(DataError.convertIDFailed.localizedDescription)
            return .failure(DataError.convertIDFailed)
        }
        
        /// date 업데이트 필요성 / 레벨업 message 필요성 체크
        let updateResult = updateHangdamIfNeeded(hangdamID: happiness.hangdamID)
        
        switch updateResult {
        case .success:
            /// 기억생성
            return coreDataManager.createHappiness(happiness, to: hangdamID)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 행담이가 가진 기존 행복 개수 체크하여 경우에 따라 이벤트 발생 또는 데이터 업데이트
    private func updateHangdamIfNeeded(hangdamID: String) -> Result<Void, DataError> {
        guard let hangdamID = IDConverter.toNSManagedObjectID(from: hangdamID, in: coreDataManager.context),
              let count = coreDataManager.checkHappinessCount(with: hangdamID)
        else {
            print(DataError.convertIDFailed.localizedDescription)
            return .failure(DataError.convertIDFailed)
        }
        
        switch count {
        case 0:     // 행담이 startDate 업데이트, 레벨 1로 성장
            postNotification(level: 1)
            return coreDataManager.updateHangdam(with: hangdamID, updateCase: .startDate(Date.now))
        case 3:     // 행담이 레벨 2로 성장
            postNotification(level: 2)
            return .success(())
        case 10:    // 행담이 레벨 3으로 성장
            postNotification(level: 3)
            return .success(())
        case 24:    // 행담이 레벨 4로 성장
            postNotification(level: 4)
            return .success(())
        case 29:    // 행담이 endDate 업데이트, 최종 성장(보관함 이동)
            postNotification(level: 5)
            return coreDataManager.updateHangdam(with: hangdamID, updateCase: .endDate(Date.now))
        default:
            return .success(())
        }
    }
    
    /// 행담이가 가진 기억들 호출
    func getHappinesses(of hangdamID: String) -> [HappinessDTO]? {
        guard let id = IDConverter.toNSManagedObjectID(from: hangdamID, in: coreDataManager.context) else {
            print(DataError.convertIDFailed.localizedDescription)
            return nil
        }
        
        return try? coreDataManager.getHappinesses(of: id)?.compactMap { $0.toDTO }
    }
    
    /// 기억 삭제
    func deleteHappiness(with id: String?, path: String?) -> Result<Void, DataError> {
        guard let id = IDConverter.toNSManagedObjectID(from: id, in: coreDataManager.context) else {
            print(DataError.convertIDFailed.localizedDescription)
            return .failure(DataError.convertIDFailed)
        }
        
        // imagePath가 있는 경우에만 이미지 삭제
        if let path = path {
            imageManager.deleteImage(path)
        }
        
        return coreDataManager.deleteHappiness(with: id)
    }
    
    func getThumbnailImage(from path: String) -> UIImage {
        return imageManager.getThumbnailImage(with: path)
    }
    
    func getContentImage(from path: String) -> UIImage? {
        return imageManager.getImage(with: path)
    }
}

extension HappinessRepository {
    /// NotificateionCenter를 통해 main view에 레벨업 메시지 출력 요청
    private func postNotification(level: Int) {
        NotificationCenter.default.post(name: Notification.levelUP, object: nil, userInfo: ["level": level])
    }
}
