//
//  FeedCache.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ feed: [ImageData], completion: @escaping (Result) -> Void)
}
