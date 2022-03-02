//
//  ImageUploader.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public protocol ImageUploader {
    typealias Result = Swift.Result<Void, Error>
    func uploadImageData(_: Data, to url: URL, fromOriginalURL: URL, completion: @escaping (Result) -> Void)
}
