//
//  MovieRow.swift
//  MovieChallengeSwiftUIVersion
//
//  Created by Kevin on 11/13/23.
//

import SwiftUI

struct MovieRow: View {
    var movie: SearchModel
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: movie.convertStrtoURL())
                Text(movie.Title ?? "")
                    .font(.headline)
                    .padding(.leading)
                Text("by \(movie.imdbID ?? "")")
                .font(.subheadline)
                .padding(.leading)

        }.padding()
    }
}

