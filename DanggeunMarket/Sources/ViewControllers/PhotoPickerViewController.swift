//
//  PhotoPickerViewController.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import UIKit
import Photos
import PhotosUI

final class PhotoPickerViewController: UIViewController {
    
    // Properties
    var fetchResult: PHFetchResult<PHAsset>!
    var albums: [PHAssetCollection] = []
    var selectedAlbum: PHAssetCollection?
    var photos: PHFetchResult<PHAsset>!
    
    
    
    //MARK: - Properties
    
    fileprivate var allPhotosInCurrentAlbum = PHFetchResult<PHAsset>()
    
    fileprivate var smartAlbums = [PHAssetCollection]()
    
    fileprivate var userCreatedAlbums = PHFetchResult<PHAssetCollection>()
    
    fileprivate var allAlbums = [PHAssetCollection]()
    
    fileprivate let listOfsmartAlbumSubtypesToBeFetched: [PHAssetCollectionSubtype] = [.smartAlbumUserLibrary, .smartAlbumFavorites, .smartAlbumScreenshots]
    
    
    // MARK: - UI Components
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CameraCell.self, forCellWithReuseIdentifier: CameraCell.cellIdentifier)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.cellIdentifier)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.view.backgroundColor = .blue
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.backgroundColor = .yellow
        
        // 사진 라이브러리 권한 요청 및 데이터 로딩
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.loadPhotosFromLibrary()
//                self.loadAlbums()
            } else {
                // 권한 거부 처리
            }
        }
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
        
        print(allAlbums)
        
        DispatchQueue.main.async {
            //            self.mediaPickerView.bindDataFromPhotosLibrary(fetchedAssets: self.allPhotosInCurrentAlbum, albumTitle: "Recents")
            self.tableView.reloadData()
        }

        
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        DispatchQueue.main.async {
            //            self.mediaPickerView.bindDataFromPhotosLibrary(fetchedAssets: self.allPhotosInCurrentAlbum, albumTitle: "Recents")
            self.collectionView.reloadData()
        }
    }
    
    // MARK: 선택한 앨범 사진 asset 가져오기
    func handleDidSelect(album: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        let fetchedAssets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        fetchResult = fetchedAssets
        
        self.bindDataFromPhotosLibrary(fetchedAssets: self.allPhotosInCurrentAlbum, albumTitle: album.localizedTitle ?? "")
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
        
        // cell data binding
        var coverAsset: PHAsset?
        let aUserCreatedAlbum = allAlbums[indexPath.item]
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        let fetchedAssets = PHAsset.fetchAssets(in: aUserCreatedAlbum, options: fetchOptions)
        coverAsset = fetchedAssets.firstObject
        guard let asset = coverAsset else { return albumCell }
        
        let coverImage = getAssetThumbnail(asset: asset, size: albumCell.bounds.size)
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
//        dismiss(animated: true)
    }
    
}

extension PhotoPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.cellIdentifier, for: indexPath) as! CameraCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellIdentifier, for: indexPath) as! ImageCell
            let asset = fetchResult.object(at: indexPath.item)
            
            // PHCachingImageManager를 사용하여 섬네일 이미지 로드
            PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil) { image, _ in
                cell.imageView.image = image
            }
            
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
        let width = collectionView.frame.width / 3 - 15
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func handleCameraCellSelection() {
        
        // 카메라 접근 허용
        // 접근 o -> 카메라뷰로 넘어가게
        // 접근 x -> 알랏 보여주고 설정페이지
        print("Special cell at index 0 selected!")
    }
    
    func handleImageCellSelection(at indexPath: IndexPath) {
        
        // ImageCell isSelected 처리
        print("Regular cell at index \(indexPath.item) selected!")
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
        navigationTitleButton.backgroundColor = .yellow
        compeleteButton.backgroundColor = .white
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
        view.addSubviews(collectionView, tableView, bottomToolbar)
        
        // ToolBar Constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            editButton.widthAnchor.constraint(equalToConstant: 100),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            bottomToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setGestureRecognizer() {
        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTableView))
        let completeTapGesture = UITapGestureRecognizer()
        self.navigationTitleButton.addGestureRecognizer(titleTapGesture)
        self.compeleteButton.addGestureRecognizer(completeTapGesture)
    }
    
}

extension PhotoPickerViewController {
    // MARK: - Actions
    
    @objc func toggleTableView() {
        // 테이블 뷰 보이기/숨기기
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.isHidden = !self.tableView.isHidden
        })
        
    }
    
    @objc func editButtonTapped() {
        print("편집 버튼이 눌렸습니다.")
    }
    
    
}

