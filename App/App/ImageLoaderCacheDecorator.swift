//
//  FeedLoaderCacheDecorator.swift
//  App
//
//  Created by Omran Khoja on 3/1/22.
//

import Foundation
import CoreLayer

public final class ImageLoaderCacheDecorator: ImageLoader {
    private let decoratee: ImageLoader
    private let cache: ImageCache
    
    public init(decoratee: ImageLoader, cache: ImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        }
    }
}
