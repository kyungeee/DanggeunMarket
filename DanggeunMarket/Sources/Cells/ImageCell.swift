//
//  ImageCell.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//


import UIKit

class ImageCell: UICollectionViewCell {
    
    //MARK: - View's LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
//        setUpAlbumCoverPlaceHolderImage()
    }
    
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    // MARK: - UI Components
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("1", for: .normal)
        return button
    }()
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 버튼이 탭되었을 때 호출되는 메소드
    @objc func buttonTapped() {
        // 버튼의 선택 여부를 토글
        let isSelected = !selectButton.isSelected
        // 선택 여부에 따라 외형 업데이트
        updateButtonAppearance(selected: isSelected)
    }
    
    // 버튼 외형을 업데이트하는 메소드
    func updateButtonAppearance(selected: Bool) {
        // 선택되지 않았을 때
        if !selected {
            selectButton.layer.backgroundColor = nil // 배경색 제거
            selectButton.layer.borderColor = UIColor.black.cgColor // 테두리 선 색상 유지
        } else {
            selectButton.layer.backgroundColor = UIColor.systemBlue.cgColor // 선택되었을 때 배경색 변경
            selectButton.layer.borderColor = nil // 테두리 선 제거
        }
        
        // 버튼의 선택 상태 업데이트
        selectButton.isSelected = selected
       }
    
}

extension ImageCell {
    
    private func setUpViews() {
        backgroundColor = .clear
        self.contentView.addSubviews(imageView, selectButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            selectButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            selectButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            selectButton.widthAnchor.constraint(equalToConstant: 30),
            selectButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
    }
}
