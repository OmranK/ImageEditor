//
//  FeedLoaderCacheDecorator.swift
//  App
//
//  Created by Omran Khoja on 3/1/22.
//

import CoreLayer

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [ImageData]) {
        save(feed) { result in
            switch result {
            case .success:
                print("Sucessfully cached ")
            case .failure(let failure):
                print("Failed cache save \(failure)")
            }
        }
    }
    
}
