//
//  ImageViewModel.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/25.
//

import UIKit
import Photos
import PhotosUI

class ImageViewModel {
    
    // TODO: - 다중선택 이미지 프로퍼티 추가
    // FIXME: - refectoring
    
    //MARK: - Properties
    fileprivate var allPhotosInCurrentAlbum = PHFetchResult<PHAsset>()
    
    fileprivate var smartAlbums = [PHAssetCollection]()
    
    fileprivate var userCreatedAlbums = PHFetchResult<PHAssetCollection>()
    
    fileprivate let listOfsmartAlbumSubtypesToBeFetched: [PHAssetCollectionSubtype] = [.smartAlbumUserLibrary, .smartAlbumFavorites, .smartAlbumVideos, .smartAlbumScreenshots]
    
    
}
