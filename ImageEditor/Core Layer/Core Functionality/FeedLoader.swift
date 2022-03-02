//
//  FeedLoader.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[ImageData], Error>
    func load(completion: @escaping (Result) -> Void)
}
