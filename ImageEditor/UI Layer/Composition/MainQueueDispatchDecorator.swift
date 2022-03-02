//
//  MainQueueDispatchDecorator.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation
import CoreLayer
import PresentationLayer

// Decorator for wrapping task completions to run on the main thread.
 
final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        Thread.isMainThread ? completion() : DispatchQueue.main.async { completion() }
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: ImageLoader where T == ImageLoader {
    func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FilterSupplier where T == FilterSupplier {
    func applyFilter(_ number: Int, to imageData: Data, completion: @escaping (FilterSupplier.Result) -> Void) {
        decoratee.applyFilter(number, to: imageData) { [weak self] result in
            self?.dispatch { completion(result)}
        }
    }
    
    func sampleAllFilters(on imageData: Data, completion: @escaping (FilterSupplier.SampleResult) -> Void) {
        decoratee.sampleAllFilters(on: imageData) { [weak self] result in
            self?.dispatch { completion(result)}
        }
    }
}

extension MainQueueDispatchDecorator: ImageEnhancer where T == ImageEnhancer {
    func setForEnhancement(_ imageData: Data, completion: @escaping (ImageEnhancer.SetResult) -> Void) {
        decoratee.setForEnhancement(imageData) { [weak self] result in
            self?.dispatch { completion(result)}
        }
    }
    
    func adjustImageProperty(_ number: Int, to newValue: Float, completion: @escaping (ImageEnhancer.Result) -> Void) {
        decoratee.adjustImageProperty(number,to: newValue) { [weak self] result in
            self?.dispatch { completion(result)}
        }
    }
    
}

extension MainQueueDispatchDecorator: ImageUploader where T == ImageUploader {
    func uploadImageData(_ data: Data, to url: URL, fromOriginalURL origin: URL, completion: @escaping (ImageUploader.Result) -> Void) {
        decoratee.uploadImageData(data, to: url, fromOriginalURL: origin) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}


extension MainQueueDispatchDecorator: EndpointLoader where T == EndpointLoader {
    func load(completion: @escaping (EndpointLoader.Result) -> Void) {
        decoratee.load() { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
