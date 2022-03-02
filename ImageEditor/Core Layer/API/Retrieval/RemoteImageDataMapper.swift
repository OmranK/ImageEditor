//
//  FeedItemsMapper.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

internal final class RemoteImageDataMapper {
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageData] {
        guard response.statusCode == OK_200, let feed = try? JSONDecoder().decode([RemoteImageData].self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return feed
    }
}
