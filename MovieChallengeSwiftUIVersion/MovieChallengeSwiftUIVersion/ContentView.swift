//
//  ContentView.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 11/12/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MovieViewModel()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView(content: {
            VStack {
                if viewModel.isSearching {
                    ProgressView()
                } else {
                    List(viewModel.result) { movie in
                        MovieRow(movie: movie)
                    }.overlay {

                    }
                }

            }
        }).navigationTitle("Search").toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { dismiss() }) {
                    Text("Done")
                }
            }
        }).searchable(text: $viewModel.searchTerm)
    }
}

struct BookSearchTaskCancellationView_Previews: PreviewProvider {
  static var previews: some View {
      ContentView(viewModel: MovieViewModel())
  }
}


