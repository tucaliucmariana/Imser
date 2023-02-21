//
//  ServiceProtocol.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 02.02.2023.
//

import Foundation
import Alamofire
import Combine
import UIKit

protocol ServiceProtocol {
    func fetchImage(with text: String) -> AnyPublisher<DataResponse<ImageDTO, NetworkError>, Never>
    func fetchImage(with image: Data) -> AnyPublisher<DataResponse<ImageDTO, NetworkError>, Never>
    func downloadImage(url: String) async throws -> UIImage
}

class Service {
    static let shared: ServiceProtocol = Service()
    private init() { }
}

extension Data {
    var bytes: [UInt8] {
        var byteArray = [UInt8](repeating: 0, count: self.count)
        self.copyBytes(to: &byteArray, count: self.count)
        return byteArray
    }
}

extension Service: ServiceProtocol {
    func fetchImage(with text: String) -> AnyPublisher<DataResponse<ImageDTO, NetworkError>, Never> {
        let url = URL(string: "https://api.openai.com/v1/images/generations")!

        let headers: HTTPHeaders = [
            "Authorization": "Bearer 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",
            "Content-Type": "application/json"
        ]

        var parameters: Parameters = [
            "n": 5,
            "size": "512x512"
        ]
        parameters["prompt"] = text

        return AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .publishDecodable(type: ImageDTO.self)
            .map { response in
                response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0)}
                    return NetworkError(initialError: error, backendError: backendError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchImage(with image: Data) -> AnyPublisher<DataResponse<ImageDTO, NetworkError>, Never> {
        let url = URL(string: "https://api.openai.com/v1/images/variations")!

        let headers: HTTPHeaders = [
            "Authorization": "Bearer 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",
            "Content-Type": "multipart/form-data"
        ]

        let imagePNG = UIImage(data: image)?.pngData()
        var parameters: Parameters = [
            "image": imagePNG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)),
            "n": 5,
            "size": "512x512"
        ]

        return AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .publishDecodable(type: ImageDTO.self)
            .map { response in
                response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0)}
                    return NetworkError(initialError: error, backendError: backendError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func downloadImage(url: String) async throws -> UIImage {
        let response = await AF.download(url).serializingData().response
        switch response.result {
        case .success(let data):
            if let image = UIImage(data: data) {
                return image
            } else {
                throw AFError.responseValidationFailed(reason: .dataFileNil)
            }
        case .failure(let error):
            throw error
        }
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
