//
//  UserDefaultsManager.swift
//  Sodam
//
//  Created by 박시연 on 1/22/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // 이름 충돌 방지 및 재사용성 증가
    private enum Keys {
        static let notificationTime = "time"  // 앱 알림 시간
        static let appSettingToggleState = "appSettingToggleState"  // 앱 설정 토글 상태
        static let content = "content"  // 작성 내용
        static let imagePath = "imagePath"  // 작성시 등록 이미지
        static let notificationAuthorizationStatus = "notificationAuthorizationStatus"  // 알림 권한 상태 (허용/거부)를 UserDefaults에 저장
        static let toggleSetBeforeKey = "hasUserSetToggleBefore"  // 사용자가 한 번이라도 설정한 적이 있는지 여부 확인
        static let notificationInitialSetupComplete = "notificationInitialSetupComplete" // 앱 알림 초기 설정 여부 확인
        static let isDiaryWritten = "isDiaryWritten"  // 기록 작성 여부 확인
        static let diaryWrittenDateKey = "diaryWrittenDateKey"  // 기록 작성 시간
    }
    
    // MARK: - UserDefaults에 저장
    
    // 알림 시간을 UserDefaults에 저장
    func saveNotificationTime(_ time: Date) {
        userDefaults.set(time, forKey: Keys.notificationTime)
    }
    
    // 앱 설정 알림 토글 상태 (ON/OFF)를 UserDefaults에 저장
    func saveAppNotificationToggleState(_ isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: Keys.appSettingToggleState)
    }
    
    // 사용자가 한 번이라도 설정한 적이 있는지 여부 반환
    func hasUserSetToggleBefore() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.toggleSetBeforeKey)
    }
    
    // 작성된 내용(content)을 UserDefaults에 저장
    func saveContent(_ content: String) {
        userDefaults.set(content, forKey: Keys.content)
    }
    
    // 작성된 이미지 경로(imagePath)를 UserDefaults에 저장
    func saveImagePath(_ imagePath: [String]) {
        userDefaults.set(imagePath, forKey: Keys.imagePath)
    }
    
    // 알림 권한 상태 (허용/거부)를 UserDefaults에 저장
    func saveNotificaionAuthorizationStatus(_ isAuthorized: Bool) {
        userDefaults.set(isAuthorized, forKey: Keys.notificationAuthorizationStatus)
    }
    
    // 일기 작성 여부 저장(알림시간 전 작성된 내용이 있는 경우 확인)
    func saveDiaryWrittenStatus(_ written: Bool) {
        UserDefaults.standard.set(written, forKey: Keys.isDiaryWritten)
    }
    
    // 일기 작성 날짜 저장
    func saveDiaryWrittenDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: Keys.diaryWrittenDateKey)
    }
    
    // 알림 초기 설정 완료 여부를 확인 (알림 설정이 처음 완료되었는지 여부)
    func isNotificationSetupComplete() -> Bool {
        return userDefaults.bool(forKey: Keys.notificationInitialSetupComplete)
    }

    // MARK: - UserDefaults에 저장된 값 얻어오기
    
    // 저장된 알림 시간을 가져옴
    func getNotificationTime() -> Date? {
        userDefaults.object(forKey: Keys.notificationTime) as? Date
    }
    
    // 앱 설정 알림 토글 상태 (ON/OFF)를 가져옴
    func getAppNotificationToggleState() -> Bool {
        userDefaults.bool(forKey: Keys.appSettingToggleState)
    }
    
    // 작성된 내용을 가져옴
    func getContent() -> String? {
        userDefaults.string(forKey: Keys.content)
    }
    
    // 저장된 이미지 경로 목록을 가져옴
    func getImagePath() -> [String]? {
        userDefaults.stringArray(forKey: Keys.imagePath)
    }

    // 임시 저장된 콘텐츠와 이미지 경로 삭제
    func deleteTemporaryPost() {
        print("[WriteView] 임시저장 됐던 content와 imagePath 삭제")
        userDefaults.removeObject(forKey: Keys.content)
        userDefaults.removeObject(forKey: Keys.imagePath)
    }
    
    // 저장된 알림 권한 상태를 가져옴
    func getNotificaionAuthorizationStatus() -> Bool {
        return userDefaults.bool(forKey: Keys.notificationAuthorizationStatus)
    }
    
    // 저장된 일기 작성 날짜 가져오기
    func getDiaryWrittenDate() -> Date? {
        return UserDefaults.standard.value(forKey: Keys.diaryWrittenDateKey) as? Date
    }
    
    // 일기 작성 여부 불러오기
    func getDiaryWrittenStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.isDiaryWritten)
    }
    
    // 알림 초기 설정을 완료 표시 (첫 설정 후 완료 상태로 변경)
    func markNotificationSetupAsComplete() {
        userDefaults.set(true, forKey: Keys.notificationInitialSetupComplete)
    }
    
    // 00시에 일기 상태를 재설정
    func resetDiaryWrittenStatusAtMidnight() {
        let calendar = Calendar.current
        let nextMidnight = calendar.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
        
        Timer.scheduledTimer(withTimeInterval: nextMidnight.timeIntervalSinceNow, repeats: false) { _ in
            self.saveDiaryWrittenStatus(false)
        }
    }
}
