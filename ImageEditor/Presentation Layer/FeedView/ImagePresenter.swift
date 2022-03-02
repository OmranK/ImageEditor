//
//  FeedImagePresenter.swift
//  PresentationLayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation
import CoreLayer

public protocol ImageView {
    associatedtype Image
    func display(_ model: ImageViewVM<Image>)
}

public final class ImagePresenter<View: ImageView, Image> where View.Image == Image {
    
    public typealias ImageTransformation = (Data) -> Image?
    
    private let imageTransformer: ImageTransformation
    private let view: View
    
    public init(view: View, imageTransformer: @escaping ImageTransformation) {
        self.imageTransformer = imageTransformer
        self.view = view
    }
    
    public func didStartLoadingImageData(for model: ImageData){
        view.display(ImageViewVM(url: model.url, dateCreated: format(toString: model.created), dateUpdated: format(toString: model.updated), image: nil, imageData: nil, isLoading: true, shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: ImageData) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageDataWithError(for: model)
        }
        view.display(ImageViewVM(url: model.url, dateCreated: format(toString: model.created), dateUpdated: format(toString: model.updated), image: image, imageData: data, isLoading: false, shouldRetry: false))
    }
    
    public func didFinishLoadingImageDataWithError(for model: ImageData) {
        view.display(ImageViewVM(url: model.url, dateCreated: format(toString: model.created), dateUpdated: format(toString: model.updated), image: nil, imageData: nil, isLoading: false, shouldRetry: true))
    }
    
    
    private func format(toString date: Date) -> String  {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a"
        return dateFormatter.string(from: date)
    }
}
