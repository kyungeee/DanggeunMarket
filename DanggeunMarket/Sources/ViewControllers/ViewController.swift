//
//  ViewController.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController, UIScrollViewDelegate {
    
    var authService: AuthServiceInterface
    var selectedPhotos: [UIImage] = []
    
    // MARK: - UI Components
    lazy var imageScrollView = ImageScrollView()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    
    lazy var selectImageButton: UIButton = {
        var button = UIButton()
        if let image = UIImage(systemName: "carrot.fill")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(image, for: .normal)
            button.tintColor = .white
        }
        button.setTitle("사진 선택하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(presentSecondViewController), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    init(authService: AuthServiceInterface) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController {
    func configureUI() {
        setDetail()
        setLayout()
        setScrollView()
    }
    
    final private func setScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    func setDetail() {
        scrollView.backgroundColor = .black
        self.view.backgroundColor = .white
    }
    
    func setLayout() {
        
        view.addSubviews(scrollView, selectImageButton)
        scrollView.addSubviews(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -150),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 3.0),
            
            selectImageButton.topAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: 30),
            selectImageButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            selectImageButton.widthAnchor.constraint(equalToConstant: 200),
            selectImageButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
    
    func scrollWithImageView() {
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        for (index, photo) in selectedPhotos.enumerated() {
            let imageView = UIImageView()
            let positionX = self.view.frame.width * CGFloat(index)
            imageView.frame = CGRect(x: positionX, y: -150, width: self.view.bounds.width, height: self.view.bounds.height)
            imageView.image = photo
            imageView.contentMode = .scaleAspectFit
            
            contentView.addSubview(imageView)
        }
        
        let totalContentWidth = self.view.frame.width * CGFloat(selectedPhotos.count)
        scrollView.contentSize = CGSize(width: totalContentWidth, height: scrollView.frame.height)
    }
}

extension ViewController {
    @objc func presentSecondViewController() {
       
        if authService.photoAuth() {
            let authService = AuthService()
            let galleryVC = PhotoPickerViewController(authService: authService)
            let navigationController = UINavigationController(rootViewController: galleryVC)
            navigationController.modalPresentationStyle = .fullScreen
            galleryVC.delegate = self
            self.present(navigationController, animated: true, completion: nil)
        } else {
            let alert =  authService.AuthSettingOpen(authString: "앨범")
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: didFinishTakingPhotoDelegate {
    func didFinishTakingPhoto(_ photo: [UIImage]) {
        self.selectedPhotos = photo
        scrollWithImageView()
    }
    
    func didFinishSelectingPhotos(_ photos: [UIImage]) {
        self.selectedPhotos = photos
        scrollWithImageView()
    }
}
