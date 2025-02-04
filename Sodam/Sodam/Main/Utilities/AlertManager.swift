//
//  AlertManager.swift
//  Sodam
//
//  Created by 손겸 on 1/22/25.
//

import UIKit

final class AlertManager {
    
    // 금지어 포함 여부 확인
    private static func containsForbiddenWord(_ text: String) -> Bool {
        for word in ForbiddenWords.list {
            if text.contains(word) {
                return true
            }
        }
        return false
    }
    
    // 이름 입력 알림창
    static func showAlert(
        on viewController: UIViewController,
        completion: @escaping (String?) -> Void
    ) {
        let alertController = UIAlertController(
            title: "이름 짓기",
            message: "4글자 이내로 적어주세요",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "이름을 입력하세요"
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) // 실시간 감지
            
            // 텍스트필드 옆에 Label 추가
            let rightLabel = UILabel()
            rightLabel.text = "담이"
            rightLabel.font = .mapoGoldenPier(14)
            rightLabel.textColor = .gray
            rightLabel.sizeToFit()
            
            // Label을 rightView로 설정
            textField.rightView = rightLabel
            textField.rightViewMode = .always
        }
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            guard let name = alertController.textFields?.first?.text, !name.isEmpty else {
                viewController.view.showToast(message: "이름을 입력해주세요.")
                return
            }
            
            // 글자 수 확인
            if name.count > 4 {
                viewController.view.showToast(message: "최대 글자수를 초과했습니다.")
                return
            }
            
            if containsForbiddenWord(name) {
                viewController.view.showToast(message: "적절하지 않은 이름입니다.")
                return
            }
            
            let finalName = "\(name)담이" // 입력값 + "담이"
            completion(finalName)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true)
    }
    
    // 실시간 입력 감지
    @objc private static func textFieldDidChange(_ textField: UITextField) {
        DispatchQueue.main.async {
            guard let text = textField.text else { return }
            
            if let lang = textField.textInputMode?.primaryLanguage, lang.hasPrefix("ko") {
                // 한글 조합 중에도 4글자로 제한
                if text.count > 4 {
                    textField.text = String(text.prefix(4))
                }
            } else {
                // 영어나 숫자 입력 시 8글자 초과 제한
                if text.count > 8 {
                    textField.text = String(text.prefix(8))
                }
            }
        }
    }
}

