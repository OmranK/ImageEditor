//
//  ImageEditorPresenter.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation

public protocol ImageEditorButtonsView {
    func display(_ viewModel: ImageEditorButtonsViewVM)
}

public protocol ImageEditorCanvasView {
    func display(_ viewModel: ImageEditorCanvasViewVM)
    func displayAdjustment(_ viewModel: ImageEditorCanvasViewVM)
}

public protocol ImageSaveProgressView {
    func displayResult(_ viewModel: ImageSaveProgressViewVM)
}

public final class ImageEditorPresenter {
    private let imageEditorButtonsView: ImageEditorButtonsView
    private let imageEditorCanvasView: ImageEditorCanvasView
    private let imageSaveProgressView: ImageSaveProgressView
    
    public init(imageEditorButtonsView: ImageEditorButtonsView, imageEditorCanvasView: ImageEditorCanvasView, imageSaveProgressView: ImageSaveProgressView) {
        self.imageEditorButtonsView = imageEditorButtonsView
        self.imageEditorCanvasView = imageEditorCanvasView
        self.imageSaveProgressView = imageSaveProgressView
    }
    
    public func didReceiveButtonImages(data: [Data]) {
        DispatchQueue.main.async {
            self.imageEditorButtonsView.display(ImageEditorButtonsViewVM(buttonImagesData: data))
        }
    }
    
    public func didReceiveFilteredImage(data: Data) {
        imageEditorCanvasView.display(ImageEditorCanvasViewVM(filteredImageData: data))
    }
    
    public func didReceiveEnhancedImaged(data: Data) {
        imageEditorCanvasView.displayAdjustment(ImageEditorCanvasViewVM(filteredImageData: data))
    }
    
    public func didCompleteSaveRequest(result: Result<Void, Error>) {
        imageSaveProgressView.displayResult(ImageSaveProgressViewVM(result: result))
    }

}
