//
//  CameraCell.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import UIKit

class CameraCell: UICollectionViewCell {
    
    //MARK: - View's LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
//        setUpAlbumCoverPlaceHolderImage()
    }
    
    // MARK: - UI Components
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    lazy var cameraImage: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(systemName: "camera.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            imageView.image = image
        }
        return imageView
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraCell {
    private func setup(){
        setCellAttribute()
        setLayout()
    }
    
    private func setCellAttribute() {
        backgroundColor = .lightGray
    }
    
    private func setLayout() {
        self.contentView.addSubviews(cameraImage)
        
        NSLayoutConstraint.activate([
            cameraImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cameraImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cameraImage.heightAnchor.constraint(equalToConstant: 30),
            cameraImage.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
 
}
