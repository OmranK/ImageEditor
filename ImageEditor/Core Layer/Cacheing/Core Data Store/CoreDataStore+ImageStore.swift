//
//  CoreDataStore+ImageLoader.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation

extension CoreDataStore: ImageStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (ImageStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedImageData.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (ImageStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedImageData.first(with: url, in: context)?.data
            })
        }
    }
    
}
