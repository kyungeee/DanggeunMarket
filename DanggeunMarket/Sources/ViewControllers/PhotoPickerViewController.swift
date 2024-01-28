//
//  PhotoPickerViewController.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import UIKit
import Photos
import PhotosUI

protocol didFinishTakingPhotoDelegate: AnyObject {
    func didFinishTakingPhoto(_ photo: [UIImage])
    func didFinishSelectingPhotos(_ photos: [UIImage])
}

final class PhotoPickerViewController: UIViewController {
    
    //MARK: - Properties
    
    private var authService: AuthService
    
    private var fetchResult: PHFetchResult<PHAsset>!
    
    private var allAlbums = [PHAssetCollection]()
    
    private let listOfsmartAlbumSubtypesToBeFetched: [PHAssetCollectionSubtype] = [.smartAlbumUserLibrary, .smartAlbumFavorites]
    
    private var dataSource = [PhotoCellInfo]()
    private var selectedPhotos = [PhotoCellInfo]()
    private var selectedIndexArray = [Int]()
    
    weak var delegate: didFinishTakingPhotoDelegate?
    
    // MARK: - UI Components
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CameraCell.self, forCellWithReuseIdentifier: CameraCell.cellIdentifier)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.cellIdentifier)
        return collectionView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.cellIdentifier)
        return tableView
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        return button
    }()
    
    lazy var navigationTitleButton = NaviTitleButton()
    lazy var compeleteButton = CompleteButton()
    
    lazy var bottomToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    lazy var editButton: EditButtonView = {
        let editButton = EditButtonView()
        editButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editButtonTapped))
        editButton.addGestureRecognizer(tapGesture)
        editButton.isUserInteractionEnabled = true
        return editButton
    }()
    
    lazy var limitView = UIView()
    lazy var limitTextLabel: UILabel = {
        let label = UILabel()
        label.text = "지금 모든 사진 접근 권한을 허용하면 더 쉽고 편하게 사진을 올릴 수 있어요"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        return label
    }()
    
    lazy var goToSetting: UILabel = {
        let label = UILabel()
        label.text = "사진 접근 허용하기"
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self

        if authService.isPhotoLimitAuth() {
            self.limitView.isHidden = false
        } else {
            self.limitView.isHidden = true
        }
        
        setup()
        loadPhotosFromLibrary()
        
    }
    
    init(authService: AuthService) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


// TODO: - VM 로 비즈니스 로직 리펙터링
extension PhotoPickerViewController {
    // MARK: - PhotoKit
    
    // MARK: 최근 항목 앨범 이미지 불러오기, 앨범 목록 불러오기
    func loadPhotosFromLibrary() {
        
        // 스마트 앨범 로드
        for collectionSubType in listOfsmartAlbumSubtypesToBeFetched {
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: collectionSubType, options: nil)
            smartAlbums.enumerateObjects { (collection, _, _) in
                self.allAlbums.append(collection)
            }
        }
        
