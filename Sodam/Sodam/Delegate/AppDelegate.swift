//
//  AppDelegate.swift
//  Sodam
//
//  Created by 손겸 on 1/20/25.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // 초기 설정 체크 추가
        checkInitialSetup()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - UNUserNotificationCenterDelegate Setting Method

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground 상태인 경우(앱 실행중인상태) 알림이 오면 해당 메서드 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔔 Foreground에서 알림 수신: \(notification.request.identifier)") // 로그 추가
        // 알림 수신 시 뱃지 수를 1씩 증가
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1
        
        completionHandler([.banner, .badge, .sound, .list])
    }
    
    // Background에서 알림 클릭 시 처리사용자가 알림을 탭했을때 해당 메서드 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()  // 응답 처리가 완료되었음을 시스템에 알림
    }
}

// MARK: - Private Methods

private extension AppDelegate {
    // 초기 설정 체크 추가
    func checkInitialSetup() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async { // UI 변경은 반드시 메인 스레드에서 실행
                switch settings.authorizationStatus {
                case .notDetermined:
                    // 권한 요청 (사용자가 한 번도 응답하지 않은 상태)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // 1초 후 실행
                        self.requestNotificationAuthorization()
                    }
                case .denied:
                    // 권한 허용 거부된 경우 → UserDefaultsManager로 중복 표시 방지
                    if !UserDefaultsManager.shared.getNotificaionAuthorizationStatus() {
                        self.showToast(message: "알림 권한이 거부되었습니다.")
                        UserDefaultsManager.shared.saveNotificaionAuthorizationStatus(true) // 최초 한 번만 저장
                    }
                case .authorized, .provisional, .ephemeral:
                    // 초기 설정이 완료 여부
                    if !UserDefaultsManager.shared.isNotificationSetupComplete() {
                        self.setDefaultNotificationTime()
                        UserDefaultsManager.shared.markNotificationSetupAsComplete()
                    }
                    UserDefaultsManager.shared.saveNotificaionAuthorizationStatus(true)
                @unknown default:
                    break
                }
            }
        }
    }
    
    // 앱 첫 진입시 디폴트 시간
    func setDefaultNotificationTime() {
        let calendar = Calendar.current
        let defaultTime = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!
        UserDefaultsManager.shared.saveNotificationTime(defaultTime)
        
        // 로컬 알림 예약
        LocalNotificationManager.shared.setReservedNotification(defaultTime)
    }
    
    // 앱 첫 진입시 권한 허용 여부에 따른 토스트 알림
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]  // 필요한 알림 권한을 설정
        
        center.requestAuthorization(options: authOptions) { success, error in
            DispatchQueue.main.async { // UI 변경은 반드시 메인 스레드에서 실행
                if let error = error {
                    print("알림 권한 요청 중 에러 발생: \(error.localizedDescription)")
                    return
                }
                
                if success {
                    self.showToast(message: "알림 시간 설정이 가능합니다.")
                    // 최초 설정이 완료되지 않았을 경우 기본 시간 설정
                    if !UserDefaultsManager.shared.isNotificationSetupComplete() {
                        self.setDefaultNotificationTime()
                        UserDefaultsManager.shared.markNotificationSetupAsComplete()
                    }
                    UserDefaultsManager.shared.saveNotificaionAuthorizationStatus(true)
                } else {
                    print("알림 권한이 거부되었습니다.")
                    // 1초 후에 토스트 메시지 띄우기
                    self.showToast(message: "알림 권한이 거부되었습니다.")
                    UserDefaultsManager.shared.saveNotificaionAuthorizationStatus(true)
                }
            }
        }
    }
    
    // 안전하게 토스트 메시지를 표시하는 함수
    func showToast(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 현재 최상위 윈도우의 rootViewController의 view에서 토스트 표시(화면전환될때도 토스트 유지)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.rootViewController?.view.showToast(message: message)
            }
        }
    }
}
