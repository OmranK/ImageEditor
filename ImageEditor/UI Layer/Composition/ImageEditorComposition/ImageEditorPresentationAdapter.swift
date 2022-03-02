//
//  ImageEditorPresentationAdapter.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation
import CoreLayer
import PresentationLayer

final class ImageEditorPresentationAdapter: ImageEditorViewControllerDelegate {
    
    private let imageUploader: ImageUploader
    private let endpointLoader: EndpointLoader
    private let filterSupplier: FilterSupplier
    private let imageEnhancer: ImageEnhancer
    
    var presenter: ImageEditorPresenter?
    
    init(imageUploader: ImageUploader, filterSupplier: FilterSupplier, imageEnhancer: ImageEnhancer, endpointLoader: EndpointLoader) {
        self.filterSupplier = filterSupplier
        self.imageEnhancer = imageEnhancer
        self.imageUploader = imageUploader
        self.endpointLoader = endpointLoader

    }
    
    func didRequestFilterButtons(from imageData: Data) {
        filterSupplier.sampleAllFilters(on: imageData) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didReceiveButtonImages(data: data)
            case let .failure(error):
                fatalError("\(error)")
            }
        }
    }
    
    func didRequestFilter(_ number: Int, on imageData: Data) {
        filterSupplier.applyFilter(number, to: imageData, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didReceiveFilteredImage(data: data)
            case let .failure(error):
                fatalError("\(error)")
            }
        })
    }
    
    
    func didSetForAdjustment(_ imageData: Data) {
        imageEnhancer.setForEnhancement(imageData) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                fatalError("\(error)")
            }
        }
    }
    
    func didAdjustImageSetting(_ number: Int, to newValue: Float) {
        imageEnhancer.adjustImageProperty(number, to: newValue) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didReceiveEnhancedImaged(data: data)
            case let .failure(error):
                fatalError("\(error)")
            }
        }
    }
    
    
    func didRequestSave(_ imageData: Data, fromOriginalURL origin: URL) {
        endpointLoader.load {  [weak self] result in
            switch result {
            case let .success(endpoint):
                self?.imageUploader.uploadImageData(imageData, to: endpoint.url, fromOriginalURL: origin) { [weak self] result in
                    switch result {
                    case .success:
                        self?.presenter?.didCompleteSaveRequest(result: .success(()))
                    case let .failure(error):
                        self?.presenter?.didCompleteSaveRequest(result: .failure(error))
                    }}
            case let .failure(error):
                self?.presenter?.didCompleteSaveRequest(result: .failure(error))
            }
            
        }
        
    }
}
