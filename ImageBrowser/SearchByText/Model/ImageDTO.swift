//
//  ImageModel.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 02.02.2023.
//

import Foundation

// MARK: - ImageDTO
struct ImageDTO: Decodable {
    let created: Double
    let data: [ImageModel]
}

// MARK: - Image
struct ImageModel: Decodable {
    let url: String
}
