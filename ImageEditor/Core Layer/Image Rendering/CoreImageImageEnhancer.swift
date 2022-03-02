//
//  CoreImageImageEnhancer.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/25/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins

public final class CoreImageImageEnhancer: ImageEnhancer {
    
    private enum Error: Swift.Error {
        case invalidImageData
        case imageDataNotSet
        case ciFilterApplicationError
        case ciDataTransformationError
    }
    
    private let context: CIContext
    private var currentImage: CIImage?
    private let imageProcessingQueue = DispatchQueue.global(qos: .userInitiated)
    
    public init(context: CIContext) {
        self.context = context
    }
    
    public func setForEnhancement(_ imageData: Data, completion: @escaping (ImageEnhancer.SetResult) -> Void) {
         guard let image = convertToCIImage(imageData, completion: completion) else { return }
         currentImage = image
    }
    
    public func adjustImageProperty(_ number: Int, to newValue: Float, completion: @escaping (ImageEnhancer.Result) -> Void) {
        guard let image = currentImage else {
            completion(.failure(Error.imageDataNotSet))
            return
        }
        switch number {
        case 1:
            adjust(brightness(on: image, to: newValue), completion: completion)
        case 2:
            adjust(hue(on: image, to: newValue), completion: completion)
        case 3:
            adjust(contrast(on: image, to: newValue), completion: completion)
        case 4:
            adjust(saturation(on: image, to: newValue), completion: completion)
        case 5:
            adjust(exposure(on: image, to: newValue), completion: completion)
        default:
            adjust(vibrance(on: image, to: newValue), completion: completion)
        }
    }
    
    private func adjust(_ filter: CIFilter, completion: @escaping (ImageEnhancer.Result) -> Void) {
        guard let filteredImage = renderFiltered(using: filter, completion: completion) else { return }
        imageProcessingQueue.async {
            self.convertToData(filteredImage, completion: completion)
        }
    }
}

// MARK: - Filters
extension CoreImageImageEnhancer {
    private func brightness(on image: CIImage, to newValue: Float) -> CIFilter {
        let filter = CIFilter.colorControls()
        let minLimit: Float = -0.2
        let maxLimit: Float = 0.2
        let newBrightnessValue = map(input: newValue, outputStart: minLimit, outputEnd: maxLimit)
        filter.brightness = newBrightnessValue
        return apply(filter, to: image)
    }
    
    private func saturation(on image: CIImage, to newValue: Float) -> CIFilter {
        let filter = CIFilter.colorControls()
        let minLimit: Float = -10.0
        let maxLimit: Float = 10.0
        let newSaturationValue = map(input: newValue, outputStart: minLimit, outputEnd: maxLimit)
        filter.saturation = newSaturationValue
        return apply(filter, to: image)
    }
    
    private func contrast(on image: CIImage, to newValue: Float) -> CIFilter {
        let filter = CIFilter.colorControls()
        let minLimit: Float = 0.75
        let maxLimit: Float = 2.0
        let newContrastValue = map(input: newValue, outputStart: minLimit, outputEnd: maxLimit)
        filter.contrast = newContrastValue
        return apply(filter, to: image)
    }
    
    private func hue(on image: CIImage, to newValue: Float) -> CIFilter {
        let filter = CIFilter.hueAdjust()
        let minLimit: Float = -2.0
        let maxLimit: Float = 2.0
        let newContrastValue = map(input: newValue, outputStart: minLimit, outputEnd: maxLimit)
        filter.angle = newContrastValue
        return apply(filter, to: image)
    }
    
    private func exposure(on image: CIImage, to newValue: Float) -> CIFilter {
        let filter = CIFilter.exposureAdjust()
        let minLimit: Float = -1.0
        let maxLimit: Float = 1.0
        let newEVValue = map(input: newValue, outputStart: minLimit, outputEnd: maxLimit)
        filter.ev = newEVValue
        return apply(filter, to: image)
    }
    
    private func vibrance(on image: CIImage, to newValue: Float) -> CIFilter {
        let filter = CIFilter.vibrance()
        let minLimit: Float = -18.0
        let maxLimit: Float = 20.0
        let newEVValue = map(input: newValue, outputStart: minLimit, outputEnd: maxLimit)
        filter.amount = newEVValue
        return apply(filter, to: image)
    }
}



// MARK: - Helpers

extension CoreImageImageEnhancer {
    
    private func map(input: Float, outputStart: Float, outputEnd: Float) -> Float {
        let inputStart: Float = -100
        let inputEnd: Float = 100
        let slope: Float = (outputEnd - outputStart) / (inputEnd - inputStart)
        let output = outputStart + slope * (input - inputStart)
        return output
    }
    
    
    private func apply(_ filter: CIFilter, to image: CIImage) -> CIFilter {
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter
    }
    
    private func convertToCIImage(_ data: Data, completion: (ImageEnhancer.SetResult) -> Void) -> CIImage? {
        if let ciImage = CIImage(data: data) {
            return ciImage
        } else {
            completion(.failure(Error.invalidImageData))
            return nil
        }
    }
    
    private func renderFiltered(using filter: CIFilter, completion: (ImageEnhancer.Result) -> Void) -> CIImage? {
        if let filteredImage = filter.outputImage {
            return filteredImage
        } else {
            completion(.failure(Error.ciFilterApplicationError))
            return nil
        }
    }
    
    private func convertToData(_ ciImage: CIImage, completion: (ImageEnhancer.Result) -> Void) {
        if let filteredImageData = convertToJPEGData(ciImage) {
            return completion(.success(filteredImageData))
        } else {
            return completion(.failure(Error.ciDataTransformationError))
        }
    }
    
    private func convertToJPEGData(_ ciImage: CIImage) -> Data? {
        return context.jpegRepresentation(
            of: ciImage,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
            options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : 1.0])
    }
}