        // 사용자 생성 앨범 로드
        let userCreatedAlbumsOptions = PHFetchOptions()
        userCreatedAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: userCreatedAlbumsOptions)
        userAlbums.enumerateObjects { (collection, _, _) in
            self.allAlbums.append(collection)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchOptions.sortDescriptors = [sortDescriptor]
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        fetchResult.enumerateObjects { (asset, _, _) in
            let image = self.getAssetThumbnail(asset: asset, size: PHImageManagerMaximumSize)
            let photoInfo = PhotoCellInfo(phAsset: asset, image: image, selectedOrder: .none)
            
            self.dataSource.append(photoInfo)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: 선택한 앨범 사진 asset 가져오기
    func handleDidSelect(album: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        let fetchedAssets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        fetchResult = fetchedAssets
        
        dataSource = []
        selectedIndexArray = []
        
        fetchResult.enumerateObjects { (asset, index, _) in
            var photoInfo: PhotoCellInfo
            if let info = self.selectedPhotos.first(where: { $0.phAsset == asset }) {
                photoInfo = PhotoCellInfo(phAsset: info.phAsset, image: info.image, selectedOrder: info.selectedOrder)
                self.selectedIndexArray.append(index + 1)
            } else {
                photoInfo = PhotoCellInfo(phAsset: asset, image: nil, selectedOrder: .none)
            }
            
            self.dataSource.append(photoInfo)
        }
    
        self.bindDataFromPhotosLibrary(fetchedAssets: self.fetchResult, albumTitle: album.localizedTitle ?? "")
        self.tableView.isHidden = !self.tableView.isHidden
        
    }
    
    // MARK: 앨범 선택 후 CollectionView 에 데이터 바인딩
    func bindDataFromPhotosLibrary(fetchedAssets: PHFetchResult<PHAsset>, albumTitle: String) {
        collectionView.reloadData()
        navigationTitleButton.titleLabel.text = albumTitle
        handleAnimateArrow(toIdentity: true)
        guard fetchResult.count != 0 else {return}
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
     }
      
    // MARK: 네비 타이틀 뷰 이미지 회전 애니메이션
    func handleAnimateArrow(toIdentity: Bool) {
        if toIdentity {
            navigationTitleButton.downImage.handleRotate180(rotate: false, withDuration: 0.2)
        } else {
            navigationTitleButton.downImage.handleRotate180(rotate: true, withDuration: 0.2)
        }
    }
        
    func getCurrentAlbumTitle() -> String {
        let albumTitle = navigationTitleButton.titleLabel.text ?? ""
        return albumTitle
    }
    
    // MARK: - asset 데이터로 부터 이미지 가져오기
    public func getAssetThumbnail(asset: PHAsset, size: CGSize) -> UIImage? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        var thumbnail: UIImage?
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) {(imageReturned, info) in
            guard let thumbnailUnwrapped = imageReturned else {return}
            thumbnail = thumbnailUnwrapped
        }
        return thumbnail
    }
    
}

extension PhotoPickerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let albumCell = dequeAlbumCell(for: indexPath)
        return albumCell
    }
    
    func dequeAlbumCell(for indexPath: IndexPath) -> UITableViewCell {
        let albumCell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.cellIdentifier, for: indexPath) as! AlbumCell
        
        albumCell.backgroundColor = .clear
        albumCell.selectionStyle = .none
        
        var coverAsset: PHAsset?
        let aUserCreatedAlbum = allAlbums[indexPath.item]
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        let fetchedAssets = PHAsset.fetchAssets(in: aUserCreatedAlbum, options: fetchOptions)
        coverAsset = fetchedAssets.firstObject
        guard let asset = coverAsset else { return albumCell }
        
        let coverImage = getAssetThumbnail(asset: asset, size: PHImageManagerMaximumSize)
        albumCell.bindData(albumTitle: aUserCreatedAlbum.localizedTitle ?? "", albumCoverImage: coverImage)
    
        return albumCell
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAlbums.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleDidSelect(album: allAlbums[indexPath.row])
    }
    
}

extension PhotoPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  dataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.cellIdentifier, for: indexPath) as! CameraCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.cellIdentifier, for: indexPath) as! PhotoCell
            let imageInfo = dataSource[indexPath.item - 1]
            let phAsset = imageInfo.phAsset
            let imageSize = cell.bounds.size
            let photo = getAssetThumbnail(asset: phAsset, size: imageSize)
            
            cell.prepare(info: .init(phAsset: phAsset, image: photo, selectedOrder: imageInfo.selectedOrder))
            
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let interval = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return interval
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 14
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var updateIdx = [indexPath]
        
        if indexPath.item == 0 {
            // CameraCell 선택 시 로직
            showCameraView()
        } else {
            // PhotoCell 선택 시 로직
            let info = dataSource[indexPath.item - 1]
            if case .selected = info.selectedOrder {
                dataSource[indexPath.item - 1] = .init(phAsset: info.phAsset, image: info.image, selectedOrder: .none)
                selectedIndexArray.removeAll { $0 == indexPath.item }
                selectedPhotos.removeAll { $0.phAsset == info.phAsset }
                
                selectedPhotos
                    .enumerated()
                    .forEach { index, info in
                        selectedPhotos[index].selectedOrder = .selected(index + 1)
                    }
                
                selectedIndexArray
                    .forEach { idx in
                        let preInfo = dataSource[idx - 1]
                        if let currentInfo = selectedPhotos.first(where: { $0.phAsset == preInfo.phAsset }) {
                            dataSource[idx - 1] = .init(phAsset: preInfo.phAsset, image: preInfo.image, selectedOrder: currentInfo.selectedOrder)
                        }
                        updateIdx.append(IndexPath(row: idx, section: 0))
                    }
                
            } else {
                let newInfo = PhotoCellInfo(phAsset: info.phAsset, image: info.image, selectedOrder: .selected(selectedIndexArray.count + 1))
                dataSource[indexPath.item - 1] = newInfo
                selectedPhotos.append(newInfo)
                selectedIndexArray.append(indexPath.item)
            }
            
            update(indexPaths: updateIdx)
        }
        
        func update(indexPaths: [IndexPath]) {
            self.compeleteButton.numberLabel.text = "\(selectedPhotos.count)"
            collectionView.performBatchUpdates {
                collectionView.reloadItems(at: indexPaths)
            }
        }
    }
    
}


