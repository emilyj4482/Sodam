//
//  HangdamStorageViewModel.swift
//  Sodam
//
//  Created by 박진홍 on 1/26/25.
//

import Combine

final class HangdamStorageViewModel: ObservableObject {
    @Published var currentHangdam: HangdamDTO?
    @Published var storedHangdamList: [HangdamDTO]?
    @Published var error: DataError?
    
    private let hangdamRepository: HangdamRepository
    
    init(hangdamRepository: HangdamRepository) {
        self.hangdamRepository = hangdamRepository
        fetchCurrentHangdam()
        fetchHangdamList()
    }
    
    func fetchCurrentHangdam() {
        let fetchResult = hangdamRepository.getCurrentHangdam()
        
        switch fetchResult {
        case .success(let hangdam):
            self.currentHangdam = hangdam
        case .failure(let error):
            self.error = error
        }
    }
    
    func fetchHangdamList() {
        let fetchResult = hangdamRepository.getSavedHangdams()
        
        switch fetchResult {
        case .success(let hangdamList):
            self.storedHangdamList = hangdamList
        case .failure(let error):
            self.error = error
        }
    }
}
