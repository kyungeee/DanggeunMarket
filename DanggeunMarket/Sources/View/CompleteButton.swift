//
//  CompleteButton.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/25.
//


import UIKit

class CompleteButton: UIView {
    
    // MARK: - UI Components

    lazy var naviRightItemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .orange
        label.text = "2"
        return label
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "완료"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
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


extension CompleteButton {
    private func setLayout() {
        self.addSubviews(naviRightItemStackView)
        self.naviRightItemStackView.addArrangedSubviews(numberLabel, textLabel)
        
        NSLayoutConstraint.activate([
            naviRightItemStackView.topAnchor.constraint(equalTo: self.topAnchor),
            naviRightItemStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            naviRightItemStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            naviRightItemStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
}
