//
//  NetworkError.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 02.02.2023.
//

import Foundation
import Alamofire

struct NetworkError: Error {
    let initialError: AFError
    let backendError: BackendError?
}

struct BackendError: Codable, Error {
    var status: String
    var message: String
}
