//
//  RemoteImageLoader.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public final class RemoteImageLoader: ImageLoader {
     private let client: HTTPGetClient

     public init(client: HTTPGetClient) {
         self.client = client
     }

     public enum Error: Swift.Error {
         case connectivity
         case invalidData
     }

     private final class HTTPClientTaskWrapper: ImageLoaderTask {
         private var completion: ((ImageLoader.Result) -> Void)?

         var wrapped: HTTPGetClientTask?

         init(_ completion: @escaping (ImageLoader.Result) -> Void) {
             self.completion = completion
         }

         func complete(with result: ImageLoader.Result) {
             completion?(result)
         }

         func cancel() {
             preventFurtherCompletions()
             wrapped?.cancel()
         }

         private func preventFurtherCompletions() {
             completion = nil
         }
     }

     public func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
         let task = HTTPClientTaskWrapper(completion)
         task.wrapped = client.get(from: url) { [weak self] result in
             guard self != nil else { return }

             switch result {
             case let .success((data, response)):
                 if response.statusCode == 200, !data.isEmpty {
                     task.complete(with: .success(data))
                 } else {
                     task.complete(with: .failure(Error.invalidData))
                 }
             case .failure:
                 task.complete(with: .failure(Error.connectivity))
             }
         }
         return task
     }
 }
