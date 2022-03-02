//
//  NavigationController.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import UIKit
import CoreLayer
import PresentationLayer

extension FeedUIComposer {
    
    public static func imageEditorControllerComposedWith(imageUploader: ImageUploader, endpointLoader: EndpointLoader, filterSupplier: FilterSupplier, imageEnhancer: ImageEnhancer, for imageData: Data, at url: URL) -> ImageEditorViewController {
        let imageEditorPresentationAdapter = ImageEditorPresentationAdapter(
            imageUploader: MainQueueDispatchDecorator(imageUploader),
            filterSupplier: MainQueueDispatchDecorator(filterSupplier),
            imageEnhancer: MainQueueDispatchDecorator(imageEnhancer),
            endpointLoader: MainQueueDispatchDecorator(endpointLoader))
        
        let imageEditorController = ImageEditorViewController.makeWith(delegate: imageEditorPresentationAdapter, for: imageData, at: url)
        
        let presenter = ImageEditorPresenter(
            imageEditorButtonsView: WeakRefVirtualProxy(imageEditorController),
            imageEditorCanvasView: WeakRefVirtualProxy(imageEditorController),
            imageSaveProgressView:  WeakRefVirtualProxy(imageEditorController))
        imageEditorPresentationAdapter.presenter = presenter
        return imageEditorController
    }
}

private extension ImageEditorViewController {
    static func makeWith(delegate: ImageEditorViewControllerDelegate, for imageData: Data, at url: URL) -> ImageEditorViewController {
        let bundle = Bundle(for: ImageEditorViewController.self)
        let storyboard = UIStoryboard(name: "ImageEditor", bundle: bundle)
        let editorController = storyboard.instantiateInitialViewController() as! ImageEditorViewController
        editorController.delegate = delegate
        editorController.imageData = imageData
        editorController.url = url
        return editorController
    }
}





//final class ImageEditorViewAdapter: ImageEditorButtonsView {
//
//    private weak var imageEditorController: ImageEditorViewController?
//
//    init(imageEditorController: ImageEditorViewController) {
//        self.imageEditorController = imageEditorController
//    }
//
//    func display(_ viewModel: ImageEditorButtonsViewVM) {
//        imageEditorController?.buttonImages = viewModel.buttonImagesData.map { imageData in
//            if let image = UIImage(data: imageData) {
//                return image
//            }
//        }
//    }
//}
