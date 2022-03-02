//
//  FeedCellController.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//
//

import UIKit
import PresentationLayer

protocol FeedCellControllerDelegate {
    func didRequestLoadImage()
    func didCancelLoadImage()
}

protocol FeedCellControllerSelectionDelegate {
    func didSelectCell(for data: Data)
}

final class FeedCellController: ImageView {
    typealias Routing = (Data, URL) -> Void
    typealias Image = UIImage
    private var cell: FeedCell?
    private var routing: (Data, URL) -> Void
    var imageData: Data?
    
    private let delegate: FeedCellControllerDelegate
    init(delegate: FeedCellControllerDelegate, routing: @escaping Routing) {
        self.delegate = delegate
        self.routing = routing
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestLoadImage()
        return cell!
    }
    
    func display(_ model: ImageViewVM<UIImage>) {
        cell?.createdDateLabel.text = "Date created: \(model.dateCreated)"
        cell?.updatedDateLabel.text = "Date updated: \(model.dateUpdated)"
        
        cell?.feedImageView.image = model.image
        cell?.feedImageView.setImageWithAnimation(model.image)
        
        cell?.retryButton.isHidden = !model.shouldRetry
        cell?.imageContainer.isShimmering = model.isLoading
        cell?.onRetry = delegate.didRequestLoadImage
        cell?.transition = { [weak self] in
            if let data = model.imageData {
                self?.routing(data, model.url)
            }
        }
    }

    func preLoad() {
        delegate.didRequestLoadImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelLoadImage()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}


