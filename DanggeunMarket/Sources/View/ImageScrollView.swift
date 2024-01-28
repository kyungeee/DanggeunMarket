//
//  ImageScrollView.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import UIKit


class ImageScrollView: UIView {
    
    // UI Components
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        udpateUI(images: [])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()
        udpateUI(images: [])
    }
    
}

extension ImageScrollView {
    
    // Update UI
    private func setLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        self.addSubview(scrollView)
        
        var scrollViewAnchors = [NSLayoutConstraint]()
        
        scrollViewAnchors.append(scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0))
        scrollViewAnchors.append(scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0))
        scrollViewAnchors.append(scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0))
        scrollViewAnchors.append(scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0))
        NSLayoutConstraint.activate(scrollViewAnchors)
        
       
        var stackViewAnchors = [NSLayoutConstraint]()
        stackViewAnchors.append(stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0))
        stackViewAnchors.append(stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0))
        stackViewAnchors.append(stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0))
        stackViewAnchors.append(stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0))
        NSLayoutConstraint.activate(stackViewAnchors)
        
    }
    
    func udpateUI(images: [UIImage]) {
        for (index, item) in images.enumerated() {
            let image: UIImage = item
            stackView.addArrangedSubviews(createImageView(index: index, item: image))
        }
    }
    
    private func createImageView(index: Int, item: UIImage) -> UIView {
        let view = SelectedImageView()
        
        view.backgroundColor = .clear
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        
        view.imageView.image = item
        
        return view
    }
    
}

