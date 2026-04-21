//
//  ShortsViewModel.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import Combine
import Foundation
import SwiftUI

final class ShortsViewModel: ObservableObject {
    @Published var title: String = "Home"
    @Published var urls = MockVideoUrls.all
    
    func getNextVideos() {
        urls.append(contentsOf: MockVideoUrls.all)
    }
}

struct MockVideoUrls {
    static var all: [String] {
        [
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
            "https://www.w3schools.com/html/mov_bbb.mp4",
        ]
    }
}
