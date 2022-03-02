//
//  RemoteFeedLoader.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPGetClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPGetClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try RemoteImageDataMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteImageData {
    func toModels() -> [ImageData] {
        return self.map {
            ImageData(url: $0.url, created: format(toDate: $0.created), updated: format(toDate: $0.updated))
        }
    }
    
    private func format(toDate stringDate: String) -> Date {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a"
        guard let date = dateFormatter.date(from: stringDate) else {
            fatalError("Date format received from API has changed. Update formatter to reflect the update.")
        }
        return date
    }
}
