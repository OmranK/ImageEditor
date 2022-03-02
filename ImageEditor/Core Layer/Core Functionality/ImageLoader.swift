//
//  ImageLoader.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public protocol ImageLoaderTask {
    func cancel()
}

public protocol ImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageLoaderTask
}