extension PhotoPickerViewController {
    
    // MARK: - Layout Setup
    func setup() {
        setNavigationBar()
        setupToolbar()
        setLayout()
        setGestureRecognizer()
    }
    
    func setNavigationBar() {
        navigationTitleButton.backgroundColor = .white
        compeleteButton.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationItem.titleView = navigationTitleButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: compeleteButton)
    }
    
    private func setupToolbar() {
        let editButton = UIBarButtonItem(customView: editButton)
        self.bottomToolbar.setItems([editButton], animated: false)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomToolbar.setItems([editButton, flexibleSpace], animated: false)
    }
    
    // MARK: - Layout Setup
    private func setLayout() {
        setBottomToolBar()
        setBottomToolBarSubviews()
        setlimitView()
        setCollectionview()
        setTableView()
    }
    
    func setCollectionview() {
        self.view.addSubviews(collectionView)
        if limitView.isHidden == false {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: limitView.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor)
            ])
        }
    }
    
    func setlimitView() {
        self.view.addSubviews(limitView)
        NSLayoutConstraint.activate([
            limitView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            limitView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            limitView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            limitView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setTableView() {
        self.view.addSubviews(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    
    func setBottomToolBar() {
        self.view.addSubviews(bottomToolbar)
        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalToConstant: 100),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            bottomToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setBottomToolBarSubviews() {
        self.limitView.backgroundColor = .placeholderText
        self.limitView.addSubviews(limitTextLabel, goToSetting)
        NSLayoutConstraint.activate([
            limitTextLabel.leadingAnchor.constraint(equalTo: limitView.leadingAnchor, constant: 10),
            limitTextLabel.trailingAnchor.constraint(equalTo: limitView.trailingAnchor, constant: 10),
            limitTextLabel.topAnchor.constraint(equalTo: limitView.topAnchor, constant: 13),
            goToSetting.topAnchor.constraint(equalTo: limitTextLabel.bottomAnchor, constant: 3),
            goToSetting.leadingAnchor.constraint(equalTo: limitView.leadingAnchor, constant: 10),
            goToSetting.trailingAnchor.constraint(equalTo: limitView.trailingAnchor, constant: 10)
        ])
    }
    
    private func setGestureRecognizer() {
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTableView))
        let completeTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        let editTapGesture = UITapGestureRecognizer(target: self, action: #selector(pushThirdViewController))
        let openSettingGesture = UITapGestureRecognizer(target: self, action: #selector(authSettingOpen))
        self.dismissButton.addGestureRecognizer(dismissTapGesture)
        self.navigationTitleButton.addGestureRecognizer(titleTapGesture)
        self.compeleteButton.addGestureRecognizer(completeTapGesture)
        self.editButton.addGestureRecognizer(editTapGesture)
        self.goToSetting.addGestureRecognizer(openSettingGesture)
    }
    
}

extension PhotoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showCameraView() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        delegate?.didFinishTakingPhoto([image])
        self.dismiss(animated: true, completion: nil)
    }
}


extension PhotoPickerViewController {
    // MARK: - Actions
    @objc func toggleTableView() {
        // 테이블 뷰 보이기/숨기기
        UIView.animate(withDuration: 0.5, animations: {
            self.handleAnimateArrow(toIdentity: false)
            self.tableView.isHidden = !self.tableView.isHidden
        })
    }
    
    @objc func editButtonTapped() {
        
    }
    
    @objc func authSettingOpen() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    @objc func pushThirdViewController() {
        let selectedPhotos = self.selectedPhotos
        let editVC = EditViewController(selectedPhotos: selectedPhotos)
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc func dismissModal() {
        let selectedPhotos = self.selectedPhotos.compactMap { $0.image }
        delegate?.didFinishSelectingPhotos(selectedPhotos)
        self.dismiss(animated: true, completion: nil)
    }
    
}

