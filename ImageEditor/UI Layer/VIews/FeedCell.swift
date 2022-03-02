//
//  FeedCellView.swift
//  PresentationLayer
//
//  Created by Omran Khoja on 2/26/22.
//

import UIKit

final public class FeedCell: UITableViewCell {
    
    @IBOutlet private(set) public var createdDateLabel: UILabel!
    @IBOutlet private(set) public var updatedDateLabel: UILabel!
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var retryButton: UIButton!
    @IBOutlet private(set) public var imageButton: UIButton!
    
    var onRetry: (() -> Void)?
    var transition: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
    
    @IBAction func imageSelected(_ sender: UIButton) {
        transition?()
    }
}
