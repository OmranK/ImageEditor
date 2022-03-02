//
//  RemoteEndpointLoader.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/28/22.
//

import Foundation

public final class RemoteEndpointLoader: EndpointLoader {
    private let url: URL
    private let client: HTTPGetClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = EndpointLoader.Result
    
    public init(url: URL, client: HTTPGetClient) {
        self.url = url
        self.client = client
    }
    
    private var OK_200: Int { return 200 }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                guard response.statusCode == self?.OK_200, let endpoint = try? JSONDecoder().decode(ImageUploadEndpoint.self, from: data) else { return completion(.failure(Error.invalidData)) }
                completion(.success(endpoint))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
