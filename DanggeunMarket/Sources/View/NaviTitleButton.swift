//
//  NaviTitleButton.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/25.
//


import UIKit

class NaviTitleButton: UIView {
    
    // MARK: - UI Components

    lazy var naviTitleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    
    lazy var downImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 항목"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()
    }
    
}


extension NaviTitleButton {
    private func setLayout() {
        self.addSubviews(naviTitleStackView)
        self.naviTitleStackView.addArrangedSubviews(titleLabel, downImage)
        
        NSLayoutConstraint.activate([
            naviTitleStackView.topAnchor.constraint(equalTo: self.topAnchor),
            naviTitleStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            naviTitleStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            naviTitleStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
}

