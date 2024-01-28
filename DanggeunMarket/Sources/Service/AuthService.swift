//
//  AuthService.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/28.
//

import UIKit
import Photos

protocol AuthServiceInterface {
    func photoAuth() -> Bool
    func CameraAuth() -> Bool
    func isPhotoLimitAuth() -> Bool
    func AuthSettingOpen(authString: String) -> UIAlertController
    func isDetermined() -> Bool
}

class AuthService: AuthServiceInterface {
    
    func isDetermined() -> Bool {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        var isAuth = false
      
        if authorizationStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (state) in
                if state == .authorized {
                    isAuth = true
                }
            }
        }
        return isAuth
    }
    
    func photoAuth() -> Bool {
        // 포토 라이브러리 접근 권한
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        var isAuth = false
        
        switch authorizationStatus {
        case .authorized: return true // 사용자가 앱에 사진 라이브러리에 대한 액세스 권한을 명시 적으로 부여
        case .limited: return true
        case .denied: break // 사용자가 사진 라이브러리에 대한 앱 액세스를 명시 적으로 거부했습니다.
        case .notDetermined: // 사진 라이브러리 액세스에는 명시적인 사용자 권한이 필요하지만 사용자가 아직 이러한 권한을 부여하거나 거부하지 않았습니다
            PHPhotoLibrary.requestAuthorization { (state) in
                if state == .authorized {
                    isAuth = true
                }
            }
            return isAuth
        case .restricted: break // 앱이 사진 라이브러리에 액세스 할 수있는 권한이 없으며 사용자는 이러한 권한을 부여 할 수 없습니다.
        default: break
        }
        
        return false;
    }
    
    func CameraAuth() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == AVAuthorizationStatus.authorized
    }

    
    func isPhotoLimitAuth() -> Bool {
        let requiredAccessLevel: PHAccessLevel = .readWrite
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: requiredAccessLevel)
        var isLimit = false

        if authorizationStatus == .limited {
            isLimit = true
        }
        
        return isLimit
    }
    
    func AuthSettingOpen(authString: String) -> UIAlertController {
        let appName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "App"
        let message = "\(appName)이(가) \(authString) 접근 허용되어 있지 않습니다. 설정 화면으로 가시겠습니까?"
        let alert = UIAlertController(title: "설정", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .default) { action in
            print("\(action.title ?? "") 클릭")
        }
        
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        return alert
    }
    
    
}
