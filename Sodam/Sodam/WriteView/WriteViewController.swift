//
//  WriteViewController.swift
//  Sodam
//
//  Created by 박민석 on 1/21/25.
//

import UIKit
import SnapKit

protocol WriteViewControllerDelegate: AnyObject {
    func writeViewControllerDiddismiss()
}

final class WriteViewController: UIViewController {
    
    weak var delegate: WriteViewControllerDelegate?
    
    private let writeViewModel: WriteViewModel
    private let writeView = WriteView()
    
    // MARK: - 초기화
    init(writeViewModel: WriteViewModel) {
        self.writeViewModel = writeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 뷰 생명주기
    
    // 뷰를 로드할 때 WriteView를 루트 뷰로 설정
    override func loadView() {
        view = writeView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear 동작함")
        
        // 임시 저장글 있는지 확인하고 로드
        writeViewModel.loadTemporaryPost()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 컬렉션 뷰의 데이터 소스와 델리게이트 설정
        writeView.setCollectionViewDataSource(dataSource: self)
        
        // 키보드 알림 설정
        setupKeyboardNotification()
        
        // 버튼 액션 설정
        setupActions()
        
        // UITextView의 delegate 설정
        writeView.setTextViewDeleaget(delegate: self)
        
        // 뷰모델의 데이터 변경을 관찰
        writeViewModel.bindPostUpdated { [weak self] post in
            self?.updateUI(with: post)
        }
    }
    
    // 모달 dismiss 될 때 호출될 메서드
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear 동작함")
        
        // 현재 텍스트 저장
        writeViewModel.saveTemporaryPost()
        
        // 뷰가 닫힐 때 delegate 호출하기
        if self.isBeingDismissed {
            if writeViewModel.isPostSubmitted {
                print("[viewWillDisappear] CoreData에 저장됨.")
                // 작성 완료시 UserDefaults에 임시 저장된 글 삭제
                UserDefaultsManager.shared.deleteTemporaryPost()
            } else {
                print("[viewWillDisappear] UserDefaults에 저장됨.")
                // 작성 취소 시 임시 저장
                writeViewModel.saveTemporaryPost()
            }
            
            delegate?.writeViewControllerDiddismiss()
        }
    }
    
    // MARK: - 메서드 선언
    
