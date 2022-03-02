//
//  ImageUploader.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public final class RemoteImageUploader: ImageUploader {
    
    private let client: HTTPPostClient
    
    public init(client: HTTPPostClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case failedPOST
    }
    
    public typealias Result =  (ImageUploader.Result) -> Void
    
    public func uploadImageData(_ data: Data,  to url: URL, fromOriginalURL origin: URL, completion: @escaping Result) {
        client.post(jpegImageData: data, to: url, fromURL: origin) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((_, response)):
                if response.statusCode == 201 {
                    completion(.success(()))
                } else {
                    completion(.failure(Error.failedPOST))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
