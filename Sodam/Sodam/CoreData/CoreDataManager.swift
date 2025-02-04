//
//  CoreDataManager.swift
//  Sodam
//
//  Created by EMILY on 22/01/2025.
//

import CoreData

// MARK: - CoreDataManager

final class CoreDataManager {
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: CDKey.container.rawValue)
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print(DataError.containerLoadFailed.localizedDescription)
                print(error.localizedDescription)
            } else {
                print("[CoreData] container 로드 완료")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// context 저장 - 내부 호출
    private func saveContext() -> Result<Void, DataError> {
        guard context.hasChanges else {
            return .success(())
        }
        
        do {
            try context.save()
            print("[CoreData] context 변경사항 저장 완료")
            return .success(())
        } catch {
            print(DataError.contextSaveFailed.localizedDescription)
            return .failure(DataError.contextSaveFailed)
        }
    }
    
    /// context에 있는 모든 행담이 불러오기
    func fetchHangdams() -> Result<[HangdamEntity], DataError> {
        let fetchRequest = NSFetchRequest<HangdamEntity>(entityName: CDKey.hangdamEntity.rawValue)
        
        do {
            let hangdams = try context.fetch(fetchRequest)
            return .success(hangdams)
        } catch {
            print(DataError.fetchRequestFailed.localizedDescription)
            return .failure(DataError.fetchRequestFailed)
        }
    }
    
    /// 행담이 새로 생성 : 모든 값이 빈 값
    func createHangdam() -> Result<HangdamEntity, DataError> {
        let entity = HangdamEntity(context: context)
        
        let saveResult = saveContext()
        
        switch saveResult {
        case .success:
            print("[CoreData] 새로운 행담이 생성")
            return .success(entity)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 행담이 삭제 기능 아직 안 쓰지만 일단 구현함
    private func deleteHangdam(with id: NSManagedObjectID) -> Result<Void, DataError> {
        guard let entity = searchHangdam(with: id) else {
            return .failure(DataError.searchEntityFailed)
        }
        context.delete(entity)
        
        let saveResult = saveContext()
        
        switch saveResult {
        case .success:
            print("[CoreData] 행담이 삭제 완료")
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 행담이 수정 : update case에 따라 특정 attribute 수정
    func updateHangdam(with id: NSManagedObjectID, updateCase: HangdamUpdateCase) -> Result<Void, DataError> {
        guard let entity = searchHangdam(with: id) else {
            return .failure(DataError.searchEntityFailed)
        }
        
        switch updateCase {
        case .name(let name):
            entity.name = name
        case .startDate(let date):
            entity.startDate = date
        case .endDate(let date):
            entity.endDate = date
        }
        
        let saveResult = saveContext()
        
        switch saveResult {
        case .success:
            print("[CoreData] 행담이 정보 업데이트 완료")
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 행담이 검색 - 내부 호출
    private func searchHangdam(with id: NSManagedObjectID) -> HangdamEntity? {
        do {
            let hangdam = try context.existingObject(with: id) as? HangdamEntity
            return hangdam
        } catch {
            print(DataError.searchEntityFailed.localizedDescription)
            return nil
        }
    }
    
    /// 행복한 기억 생성 : 행담이 id 받아 행담이에 추가
    func createHappiness(_ dto: HappinessDTO, to hangdamID: NSManagedObjectID) -> Result<Void, DataError> {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: dto.imagePaths, requiringSecureCoding: true)
        else {
            print(DataError.convertImagePathsFailed.localizedDescription)
            return .failure(DataError.convertImagePathsFailed)
        }
        
        let entity = HappinessEntity(context: context)
        entity.content = dto.content
        entity.date = dto.date
        entity.imagePaths = data
        
        /// 행담이에 추가
        do {
            try appendHappiness(entity, to: hangdamID)
            
            let saveResult = saveContext()
            
            switch saveResult {
            case .success:
                print("[CoreData] 행복 생성 완료")
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        } catch {
            return .failure(DataError.searchEntityFailed)
        }
    }
    
    /// 행복한 기억을 행담이에 추가하는 메소드 - 내부 호출
    private func appendHappiness(_ entity: HappinessEntity, to hangamID: NSManagedObjectID) throws {
        guard let hangdam = searchHangdam(with: hangamID)
        else {
            throw DataError.searchEntityFailed
        }
        
        hangdam.addToHappinesses(entity)
    }
    
    /// 행담이가 갖고 있는 행복한 기억들 호출
    func getHappinesses(of hangdamID: NSManagedObjectID) throws -> [HappinessEntity]? {
        guard let hangdam = searchHangdam(with: hangdamID)
        else {
            print(DataError.searchEntityFailed.localizedDescription)
            throw DataError.searchEntityFailed
        }
        
        return hangdam.happinesses?.array as? [HappinessEntity]
    }
    
    /// 행복한 기억 단일 삭제
    func deleteHappiness(with id: NSManagedObjectID) -> Result<Void, DataError> {
        guard let entity = searchHappiness(with: id) else {
            return .failure(DataError.searchEntityFailed)
        }
        context.delete(entity)
        
        let saveResult = saveContext()
        
        switch saveResult {
        case .success:
            print("[CoreData] 행복 삭제 완료")
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// 행복한 기억 검색 - 내부 호출
    private func searchHappiness(with id: NSManagedObjectID) -> HappinessEntity? {
        do {
            let happiness = try context.existingObject(with: id) as? HappinessEntity
            return happiness
        } catch {
            print(DataError.searchEntityFailed.localizedDescription)
            return nil
        }
    }
    
    /// 행담이가 가진 현재 기억 개수 체크 - startDate, endDate 업데이트 기준으로 사용
    func checkHappinessCount(with hangdamID: NSManagedObjectID) -> Int? {
        guard let hangdam = searchHangdam(with: hangdamID) else { return nil }
        return hangdam.happinesses?.count
    }
}

fileprivate enum CDKey: String {
    case container = "SodamContainer"
    case hangdamEntity = "HangdamEntity"
    case happinessEntity = "HappinessEntity"
}
