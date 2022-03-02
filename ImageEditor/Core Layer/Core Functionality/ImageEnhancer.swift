//
//  ImageEnhancer.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/25/22.
//

import Foundation

public protocol ImageEnhancer {
    typealias Result = Swift.Result<Data, Error>
    typealias SetResult = Swift.Result<Void, Error>
    func setForEnhancement(_ imageData: Data, completion: @escaping (SetResult) -> Void)
    func adjustImageProperty(_ number: Int, to newValue: Float, completion: @escaping (Result) -> Void)
}
