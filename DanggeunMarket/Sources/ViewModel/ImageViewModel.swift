//
//  ImageViewModel.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/25.
//

import UIKit
import Photos
import PhotosUI

class PhotoPickerViewModel {
    
    // Properties
    private var albums: [PHAssetCollection] = []
    private var photos: [PhotoCellInfo] = []
    private var selectedPhotos: [PhotoCellInfo] = []
    
    func fetchAlbums() {
        
    }
    
    func fetchPhotos(from album: PHAssetCollection) {
        
    }

    
    var numberOfPhotos: Int {
        return photos.count
    }

    func photoInfo(at index: Int) -> PhotoCellInfo {
        return photos[index]
    }

    
}
