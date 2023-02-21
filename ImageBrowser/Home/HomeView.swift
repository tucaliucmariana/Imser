//
//  HomeView.swift
//  ImageBrowser
//
//  Created by Mariana TUCALIUC on 09.02.2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                searchByTextCardView

                searchByPhotoCardView

                Spacer()
            }
            .padding()
            .navigationTitle("Image Browser")
        }
    }

    var searchByTextCardView: some View {
        NavigationLink(destination: SearchByTextView()) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.gray)
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 20)
                Text("Download image by text search")
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .cornerRadius(16)
        }
    }

    var searchByPhotoCardView: some View {
        NavigationLink(destination: SearchByImageView()) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.gray)
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 20)
                Text("Download image by image search")
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .cornerRadius(16)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
