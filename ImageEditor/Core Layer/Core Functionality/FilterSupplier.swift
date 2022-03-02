//
//  FilterSupplier.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/25/22.
//

import Foundation

public protocol FilterSupplier {
    typealias Result = Swift.Result<Data, Error>
    typealias SamplingResult = Swift.Result<[Data], Error>
    func applyFilter(_ number: Int, to imageData: Data, completion: @escaping (Result) -> Void)
    
    typealias SampleResult = Swift.Result<[Data], Error>
    func sampleAllFilters(on imageData: Data, completion: @escaping (SampleResult) -> Void)
}

