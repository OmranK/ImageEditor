//
//  MultipartFormDataRequest.swift
//  ImageEditor
//
//  Created by Omran Khoja on 2/24/22.
//

import Foundation

struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r"
        fieldString += "Content-Transfer-Encoding: 8bit\r"
        fieldString += "\(value)\r"
        print(fieldString)
        return fieldString
    }

    func addDataField(named name: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }

    private func dataFormField(named name: String, data: Data, mimeType: String) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r")
        fieldData.append("Content-Type: \(mimeType)\r")
        fieldData.append("\r")
        fieldData.append(data)
        return fieldData as Data
    }
    
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        httpBody.append("--\(boundary)--")
        request.httpBody = httpBody as Data
        return request
    }
}

extension NSMutableData {
  func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

extension URLSession {
    func dataTask(with request: MultipartFormDataRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}