    // WriteView에 정의된 버튼들의 액션 설정 메서드
    private func setupActions() {
        writeView.setCameraButtonAction(target: self, cameraSelector: #selector(openCamera))
        writeView.setImageButtonAction(target: self, imageSelector: #selector(addImage))
        writeView.setSubmitButtonAction(target: self, submitSelector: #selector(submitText))
        writeView.setDismissButtonAction(target: self, dismissSelector: #selector(tapDismiss))
    }
    
    // 키보드 감지
    private func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 내리기 구현
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true) // 키보드 내리기
    }
    
    // 키보드 나타날 때 호출되는 메서드
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, // 키보드가 나타날 때 프레임 및 애니메이션 시간 정보 저장
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, // 키보드 크기와 위치 저장
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { // userInfo 중 애니메이션 지속 시간 저장
            return
        }
        
        // 키보드 높이를 기준으로 inset 설정
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottomInset = view.safeAreaInsets.bottom

        // 동적으로 계산된 inset 적용
        let inset = keyboardHeight - safeAreaBottomInset
        writeView.updateContainerBottomConstraint(inset: inset)
        
        // 업데이트 된 레이아웃 반영
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 키보드 사라질 때 호출되는 메서드
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        // 키보드가 사라지면 컨테이너 뷰의 제약 조건을 원래대로 복원
        writeView.updateContainerBottomConstraint(inset: 60)
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // UI 업데이트 메서드
    private func updateUI(with post: Post) {
        writeView.setTextViewText(post.content) // 텍스트뷰 업데이트
        writeView.collectionViewReload() // 컬렉션 뷰 리로드
    }
    
    // MARK: - 버튼 액션 메서드
    
    // 카메라 버튼 탭할 때 호출되는 메서드
    @objc private func openCamera() {
        // 이미지 첨부 상한에 도달하면 알림 보내기(현재는 1개)
        guard writeViewModel.images.count < 1 else {
            showAlertMaxImageLimitReached()
            return
        }
        
        writeViewModel.requestCameraAccess { [weak self] isGranted in
            if isGranted {
                // 카메라 권한이 허용된 경우 카메라 생성 및 표시
                let cameraPicker = self?.writeViewModel.createCameraPicker()
                if let picker = cameraPicker {
                    self?.present(picker, animated: true)
                }
            } else {
                // 권한이 거부된 경우 설정 화면으로 이동하는 알림 표시
                self?.showAlertGoToSetting()
            }
        }
    }
    
    // 이미지 버튼 탭할 때 호출되는 메서드
    @objc private func addImage() {
        // 이미지 첨부 상한에 도달하면 알림 보내기(현재는 1개)
        guard writeViewModel.images.count < 1 else {
            showAlertMaxImageLimitReached()
            return
        }
        
        writeViewModel.requestPhotoLibraryAccess { [weak self] isGranted in
            if isGranted {
                // 사진 라이브러리 권한이 허용된 경우 사진 피커 생성 및 표시
                let photoPicker = self?.writeViewModel.createPhotoPicker()
                if let picker = photoPicker {
                    self?.present(picker, animated: true)
                }
            } else {
                // 권한이 거부된 경우 설정 화면으로 이동하는 알림 표시
                self?.showAlertGoToSetting()
            }
        }
    }
    
    // 작성완료 버튼 탭할 때 호출되는 메서드
    @objc private func submitText() {
        guard !writeView.getTextViewText().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // 경고 메시지 표시
            let alert = UIAlertController(title: "행복 기록이 없습니다", message: "내용을 입력해주세요!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 작성 완료 알림 표시
        showCompletionAlert {
            // WriteViewModel에 작성 완료 이벤트 전달
            self.writeViewModel.submitPost {
                // 모달 닫기
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // 취소 버튼 탭할 때 호출되는 메서드
    @objc private func tapDismiss() {
        // WriteViewModel에 취소 이벤트 전달
        writeViewModel.cancelPost()
        // 모달 닫기
        dismiss(animated: true, completion: nil)
    }

    // 카메라 권한이 없는 경우 설정 화면으로 이동하는 Alert 표시
    private func showAlertGoToSetting() {
        let alertControlelr  = UIAlertController(
            title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
            message: "설정 > Sodam 탭에서 접근 권한을 활성화 해주세요.",
            preferredStyle: .alert
        )
        
        // 취소 버튼
        let cancelAlert = UIAlertAction(title: "취소", style: .cancel) { _ in
            alertControlelr.dismiss(animated: true, completion: nil)
        }
        
        // 설정으로 이동하는 버튼
        let doneAlert = UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingURL)
            else {
                return
            }
            UIApplication.shared.open(settingURL, options: [:])
        }
        
        // Alert에 버튼 추가
        [
            cancelAlert,
            doneAlert
        ].forEach(alertControlelr.addAction(_:))
        
        // Alert 표시
        DispatchQueue.main.async {
            self.present(alertControlelr, animated: true)
        }
    }
    
    // MARK: - Alert 메서드
    
    // 이미지 상한을 알리는 Alert 표시
    private func showAlertMaxImageLimitReached() {
        let alert = UIAlertController(
            title: "이미지를 추가할 수 없습니다.",
            message: "하나의 글에 최대 한 개의 이미지만 추가할 수 있습니다.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    // 작성 완료 Alert
    private func showCompletionAlert(completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "작성 완료",
            message: "글이 성공적으로 작성되었습니다!",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            alert.dismiss(animated: true, completion: completion)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - 컬렉션뷰 DataSource 설정

extension WriteViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return writeViewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let image = writeViewModel.images[indexPath.item]
        cell.configure(with: image)
        
        // 삭제 클로저 설정
        cell.onDelete = { [weak self] in
            self?.writeViewModel.removeImage(at: indexPath.item)
            collectionView.reloadData()
        }
        return cell
    }
}

// MARK: - 텍스트뷰 deleage 설정

extension WriteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트가 변경될 때마다 뷰모델에 전달
        writeViewModel.updateText(textView.text)
    }
}
