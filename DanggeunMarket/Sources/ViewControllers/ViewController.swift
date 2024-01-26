//
//  ViewController.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController {
    
    // MARK: - UI Components
    lazy var imageScrollView = ImageScrollView()
    
    lazy var selectImageButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        button.backgroundColor = .black
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
}

extension ViewController {
    
    func setLayout() {
        self.view.addSubviews(imageScrollView, selectImageButton)
        self.view.backgroundColor = .red
        self.imageScrollView.backgroundColor = .blue
        NSLayoutConstraint.activate([
            imageScrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            imageScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            imageScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            imageScrollView.heightAnchor.constraint(equalToConstant: 70),
            selectImageButton.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 20), // 수정된 부분
            selectImageButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            selectImageButton.widthAnchor.constraint(equalToConstant: 24),
            selectImageButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
}



extension ViewController {
    
    
}

