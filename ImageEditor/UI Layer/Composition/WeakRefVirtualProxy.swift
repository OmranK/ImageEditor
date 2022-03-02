//
//  WeakRefVirtualProxy.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import UIKit
import PresentationLayer

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewVM) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ImageView where T: ImageView, T.Image == UIImage {
    typealias Image = T.Image
    
    func display(_ model: ImageViewVM<Image>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedLoadingErrorView where T: FeedLoadingErrorView {
    func display(_ model: FeedLoadingErrorViewVM) {
        object?.display(model)
    }
}


extension WeakRefVirtualProxy: ImageEditorButtonsView where T: ImageEditorButtonsView {
    func display(_ model: ImageEditorButtonsViewVM) {
        object?.display(model)
    }
}


extension WeakRefVirtualProxy: ImageEditorCanvasView where T: ImageEditorCanvasView {
    func displayAdjustment(_ viewModel: ImageEditorCanvasViewVM) {
        object?.displayAdjustment(viewModel)
    }
    
    func display(_ model: ImageEditorCanvasViewVM) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: ImageSaveProgressView where T: ImageSaveProgressView {
    func displayResult(_ viewModel: ImageSaveProgressViewVM) {
        object?.displayResult(viewModel)
    }
}
