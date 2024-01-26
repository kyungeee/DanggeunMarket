//
//  EditButton.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/25.
//

import UIKit


class EditButtonView: UIView {

    // MARK: - UI Components
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var editLabel: UILabel = {
        let label = UILabel()
        label.text = "편집"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    // MARK: - Setup
    private func setupLayout() {
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(editImageView)
        buttonStackView.addArrangedSubview(editLabel)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
