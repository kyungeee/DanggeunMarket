//
//  AlbumInfo.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/26.
//

import Photos
import UIKit

struct AlbumInfo: Identifiable {
  let id: String?
  let name: String
  let count: Int
  let album: PHFetchResult<PHAsset>
}

