//
//  SearchByImage.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 09.02.2023.
//

import SwiftUI
import PhotosUI

struct SearchByImageView: View {
    @StateObject var viewModel = SearchByImageViewModel()

    @State var selectedImage: PhotosPickerItem?
    @State var selectedImageData: Data?

    @State private var searchText = ""
    @State private var isSharePresented = false
    @State private var showImageSavedAlert = false
    @State private var selectedImageUrl = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Import similar image from your gallery")

            if viewModel.isLoading {
                loadingView
            } else {
                photoPicker
                imageList
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $viewModel.showImageRetrievalFailedAlert) {
            Alert(title: Text(viewModel.imagesLoadingError), dismissButton: .cancel())
        }
        .alert(isPresented: $showImageSavedAlert) {
            Alert(title: Text("Image saved successfully"), dismissButton: .default(Text("OK")))
        }
        .alert("Do you want to download this image?", isPresented: $isSharePresented) {
            Button("Yes") {
                saveImage()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: selectedImage) { newValue in
            // Retrive selected asset in the form of Data
//            let _ = newValue?.loadTransferable(type: Data.self, completionHandler: { result in
//                switch result {
//                case .success(let data):
//                    viewModel.selectedImageData = data
//                case .failure(let error):
//                    print(error)
//                }
//            })

            Task {
                viewModel.selectedImageData = try? await newValue?.loadTransferable(type: Data.self)
            }
        }
        .onReceive(viewModel.$selectedImageData) { newValue in
            guard let data = newValue else {
                return
            }
            viewModel.getImages(with: data)
        }
    }

    private var importImageView: some View {
        Image(systemName: "plus")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color.gray)
            .frame(width: 50, height: 50)
            .padding(50)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var photoPicker: some View {
        PhotosPicker(
            selection: $selectedImage,
            matching: .images,
            photoLibrary: .shared()) {
                importImageView
            }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @ViewBuilder
    private var imageList: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.imageModels, id: \.url) { imageModel in
                    AsyncImage(url: URL(string: imageModel.url)) { phase in
                        switch phase {
                        case .success(let image):
                            ZStack {
                                image
                                    .resizable()
                                    .scaledToFit()
                                getDownloadButtonView(url: imageModel.url)
                            }
                        case .failure:
                            Image(systemName:"photo.fill")
                        default:
                            ProgressView()
                        }
                    }
                }
            }
        }
    }

    // MARK: - private methods
    private func getDownloadButtonView(url: String) -> some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    selectedImageUrl = url
                    isSharePresented = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.white)
                        .frame(width: 25, height: 25)
                        .padding([.top, .leading, .trailing], 5)
                        .padding(.bottom, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            Spacer()
        }
        .padding([.top, .trailing], 5)
    }

    private func saveImage() {
        guard let uiImage = viewModel.uiImageDictionary[selectedImageUrl] else { return }

        let imageSaver = ImageSaver()

        imageSaver.successHandler = {
            showImageSavedAlert = true
        }

        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }

        imageSaver.writeToPhotoAlbum(image: uiImage)
    }
}

struct SearchByImage_Previews: PreviewProvider {
    static var previews: some View {
        SearchByImageView()
    }
}
