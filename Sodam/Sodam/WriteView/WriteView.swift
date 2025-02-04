//
//  WriteView.swift
//  Sodam
//
//  Created by 박민석 on 1/23/25.
//

import UIKit
import SnapKit

class WriteView: UIView {
    
    // 제약 조건 변수 선언
    private var containerBottomConstraint: Constraint?
    
    // MARK: - UI 컴포넌트 선언
    
    // 화면 상단 날짜 레이블
    private let dateLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        label.font = .mapoGoldenPier(20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    // 글 작성 텍스트뷰
    private let textView: UITextView = {
        let textView: UITextView = UITextView()
        textView.font = .sejongGeulggot(16)
        textView.textColor = .darkGray
        textView.backgroundColor = .viewBackground
        return textView
    }()
    
    // 텍스트뷰에 띄울 placeholder
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "행복을 작성해주세요"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    // 이미지뷰를 담을 컬렉션뷰
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .viewBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        return collectionView
    }()
    
    // 카메라 버튼
    private let cameraButton: UIButton = {
        let button: UIButton = UIButton()
        button.tintColor = .gray
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "camera")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20) // 이미지 크기 설정
        button.configuration = config
        return button
    }()
    
    // 사진 선택 버튼
    private let imageButton: UIButton = {
        let button: UIButton = UIButton()
        button.tintColor = .gray
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "photo.on.rectangle")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20)
        button.configuration = config
        return button
    }()
    
    // 작성 완료 버튼
    private let submitButton: UIButton = {
        let button: UIButton = UIButton()
        button.tintColor = .gray
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "checkmark")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20)
        button.configuration = config
        return button
    }()
    
    // dismiss 버튼
    private let dismisslButton: UIButton = {
        let button: UIButton = UIButton()
        button.tintColor = .gray
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20)
        button.configuration = config
        return button
    }()
    
    // 바 추가
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 바의 배경색
        view.layer.cornerRadius = 4 // 모서리 둥글기
        return view
    }()
    
    // MARK: - 초기화
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI 셋업
    
    // UI 셋업
    private func setupUI() {
        backgroundColor = .viewBackground
        
        let containerView: UIView = UIView()
        [
            collectionView,
            cameraButton,
            imageButton,
            submitButton,
        ].forEach { containerView.addSubview($0) }

        [
            dateLabel,
            textView,
            placeholderLabel,
            dismisslButton,
            containerView,
            topBar
        ].forEach { addSubview($0) }
        
        // 바 제약 조건 설정
        topBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(5)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(60)
            make.height.equalTo(safeAreaLayoutGuide.snp.height).multipliedBy(0.05)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(80)
        }
        
        dismisslButton.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel.snp.centerY)
            make.width.height.equalTo(36)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).offset(-20)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.height.equalTo(safeAreaLayoutGuide.snp.height).multipliedBy(0.6)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(textView).offset(8)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(safeAreaLayoutGuide.snp.height).multipliedBy(0.20)
            containerBottomConstraint = make.bottom.equalTo(safeAreaLayoutGuide).inset(60).constraint
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(safeAreaLayoutGuide.snp.width).multipliedBy(0.25)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom)
            make.width.height.equalTo(36)
            make.leading.equalTo(textView.snp.leading)
        }
        
        imageButton.snp.makeConstraints { make in
            make.centerY.equalTo(cameraButton)
            make.width.height.equalTo(36)
            make.leading.equalTo(cameraButton.snp.trailing).offset(16)
        }
        
        submitButton.snp.makeConstraints { make in
            make.centerY.equalTo(cameraButton)
            make.width.height.equalTo(36)
            make.trailing.equalTo(textView.snp.trailing)
        }
    }
    
    // MARK: - UI 접근 메서드
    
    // 하단 UI constraints 조절 메서드
    func updateContainerBottomConstraint(inset: CGFloat) {
        containerBottomConstraint?.update(inset: inset)
    }
    
    // 컬렉션뷰 dataSource 설정 메서드
    func setCollectionViewDataSource(dataSource: UICollectionViewDataSource) {
        collectionView.dataSource = dataSource
    }
    
    // 텍스트뷰 delegate 설정 메서드
    func setTextViewDeleaget(delegate: UITextViewDelegate) {
        textView.delegate = delegate
    }
    // 텍스트뷰 내용 변경 메서드
    func setTextViewText(_ text: String) {
        textView.text = text
        updatePlaceholderVisibility() // 텍스트 변경 시 Placeholder 업데이트
    }
    
    // 텍스트뷰 내용 접근 메서드
    func getTextViewText() -> String {
        return textView.text
    }
    
    // placeholder 숨김처리 메서드
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // 카메라 버튼 액션 설정 메서드
    func setCameraButtonAction(target: Any, cameraSelector: Selector) {
        cameraButton.addTarget(target, action: cameraSelector, for: .touchUpInside)
    }
    // 사진 버튼 액션 설정 메서드
    func setImageButtonAction(target: Any, imageSelector: Selector) {
        imageButton.addTarget(target, action: imageSelector, for: .touchUpInside)
    }
    // 작성완료 버튼 액션 설정 메서드
    func setSubmitButtonAction(target: Any, submitSelector: Selector) {
        submitButton.addTarget(target, action: submitSelector, for: .touchUpInside)
    }
    // dismiss 버튼 액션 설정 메서드
    func setDismissButtonAction(target: Any, dismissSelector: Selector) {
        dismisslButton.addTarget(target, action: dismissSelector, for: .touchUpInside)
    }
    
    // 컬렉션뷰 리로드 메서드
    func collectionViewReload() {
        collectionView.reloadData()
    }
}
