//
//  HappinessListViewModel.swift
//  Sodam
//
//  Created by 박진홍 on 1/26/25.
//

import Foundation
import Combine
import UIKit

final class HappinessListViewModel: ObservableObject {
    @Published var hangdam: HangdamDTO
    @Published var happinessList: [HappinessDTO]?
    
    private let happinessRepository: HappinessRepository
    
    init(hangdam: HangdamDTO, happinessRepository: HappinessRepository = HappinessRepository()) {
        self.hangdam = hangdam
        self.happinessRepository = happinessRepository
        self.happinessList = happinessRepository.getHappinesses(of: hangdam.id)
    }
    
    func reloadData() {
        let newHappinesslist = happinessRepository.getHappinesses(of: hangdam.id)
        self.happinessList = newHappinesslist
        print("[HappinessListViewModel] reloadeData 리로드")
    }
    
    func getHappinessRepository() -> HappinessRepository {
        return self.happinessRepository
    }
    
    func getThumnail(from path: String) -> UIImage {
        return self.happinessRepository.getThumbnailImage(from: path)
    }
}

