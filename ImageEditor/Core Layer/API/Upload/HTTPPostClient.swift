//
//  HTTPPostClient.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public protocol HTTPPostClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func post(jpegImageData: Data, to url: URL, fromURL: URL, completion:  @escaping (Result) -> Void )
}
