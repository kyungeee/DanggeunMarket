//
//  SelectedImageView.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import UIKit

class SelectedImageView: UIView {
    
    // MARK: - UI Components
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private lazy var removeImageButton: UIButton =  {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(scale: .medium), forImageIn: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.layer.cornerRadius = 12
        button.backgroundColor = .systemGray
        
        return button
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


extension SelectedImageView {
    // MARK: - UI Update
    
    private func setLayout() {
        self.addSubviews(imageView, removeImageButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            removeImageButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            removeImageButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            removeImageButton.widthAnchor.constraint(equalToConstant: 24),
            removeImageButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
    }
    
}
