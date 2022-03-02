//
//  BundleFeedLoader.swift
//  App
//
//  Created by Omran Khoja on 2/28/22.
//

import Foundation

public final class BundledFeedLoader: FeedLoader {
    
    public init() {}
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(.success(bundledImageData()))
    }
    
    private func bundledImageData() -> [ImageData] {
        return [
            createDummyImageData(forResourceNamed: "spider"),
            createDummyImageData(forResourceNamed: "bobcat"),
            createDummyImageData(forResourceNamed: "snake"),
            createDummyImageData(forResourceNamed: "tiger"),
            createDummyImageData(forResourceNamed: "polarbear"),
            createDummyImageData(forResourceNamed: "eagle"),
        ]
    }
    
    private func createDummyImageData(forResourceNamed name: String) -> ImageData {
        let path = Bundle.main.path(forResource: name, ofType: "jpeg")
        let imageURL = URL(fileURLWithPath: path!)
        return  ImageData(url: imageURL, created: Date(), updated: Date())
    }

}
