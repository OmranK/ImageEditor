//
//  LocalImageLoader.swift
//  UILayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation

public final class LocalImageLoader {
    private let store: ImageStore
    
    public init(store: ImageStore) {
        self.store = store
    }
}

extension LocalImageLoader: ImageCache {
    public typealias SaveResult = Result<Void, Error>

    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            
            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalImageLoader: ImageLoader {
    public typealias LoadResult = ImageLoader.Result

    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    private final class LoadImageDataTask: ImageLoaderTask {
        private var completion: ((ImageLoader.Result) -> Void)?
        
        init(_ completion: @escaping (ImageLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ImageLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> ImageLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                })
        }
        return task
    }
}
