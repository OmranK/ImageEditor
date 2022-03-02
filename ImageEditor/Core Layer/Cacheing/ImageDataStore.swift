//
//  FeedImageDataStore.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation

public protocol ImageStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}
