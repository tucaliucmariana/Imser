//
//  ImageSearchViewModel.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 02.02.2023.
//

import UIKit
import Combine
import Alamofire

class ImageSearchViewModel: ObservableObject {
    @Published var imageModels =  [ImageModel]()
    @Published var imagesLoadingError = ""
    @Published var showImageRetrievalFailedAlert = false
    @Published var isLoading = false
    @Published var uiImageDictionary: [String: UIImage] = [:]

    private var cancellableSet: Set<AnyCancellable> = []
    var dataManager: ServiceProtocol

    init(dataManager: ServiceProtocol = Service.shared) {
        self.dataManager = dataManager
    }

    func getImages(with text: String) {
        isLoading = true
        dataManager.fetchImage(with: text)
            .sink { (dataResponse) in
                self.isLoading = false
                if dataResponse.error != nil {
                    self.createAlert(with: dataResponse.error!)
                } else {
                    guard let value = dataResponse.value else {
                        return
                    }
                    self.imageModels = value.data
                }
            }.store(in: &cancellableSet)
    }

    func createAlert(with error: NetworkError ) {
        imagesLoadingError = error.backendError == nil ?
            error.initialError.localizedDescription :
            error.backendError!.message

        self.showImageRetrievalFailedAlert = true
    }

    func downloadImages() async throws {
        try await withThrowingTaskGroup(of: (String, UIImage).self, body: { group in
            for image in imageModels {
                group.addTask {
                    return (image.url, try await self.dataManager.downloadImage(url: image.url))
                }

                for try await (url, image) in group {
                    await MainActor.run {
                        uiImageDictionary[url] = image
                    }
                }
            }
        })
    }
}
