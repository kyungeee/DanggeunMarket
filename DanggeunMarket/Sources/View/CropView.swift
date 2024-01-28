//
//  CropView.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/27.
//

import UIKit
import Photos

protocol CropViewDelegate: AnyObject {
    func cropViewDidCompleteCropping(image: UIImage)
}


class CropView: UIView {
    var imageView: UIImageView!
    var cropAreaView: UIView!
    var anchors: [UIView] = []
    
    var cropedImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.addTarget(self, action: #selector(cropComplete), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    weak var delegate: CropViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView = UIImageView(image: UIImage(named: "dragon")) // Replace "dragon" with your image name
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 50),
            imageView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            imageView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            imageView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -30)
        ])
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentSize = calculateContentSizeOfImageView(imageView: imageView)
        if cropAreaView == nil {
            setupCropAreaView(frame: contentSize)
            setupAnchors()
            setupCompleteButton()
        } else {
            cropAreaView.frame = contentSize
            positionAnchors()
            setupCompleteButton()
        }
    }
    
    func calculateContentSizeOfImageView(imageView: UIImageView) -> CGRect {
        guard let image = imageView.image else { return .zero }
        let imageViewRatio = imageView.bounds.size.width / imageView.bounds.size.height
        let imageRatio = image.size.width / image.size.height
        let scale = (imageViewRatio < imageRatio) ?
        imageView.bounds.size.width / image.size.width :
        imageView.bounds.size.height / image.size.height
        
        let scaledImageSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let imageX = (imageView.bounds.size.width - scaledImageSize.width) / 2.0
        let imageY = (imageView.bounds.size.height - scaledImageSize.height) / 2.0
        
        return CGRect(x: imageX, y: imageY, width: scaledImageSize.width, height: scaledImageSize.height)
    }
    
    
    func setupCropAreaView(frame: CGRect? = nil) {
        let padding: CGFloat = 10 // 원하는 padding 값을 설정합니다.
        let frame = frame ?? imageView.bounds.insetBy(dx: padding, dy: padding)
        
        cropAreaView = UIView()
        cropAreaView.frame = frame
        cropAreaView.layer.borderColor = UIColor.white.cgColor
        cropAreaView.layer.borderWidth = 1
        cropAreaView.isUserInteractionEnabled = true
        imageView.addSubview(cropAreaView)
        
        setupAnchors()
    }
    
    func setupCompleteButton() {
        self.imageView.addSubviews(completeButton)
        NSLayoutConstraint.activate([
            completeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 25),
            completeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
            completeButton.widthAnchor.constraint(equalToConstant: 100),
            completeButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupAnchors() {
        anchors.forEach { $0.removeFromSuperview() }
        anchors.removeAll()
        
        let anchorSize: CGFloat = 20
        for _ in 0..<4 {
            let anchorView = UIView()
            anchorView.backgroundColor = UIColor.white
            anchorView.frame.size = CGSize(width: anchorSize, height: anchorSize)
            anchorView.layer.cornerRadius = anchorSize / 2
            anchorView.isUserInteractionEnabled = true
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            anchorView.addGestureRecognizer(panGesture)
            
            anchors.append(anchorView)
            imageView.addSubview(anchorView)
        }
        
        positionAnchors()
    }
    
    
    func positionAnchors() {
        anchors[0].center = CGPoint(x: cropAreaView.frame.minX, y: cropAreaView.frame.minY) // Top Left
        anchors[1].center = CGPoint(x: cropAreaView.frame.maxX, y: cropAreaView.frame.minY) // Top Right
        anchors[2].center = CGPoint(x: cropAreaView.frame.minX, y: cropAreaView.frame.maxY) // Bottom Left
        anchors[3].center = CGPoint(x: cropAreaView.frame.maxX, y: cropAreaView.frame.maxY) // Bottom Right
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let anchorView = gesture.view, let index = anchors.firstIndex(of: anchorView) else { return }
        let translation = gesture.translation(in: imageView)
        
        // 드래그에 따른 새 위치 계산
        var newCenter = CGPoint(x: anchorView.center.x + translation.x, y: anchorView.center.y + translation.y)
        
        // 새 위치가 imageView의 contentSize 내에 있는지 확인하고, 필요하면 조정
        newCenter.x = max(imageView.frame.minX, min(newCenter.x, imageView.frame.maxX))
        newCenter.y = max(imageView.frame.minY, min(newCenter.y, imageView.frame.maxY))
        
        // 제스처 상태에 따라 처리
        switch gesture.state {
        case .began, .changed:
            // 앵커 뷰를 이동
            anchorView.center = newCenter
            // 드래그 제스처의 이동 거리를 리셋
            gesture.setTranslation(.zero, in: imageView)
            updateCropAreaBasedOnAnchors(index: index)
            positionAnchorsExcept(index: index)
            // cropAreaView의 크기와 위치 업데이트
        default:
            break
        }
    }
    
    func updateCropAreaBasedOnAnchors(index: Int) {
        // 모든 앵커의 위치를 기반으로 cropAreaView의 새로운 프레임 계산
        let minX = anchors.map { $0.center.x }.min() ?? cropAreaView.frame.minX
        let maxX = anchors.map { $0.center.x }.max() ?? cropAreaView.frame.maxX
        let minY = anchors.map { $0.center.y }.min() ?? cropAreaView.frame.minY
        let maxY = anchors.map { $0.center.y }.max() ?? cropAreaView.frame.maxY
        
        // 앵커 위치에 따라 cropAreaView의 프레임 업데이트
        cropAreaView.frame = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        
        // 나머지 앵커들도 적절한 위치로 이동
        //        positionAnchorsExcept(index: index)
    }
    
    func positionAnchorsExcept(index: Int) {
        // 각 앵커의 위치를 조정할 때는 다른 앵커들의 위치가 고정되어야 합니다.
        // 예를 들어, 왼쪽 상단 앵커를 드래그할 때는 오른쪽 상단과 왼쪽 하단 앵커의 위치를 고정시켜야 합니다.
        switch index {
        case 0: // 왼쪽 상단 앵커가 드래그 중일 때
            //            anchors[2].center.y = cropAreaView.frame.minY // 오른쪽 상단 앵커의 y 위치 고정
            //            anchors[2].center.x = cropAreaView.frame.
            //            anchors[1].center.x = cropAreaView.frame.minX // 왼쪽 하단 앵커의 x 위치 고정
            anchors[1].center.y = anchors[0].center.y
            anchors[2].center.x = anchors[0].center.x
        case 1: // 오른쪽 상단 앵커가 드래그 중일 때
            anchors[0].center.y = anchors[1].center.y// 왼쪽 상단 앵커의 y 위치 고정
            anchors[3].center.x = anchors[1].center.x /// 오른쪽 하단 앵커의 x 위치 고정
        case 2: // 왼쪽 하단 앵커가 드래그 중일 때
            anchors[0].center.x = anchors[2].center.x // 왼쪽 상단 앵커의 x 위치 고정
            anchors[3].center.y = anchors[2].center.y// 오른쪽 하단 앵커의 y 위치 고정
        case 3: // 오른쪽 하단 앵커가 드래그 중일 때
            anchors[1].center.x = anchors[3].center.x // 오른쪽 상단 앵커의 x 위치 고정
            anchors[2].center.y = anchors[3].center.y // 왼쪽 하단 앵커의 y 위치 고정
        default:
            break
        }
    }
    
    func cropImage() -> UIImage? {
        // `imageView`의 좌표계에서 이미지의 좌표계로 `cropAreaView.frame`을 변환합니다.
        guard let image = imageView.image,
              let cgImage = image.cgImage,
              let croppedCGImage = cgImage.cropping(to: convertRectToImageCoordinates(rect: cropAreaView.frame)) else { return nil }
        
        return UIImage(cgImage: croppedCGImage)
    }
    
    func convertRectToImageCoordinates(rect: CGRect) -> CGRect {
        guard let image = imageView.image else { return .zero }
        
        let contentRect = calculateContentSizeOfImageView(imageView: imageView)
        let scale = image.scale
        let x = (rect.origin.x - contentRect.origin.x) * scale
        let y = (rect.origin.y - contentRect.origin.y) * scale
        let width = rect.size.width * scale
        let height = rect.size.height * scale
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension CropView {
    @objc func cropComplete() {
        print("Crop complete, calling delegate method")
        if let croppedImage = cropImage() {
            delegate?.cropViewDidCompleteCropping(image: croppedImage)
        }
    }
}


