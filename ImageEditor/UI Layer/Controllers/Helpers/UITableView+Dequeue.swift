//
//  UITableView+Dequeue.swift
//  FeediOS
//
//  Created by Omran Khoja on 2/22/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}

