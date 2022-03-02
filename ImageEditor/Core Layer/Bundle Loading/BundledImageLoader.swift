//
//  BundledImageLoader.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/28/22.
//
//
import Foundation

public final class BundledImageLoader: ImageLoader {

    private var dummyImages = [Data]()
    
    public enum Error: Swift.Error {
        case nonBundleURL
    }
    
    private class LoadImageDataTask: ImageLoaderTask {
        private var completion: ((ImageLoader.Result) -> Void)?
        
        init(_ completion: @escaping (ImageLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ImageLoader.Result) {
            completion?(result)
        }

        func cancel() {
            completion = nil
        }
    }
    
    public init() {
        getDataForAsset(named: "spider")
        getDataForAsset(named: "bobcat")
        getDataForAsset(named: "snake")
        getDataForAsset(named: "tiger")
        getDataForAsset(named: "polarbear")
        getDataForAsset(named: "eagle")
    }
    
    private func getDataForAsset(named name: String) {
        do {
            let path = Bundle.main.path(forResource: name, ofType: "jpeg")
            let imageURL = URL(fileURLWithPath: path!)
            let data = try Data(contentsOf: imageURL)
            dummyImages.append(data)
        } catch {
            fatalError("Failed to get bundled image named: \(name)")
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        let task = LoadImageDataTask(completion)
        switch url.relativePath {
        case let str where str.contains("spider"):
            task.complete(with: .success(dummyImages[0]))
        case let str where str.contains("bobcat"):
            task.complete(with: .success(dummyImages[1]))
        case let str where str.contains("tiger"):
            task.complete(with: .success(dummyImages[2]))
        case let str where str.contains("snake"):
            task.complete(with: .success(dummyImages[3]))
        case let str where str.contains("polarbear"):
            task.complete(with: .success(dummyImages[4]))
        case let str where str.contains("eagle"):
            task.complete(with: .success(dummyImages[5]))
        default:
            task.complete(with: .failure(Error.nonBundleURL))
        }
        return task
    }
}
