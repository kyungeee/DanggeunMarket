//
//  Ex+UIVIew.swift
//  DanggeunMarket
//
//  Created by 박희경 on 2024/01/24.
//

import Photos
import UIKit


extension UIView {
    
    /// Flip view 180, true to rotate 180, false to return to identity
    func handleRotate180(rotate: Bool, withDuration: CGFloat = 0.5) {
        UIView.animate(withDuration: withDuration) { () -> Void in
            self.transform = rotate == true ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
        }
        
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
    
}
