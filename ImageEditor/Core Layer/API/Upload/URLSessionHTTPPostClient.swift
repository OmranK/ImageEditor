//
//  URLSessionHTTPPostClient.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

public final class URLSessionHTTPPostClient: HTTPPostClient {
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public init() {}
    
    public func post(jpegImageData data: Data, to url: URL, fromURL original: URL, completion: @escaping (HTTPPostClient.Result) -> Void) {
        let request = MultipartFormDataRequest(url: url)
        request.addTextField(named: "appid", value: "com.o-khoja.App")
        request.addTextField(named: "original", value: original.absoluteString)
        request.addDataField(named: "file", data: data, mimeType: "img/jpeg")
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }).resume()
    }
}
