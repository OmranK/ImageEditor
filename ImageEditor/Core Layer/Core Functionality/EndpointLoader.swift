//
//  EndpointLoader.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/28/22.
//

import Foundation

public protocol EndpointLoader {
    typealias Result = Swift.Result<ImageUploadEndpoint, Error>
    func load(completion: @escaping (Result) -> Void)
}
