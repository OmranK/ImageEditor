//
//  ImageViewVM.swift
//  PresentationLayer
//
//  Created by Omran Khoja on 2/26/22.
//

import Foundation

public struct ImageViewVM<Image> {
    public let url: URL
    public let dateCreated: String
    public let dateUpdated: String
    public let image: Image?
    public let imageData: Data?
    public let isLoading: Bool
    public let shouldRetry: Bool
}
