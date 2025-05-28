//
//  UIImageView+Animate.swift
//  EssentialFeediOS
//
//  Created by Kholmumin Tursinboev on 4/1/25.
//

import UIKit

extension UIImageView{
    
    func setImageAnimated(_ newImage: UIImage?){
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
