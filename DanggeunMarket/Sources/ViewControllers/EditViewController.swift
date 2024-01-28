//
//  EditViewController.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/26.
//


import UIKit


// 이미지 크롭을 담당할 뷰 컨트롤러
class EditViewController: UIViewController {
    
    // MARK: - Properties
    var selectedPhotos: [PhotoCellInfo]
    
    // MARK: - UI Components
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EditImageCell.self, forCellWithReuseIdentifier: EditImageCell.cellIdentifier)
        return collectionView
    }()
    
    var imageView: UIImageView!
    var cropAreaView: UIView!
    
    lazy var cropView: CropView = {
        let view = CropView()
        view.isHidden = true
        return view
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 20, y: view.bounds.height - 50, width: 100, height: 30)
        button.addTarget(self, action: #selector(toggleCropView), for: .touchUpInside)
        return button
    }()
    
    lazy var rotateButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 20, y: view.bounds.height - 50, width: 100, height: 30)
        button.addTarget(self, action: #selector(toggleCropView), for: .touchUpInside)
        return button
    }()
    
    var currentSelectedIdx: Int = 0
    
    private var previousOffset: CGFloat = 0
    private var currentPage: Int = 0
    
    init(selectedPhotos: [PhotoCellInfo]) {
        self.selectedPhotos = selectedPhotos
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupConstraints()
        self.cropView.delegate = self
//        setupButtons()
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .black
        let collectionViewLayout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height - 80)
            layout.minimumLineSpacing = 30
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            return layout
        }()
        
        collectionView.collectionViewLayout = collectionViewLayout
        
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
    }
    
    
    private func setupButtons() {
        let cancelButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 50, width: 100, height: 30))
        cancelButton.setImage(UIImage(systemName: "crop"), for: .normal)
        cancelButton.addTarget(self, action: #selector(toggleCropView), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        let rotateButton = UIButton(frame: CGRect(x: view.bounds.width - 120, y: view.bounds.height - 50, width: 100, height: 30))
        rotateButton.setImage(UIImage(systemName: "rotate.right"), for: .normal)
        rotateButton.addTarget(self, action: #selector(useAction), for: .touchUpInside)
        view.addSubview(rotateButton)
    }
    
}

extension EditViewController {
    private func setupConstraints() {
        self.view.addSubviews(collectionView, cropView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupButtons()
        
        NSLayoutConstraint.activate([
            cropView.topAnchor.constraint(equalTo: view.topAnchor),
            cropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cropView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
}


extension EditViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditImageCell.cellIdentifier, for: indexPath) as! EditImageCell
        
        cell.editImageView.image = selectedPhotos[indexPath.item].image ?? UIImage(named: "dragon")
        cell.backgroundColor = .black
        
        return cell
    }
}

extension EditViewController: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let point = self.targetContentOffset(scrollView, withVelocity: velocity)
        targetContentOffset.pointee = point
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
            self.collectionView.setContentOffset(point, animated: true)
        }, completion: nil)
    }
    
    func targetContentOffset(_ scrollView: UIScrollView, withVelocity velocity: CGPoint) -> CGPoint {
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        if previousOffset > collectionView.contentOffset.x && velocity.x < 0 {
            currentPage = currentPage - 1
        } else if previousOffset < collectionView.contentOffset.x && velocity.x > 0 {
            currentPage = currentPage + 1
        }
        
        let additional = (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) - flowLayout.headerReferenceSize.width
        
        let updatedOffset = (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * CGFloat(currentPage) - additional
        
        previousOffset = updatedOffset
        
        return CGPoint(x: updatedOffset, y: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentSelectedIdx = indexPath.item
    }
    
    func update(indexPath: IndexPath) {
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension EditViewController: CropViewDelegate {
    func cropViewDidCompleteCropping(image: UIImage) {
        // cropView가 크롭 작업을 완료했을 때 수행할 작업
        cropView.isHidden = true
        self.selectedPhotos[currentSelectedIdx].image = image
        update(indexPath: [currentSelectedIdx])
        
    }
}

extension EditViewController {
    
    @objc func toggleCropView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cropView.isHidden = !self.cropView.isHidden
        })
    }
    
    @objc private func cancelAction() {
        // 취소 버튼의 동작을 구현합니다.
    }
    
    @objc private func useAction() {
        // 'Use' 버튼을 탭했을 때의 동작을 구현합니다.

    }
    
    @objc func backToFirstViewController() {
        self.navigationController?.popToRootViewController(animated: false)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
