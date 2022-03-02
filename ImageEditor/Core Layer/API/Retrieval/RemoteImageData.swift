//
//  FeedData.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

internal struct RemoteImageData: Codable {
    internal let url: URL
    internal let created: String
    internal let updated: String
}
