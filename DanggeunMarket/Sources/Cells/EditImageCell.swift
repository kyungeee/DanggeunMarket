//
//  EditImageCell.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/27.
//

import UIKit

class EditImageCell: UICollectionViewCell {
    
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    lazy var editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // 이미지 비율 유지
        imageView.clipsToBounds = true // 셀의 경계를 넘어가는 이미지를 잘라냄
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(editImageView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        self.contentView.addSubviews(editImageView)
        NSLayoutConstraint.activate([
            editImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            editImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            editImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            editImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    public func configure(with image: UIImage) {
        editImageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        editImageView.image = nil
    }
}
