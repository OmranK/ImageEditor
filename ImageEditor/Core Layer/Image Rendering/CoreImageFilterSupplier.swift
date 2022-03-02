//
//  CoreImageFilterSupplier.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/25/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins

public final class CoreImageFilterSupplier: FilterSupplier {
    
    private enum Error: Swift.Error {
        case invalidImageData
        case ciFilterApplicationError
        case ciDataTransformationError
        case samplingError
    }
    
    private let context: CIContext
    private let imageProcessingQueue = DispatchQueue.global(qos: .userInitiated)
    
    public init(context: CIContext) {
        self.context = context
    }
    
    public func applyFilter(_ number: Int, to imageData: Data, completion: @escaping (FilterSupplier.Result) -> Void) {
        guard let image = convertToCIImage(imageData, completion: completion) else { return }
        applyFilter(number, to: image) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func applyFilter(_ number: Int, to image: CIImage, completion: @escaping (FilterSupplier.Result) -> Void) {
        switch number {
        case 0:
            apply(chromeEffect(to: image), completion: completion)
        case 1:
            apply(fadeEffect(to: image), completion: completion)
        case 2:
            apply(instantEffect(to: image), completion: completion)
        case 3:
            apply(noirEffect(to: image), completion: completion)
        case 4:
            apply(processEffect(to: image), completion: completion)
        case 5:
            apply(tonalEffect(to: image), completion: completion)
        case 6:
            apply(transferEffect(to: image), completion: completion)
        default:
            apply(sepiaFilter(to: image), completion: completion)
        }
    }
    
    private func apply(_ filter: CIFilter, completion: @escaping (FilterSupplier.Result) -> Void) {
        guard let filteredImage = renderFiltered(using: filter, completion: completion) else { return }
        imageProcessingQueue.async {
            self.convertToData(filteredImage, completion: completion)
        }
    }
    
    public func sampleAllFilters(on imageData: Data, completion: @escaping (FilterSupplier.SampleResult) -> Void) {
        guard let image = CIImage(data: imageData)  else { return completion(.failure(Error.invalidImageData)) }

        var samples = [CIImage]()
        for i in (0..<8) {
            samples.append(sampleFilter(number: i, on: image) { result in
                switch result {
                case .success: break
                case let .failure(error):
                    completion(.failure(error))
                }
            })
        }
        
        imageProcessingQueue.async {
            self.convertToData(samples) { result in
                switch result {
                case let .success(data):
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    private func sampleFilter(number: Int, on image: CIImage, completion: @escaping (FilterSupplier.Result) -> Void) -> CIImage {
        switch number {
        case 0:
            return sample(chromeEffect(to: image), completion: completion)
        case 1:
            return sample(fadeEffect(to: image), completion: completion)
        case 2:
            return sample(instantEffect(to: image), completion: completion)
        case 3:
            return sample(noirEffect(to: image), completion: completion)
        case 4:
            return sample(processEffect(to: image), completion: completion)
        case 5:
            return sample(tonalEffect(to: image), completion: completion)
        case 6:
            return sample(transferEffect(to: image), completion: completion)
        default:
            return sample(sepiaFilter(to: image), completion: completion)
        }
    }
    
    private func sample(_ filter: CIFilter, completion: @escaping (FilterSupplier.Result) -> Void) -> CIImage {
        guard let filteredImage = renderFiltered(using: filter, completion: completion) else { fatalError("Failed to render filtered image during \(filter) sampling") }
        return filteredImage
    }
}

// MARK: - Filters
extension CoreImageFilterSupplier {
    private func chromeEffect(to image: CIImage) -> CIFilter {
        return apply(CIFilter.photoEffectChrome(), to: image)
    }
    
    private func fadeEffect(to image: CIImage) -> CIFilter {
        return apply(CIFilter.photoEffectFade(), to: image)
    }
    
    private func instantEffect(to image: CIImage) -> CIFilter {
        return apply(CIFilter.photoEffectInstant(), to: image)
    }
    
    private func noirEffect(to image: CIImage) -> CIFilter {
        return apply(CIFilter.photoEffectNoir(), to: image)
    }
    
    private func processEffect(to image: CIImage) -> CIFilter {
        return apply(CIFilter.photoEffectProcess(), to: image)
    }
    
    private func tonalEffect(to image: CIImage) -> CIFilter {
        return apply(CIFilter.photoEffectTonal(), to: image)
    }
    
    private func transferEffect(to image: CIImage) -> CIFilter {
        return apply(CIFilter.photoEffectTransfer(), to: image)
    }
    
    private func sepiaFilter(to image: CIImage) -> CIFilter{
        let filter = CIFilter.sepiaTone()
        filter.intensity = 1.0
        return apply(filter, to: image)
    }
}

// MARK: - Helpers

extension CoreImageFilterSupplier {
    
    private func apply(_ filter: CIFilter, to image: CIImage) -> CIFilter {
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter
    }
    
    private func convertToCIImage(_ data: Data, completion: (FilterSupplier.Result) -> Void) -> CIImage? {
        if let ciImage = CIImage(data: data) {
            return ciImage
        } else {
            completion(.failure(Error.invalidImageData))
            return nil
        }
    }
    
    private func renderFiltered(using filter: CIFilter, completion: (FilterSupplier.Result) -> Void) -> CIImage? {
        if let filteredImage = filter.outputImage {
            return filteredImage
        } else {
            completion(.failure(Error.ciFilterApplicationError))
            return nil
        }
    }
    
    private func convertToData(_ ciImage: CIImage, completion: (FilterSupplier.Result) -> Void) {
        if let filteredImageData = convertToJPEGData(ciImage) {
            return completion(.success(filteredImageData))
        } else {
            return completion(.failure(Error.ciDataTransformationError))
        }
    }
    
    private func convertToData(_ ciImages: [CIImage], completion: (FilterSupplier.SampleResult) -> Void) {
        var samplesData = [Data]()
        for image in ciImages {
            if let filteredImageData = convertToJPEGData(image) {
                samplesData.append(filteredImageData)
            } else {
                return completion(.failure(Error.ciDataTransformationError))
            }
        }
        completion(.success(samplesData))
    }
    
    private func convertToJPEGData(_ ciImage: CIImage) -> Data? {
        return context.jpegRepresentation(
            of: ciImage,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
            options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : 1.0])
    }
}
        
