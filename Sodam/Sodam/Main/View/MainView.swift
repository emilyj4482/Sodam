//
//  MainView.swift
//  Sodam
//
//  Created by 손겸 on 1/21/25.
//

import UIKit
import SnapKit

final class MainView: UIView {
    
    // 행담이 이름 라벨 뷰
    private let nameLabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .mapoGoldenPier(27)
        label.textColor = .textAccent
        label.isHidden = true // 초기 상태에는 숨김
        return label
    }()
    
    // 이미지 뷰
    let circularImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .imageBackground
        
        // 원형 스타일
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    // 라벨 뷰
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "행담이에게 행복한 기억을 먹여주세욤 >< 뿌뿌~~"
        label.textAlignment = .center
        label.font = .mapoGoldenPier(18)
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    // 버튼 뷰
    public let createbutton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("행복 작성하기", for: .normal)
        button.setTitleColor(.imageBackground, for: .normal)
        button.titleLabel?.font = .mapoGoldenPier(20)
        button.backgroundColor = .buttonBackground
        button.layer.cornerRadius = 15
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .viewBackground
        [
            nameLabel,
            circularImageView,
            messageLabel,
            createbutton
        ].forEach { addSubview($0) }
        
        // UI 제약
        nameLabel.snp.makeConstraints {
            $0.bottom.equalTo(circularImageView.snp.top).offset(-30)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
        circularImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(UIScreen.main.bounds.height * 0.15) // 화면 높이의 15%로 높이를 맞춤
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalTo(circularImageView.snp.width)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(circularImageView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.85)
        }
        
        createbutton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(40) // se에서 글자 겹쳐서 탭바사이 간격 좀 줄임
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.width.equalToSuperview().multipliedBy(0.85)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circularImageView.layer.cornerRadius = circularImageView.frame.width / 2
    }
    
    // 메세지라벨
    func updateMessage(_ message: String) {
        messageLabel.text = message
    }
    
    // 이름 라벨 업데이트
    func updateNameLabel(_ name: String?) {
        if let name = name, !name.isEmpty {
            nameLabel.text = name
            nameLabel.isHidden = false
        } else {
            nameLabel.isHidden = true
            nameLabel.text = "이름을 지어주세요"
            nameLabel.isHidden = false
        }
    }
    
    // GIF 업데이트 메서드 추가
    func updateGif(with name: String) {
        if let gifImage = UIImage.animatedImage(withGIFNamed: name) {
            circularImageView.image = gifImage
        }
        
        
    }
}
