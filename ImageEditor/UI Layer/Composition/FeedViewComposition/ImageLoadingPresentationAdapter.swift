//
//  ImageLoadingPresentationAdapter.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import CoreLayer
import PresentationLayer

final class ImageLoadingPresentationAdapter<View: ImageView, Image>: FeedCellControllerDelegate where View.Image == Image {
    private let model: ImageData
    private let imageLoader: ImageLoader
    private var task: ImageLoaderTask?
    
    var presenter: ImagePresenter<View, Image>?
    
    init(task: ImageLoaderTask? = nil, model: ImageData, imageLoader: ImageLoader) {
        self.task = task
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestLoadImage() {
        presenter?.didStartLoadingImageData(for: model)
        task = imageLoader.loadImageData(from: model.url) { [weak self, model] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case .failure:
                self?.presenter?.didFinishLoadingImageDataWithError(for: model)
            }
        }
    }
    
    func didCancelLoadImage() {
        task?.cancel()
        task = nil
    }
}
