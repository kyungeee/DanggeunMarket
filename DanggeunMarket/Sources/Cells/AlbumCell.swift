//
//  AlbumCell.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/25.
//


import UIKit
class AlbumCell: UITableViewCell {
    
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    //MARK: - View's LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        setUpAlbumCoverPlaceHolderImage()
    }
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    //MARK: - Properties
    lazy var albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    lazy var albumTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    
    //MARK: - Handlers
    fileprivate func setUpViews() {
        backgroundColor = .clear
        selectionStyle = .none
        self.contentView.backgroundColor = .white
        self.contentView.addSubviews(albumCoverImageView, albumTitleLabel)
        
        NSLayoutConstraint.activate([
            albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            albumCoverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumCoverImageView.widthAnchor.constraint(equalToConstant: 50),
            albumCoverImageView.heightAnchor.constraint(equalToConstant: 50),
            
            albumTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumTitleLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: 12),
            albumTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])

    }
    
    
    func bindData(albumTitle: String, albumCoverImage: UIImage?) {
        albumTitleLabel.text = albumTitle
        albumCoverImageView.image = albumCoverImage
        albumCoverImageView.contentMode = .scaleAspectFill
    }
    
    
    fileprivate func setUpAlbumCoverPlaceHolderImage() {
        albumCoverImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        albumCoverImageView.tintColor = .gray
        albumCoverImageView.contentMode = .scaleAspectFit
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


