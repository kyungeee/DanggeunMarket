//
//  ImageCell.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//


import UIKit
import Photos
import PhotosUI

enum SelectionOrder {
    case none
    case selected(Int)
}

class PhotoCell: UICollectionViewCell {
    
    //MARK: - View's LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        prepare(info: nil)
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
    

    lazy var highlightedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 4.0
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.borderColor = UIColor.orange.cgColor
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    lazy var selectedNumberButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 3
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .selected)
        button.tintColor = UIColor.clear
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
        let isSelected = !selectedNumberButton.isSelected
        // 선택 여부에 따라 외형 업데이트
        updateButtonAppearance(selected: isSelected)
    }
    
}

extension PhotoCell {
    
    private func setUpViews() {
        self.contentView.addSubviews(imageView, selectedNumberButton)
        self.imageView.addSubviews(highlightedView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            highlightedView.topAnchor.constraint(equalTo: self.imageView.topAnchor),
            highlightedView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            highlightedView.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
            highlightedView.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            
            selectedNumberButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            selectedNumberButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            selectedNumberButton.widthAnchor.constraint(equalToConstant: 24),
            selectedNumberButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
        
    func updateButtonAppearance(selected: Bool) {
        if !selected {
            selectedNumberButton.layer.backgroundColor = UIColor.clear.cgColor
            selectedNumberButton.layer.borderColor = UIColor.white.cgColor
        } else {
            selectedNumberButton.layer.backgroundColor = UIColor.orange.cgColor
            selectedNumberButton.layer.borderColor = UIColor.orange.cgColor
        }

        selectedNumberButton.isSelected = selected
    }
    

    func prepare(info: PhotoCellInfo?) {
        imageView.image = info?.image
        if case let .selected(order) = info?.selectedOrder {
            highlightedView.isHidden = false
            selectedNumberButton.setTitle(String(order), for: .selected)
            updateButtonAppearance(selected: true)
        } else {
            highlightedView.isHidden = true
            updateButtonAppearance(selected: false)
        }
    }
    
}


