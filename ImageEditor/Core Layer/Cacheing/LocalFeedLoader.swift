//
//  LocalFeedLoader.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [ImageData], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [ImageData], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            completion(insertionResult)
        }
    }
    
}

extension LocalFeedLoader: FeedLoader  {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { retrieveResult in
            switch retrieveResult {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == ImageData {
    func toLocal() -> [LocalImageData] {
        return map { LocalImageData(url: $0.url, created: $0.created, updated: $0.updated) }
    }
}

private extension Array where Element == LocalImageData {
    func toModels() -> [ImageData] {
        return map { ImageData(url: $0.url, created: $0.created, updated: $0.updated) }
    }
}

