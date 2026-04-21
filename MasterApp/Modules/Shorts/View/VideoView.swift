//
//  VideoView.swift
//  MasterApp
//
//  Created by Md Shabbir Alam on 21/04/26.
//

import SwiftUI
import AVKit

struct VideoView: View {
    let url: URL
    @State private var player: AVPlayer
    
    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }
    
    var body: some View {
        VideoPlayer(player: player)
//            .rotationEffect(.degrees(-90)) // 👈 undo parent rotation
            .onAppear { player.play() }
            .onDisappear { player.pause() }
    }
}
