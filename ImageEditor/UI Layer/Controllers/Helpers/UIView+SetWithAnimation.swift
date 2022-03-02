//
//  UIView+SetWithAnimation.swift
//  FeediOS
//
//  Created by Omran Khoja on 2/22/22.
//

import UIKit

extension UIView {
    func setImageWithAnimation(_ newImage: UIImage?) {
        guard newImage != nil else { return }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
