# 🥕 당근마켓 iOS 인턴 과제 전형 - 포토피커 만들기 
## 과제 내용
- 화면1: 첫 화면
- 화면2: 사진 목록 화면
- 화면3: 사진 편집 화면 

<br>

## 💻 개발

```sh
- 언어: UIKit 
```

## ⚙️ 개발 환경

```sh
- iOS 14.0 이상
- iPhone 14 Pro에서 최적화됨
- 가로모드 미지원
```

## 🤝 컨벤션
<details>
<summary>커밋 type</summary>

```
- [Feat] 새로운 기능 추가
- [Chore] 코드 수정, 내부 파일 수정, 주석
- [Add] Feat 이외의 부수적인 코드 추가, 파일추가, 라이브러리 추가, 에셋 추가
- [Style] UI 작업 → 컴포넌트 추가, xib 작업
- [Fix] 버그 해결
- [Del] 파일 삭제
- [Move] 파일 이름 / 위치 변경
- [Refactor] 코드 리팩토링
```
</details>

<details>
<summary>전체 폴더링 구조</summary>

```
📦 DanggeunMarket
|
+ 🗂 App                     // AppDelegate, SceneDelegate
|
+ 🗂 Resources
|         
+------🗂 Assets             // Image, Color Asset
|
+------🗂 Extensions          // Extension 모음
│         
+ 🗂 Sources
|
+------🗂 Models             // PhotoCellInfo 
|
+------🗂 Service            // Service
|       |
|       +------🗂 AuthService      // 앨범, 카메라 권한 처리 
|
+------🗂 ViewControllers              // VC 모음
|       |
|       +------🗂 ViewController      
|       │         
|       +------🗂 PhotoPickerViewController
|       |
|       +------🗂 EditViewController
|
+------🗂 View               // Custom View 모음
|
+------🗂 Cells              // Cell 모음 
|
+------🗂 ViewModels         // ViewModel 모음 
```
</details>
<br>

## 👩🏻‍💻 고려한 점
### 1. PhotoKit framework 를 사용하여 포토피커 구현 

```swift
- PHFetchResult: fetch method에서 반환된 asset또는 collection의 정렬된 list
- PHAssetCollection: Moment, 사용자 제작 앨범 또는 스마트 앨범과 같은 Photos asset그룹 
- PHAsset:  PHAsset 하나의 이미지, 비디오, 또는 라이브사진 
```
```swift
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

        // 최근 항목 로드 
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchOptions.sortDescriptors = [sortDescriptor]
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        fetchResult.enumerateObjects { (asset, _, _) in
            let image = self.getAssetThumbnail(asset: asset, size: PHImageManagerMaximumSize)
            let photoInfo = PhotoCellInfo(phAsset: asset, image: image, selectedOrder: .none)
            
            self.dataSource.append(photoInfo)
        }
```

```swift
        // 선택한 앨범 사진 asset 가져오기 
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        let fetchedAssets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        fetchResult = fetchedAssets
```
```swift
       // asset 데이터로 부터 이미지 가져오기
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        var thumbnail: UIImage?
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) {(imageReturned, info) in
            guard let thumbnailUnwrapped = imageReturned else {return}
            thumbnail = thumbnailUnwrapped
        }
```

### 2. 포토피커 다중 이미지 선택 처리 
- 다른 앨범을 선택해서 이미지를 선택해도 photoCell 의 숫자(몇번째 선택된 이미지인지)가 그대로 유지
- 선택한 이미지 취소할때 photoCell 의 숫자 처리 ex) 1 -> 2 -> 3 선택 후 2 취소하면 1 -> 2 
```swift
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
```


### 3. 접근 권한 
- 앨범의 접근 권한을 권한 미요청, 권한 없음, 권한 있음, 제한된 권한 으로 나눠 처리했습니다. 
- 앨범 권한 미요청일 경우 PHPhotoLibrary.requestAuthorization 를 통해 alert를 띄워 처리했습니다.
- 앨범 접근 권한이 없을 경우 권한이 없다는 alert 를 띄워 처리했습니다. 
- 제한된 권한일 경우 포토피커뷰에서 접근 권한 수정 안내 뷰를 추가하여 구현했습니다.
```Swift
 func photoAuth() -> Bool {
        // 포토 라이브러리 접근 권한
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        var isAuth = false
        
        switch authorizationStatus {
        case .authorized: return true // 사용자가 앱에 사진 라이브러리에 대한 액세스 권한을 명시 적으로 부여
        case .limited: return true
        case .denied: break // 사용자가 사진 라이브러리에 대한 앱 액세스를 명시적으로 거부
        case .notDetermined: // 사진 라이브러리 액세스에는 명시적인 사용자 권한이 필요하지만 사용자가 아직 이러한 권한을 부여하거나 거부하지 않음
            PHPhotoLibrary.requestAuthorization { (state) in
                if state == .authorized {
                    isAuth = true
                }
            }
            return isAuth
        case .restricted: break // 앱이 사진 라이브러리에 액세스 할 수있는 권한이 없으며 사용자는 이러한 권한을 부여 할 수 없음
        default: break
        }
        
        return false;
    }
```
