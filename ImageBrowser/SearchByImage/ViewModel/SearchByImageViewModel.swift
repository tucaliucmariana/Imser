//
//  ImageSearchViewModel.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 02.02.2023.
//

import UIKit
import Combine
import Alamofire

class SearchByImageViewModel: ObservableObject {
    @Published var imageModels =  [ImageModel]()
    @Published var imagesLoadingError = ""
    @Published var showImageRetrievalFailedAlert = false
    @Published var isLoading = false
    @Published var selectedImageData: Data?
    @Published var uiImageDictionary: [String: UIImage] = [:]

    private var cancellableSet: Set<AnyCancellable> = []
    var dataManager: ServiceProtocol

    init(dataManager: ServiceProtocol = Service.shared) {
        self.dataManager = dataManager
    }

    func getImages(with imageData: Data) {
        isLoading = true
        dataManager.fetchImage(with: imageData)
            .sink { (dataResponse) in
                self.isLoading = false
                if dataResponse.error != nil {
                    self.createAlert(with: dataResponse.error!)
                    print(dataResponse.error!)
                } else {
                    guard let value = dataResponse.value else {
                        return
                    }
                    self.imageModels = value.data
                }
            }.store(in: &cancellableSet)
    }

    func createAlert(with error: NetworkError ) {
        imagesLoadingError = error.backendError == nil ? error.initialError.localizedDescription : error.backendError!.message
        self.showImageRetrievalFailedAlert = true
    }
}
