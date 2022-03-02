//
//  FeedViewAdapter.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import UIKit
import CoreLayer
import PresentationLayer

final class FeedViewAdapter: FeedView {
    typealias Routing = ((Data, URL) -> Void)
    
    private weak var feedController: FeedViewController?
    private let imageLoader: ImageLoader
    private let routing: (Data, URL) -> Void
    
    init(feedController: FeedViewController, imageLoader: ImageLoader, routing: @escaping Routing){
        self.feedController = feedController
        self.imageLoader = imageLoader
        self.routing = routing
    }
    
    func display(_ viewModel: FeedViewVM) {
        feedController?.viewModel = viewModel.feed.map { model in
            let adapter = ImageLoadingPresentationAdapter<WeakRefVirtualProxy<FeedCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedCellController(delegate: adapter, routing: routing)
            adapter.presenter = ImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        }
    }
}
