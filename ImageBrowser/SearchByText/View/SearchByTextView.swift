//
//  ContentView.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 02.02.2023.
//

import SwiftUI

struct SearchByTextView: View {
    @StateObject private var viewModel = ImageSearchViewModel()

    @State private var searchText = ""
    @State private var isSharePresented = false
    @State private var showImageSavedAlert = false
    @State private var selectedImageUrl = ""

    init() {
        UITextField.appearance().clearButtonMode = .always
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                searchImageTextField
                if viewModel.isLoading {
                    loadingView
                } else {
                    imageList
                }
            }
        }
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
        .onReceive(viewModel.$imageModels) { images in
            if images.isEmpty {
                Task {
                    do {
                        try await viewModel.downloadImages()
                    } catch {
                        print("error, failed to download images as UIImage")
                    }
                }
            }
        }
        .onChange(of: searchText, perform: { text in
            if text.isEmpty {
                viewModel.imageModels.removeAll()
                viewModel.uiImageDictionary.removeAll()
            }
        })
        .padding(20)
    }

    private var searchImageTextField: some View {
        TextField("Enter image description", text: $searchText)
            .onSubmit {
                viewModel.getImages(with: searchText)
            }
            .textFieldStyle(OutlinedTextFieldStyle())
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            Text("Searching for \(searchText)")
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
        print(selectedImageUrl)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchByTextView()
    }
}

struct OutlinedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 2)
            }
    }
}
