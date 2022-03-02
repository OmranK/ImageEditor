//
//  UIRefreshControl+Helpers.swift
//  FeediOS
//
//  Created by Omran Khoja on 2/23/22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
    
}

