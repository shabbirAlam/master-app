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
    
    @State private var playerLooper: AVPlayerLooper?
    @State private var queuePlayer: AVQueuePlayer?
    
    var body: some View {
        VideoPlayer(player: queuePlayer)
            .onAppear {
                setupPlayer()
                queuePlayer?.play()
            }
            .onDisappear {
                queuePlayer?.pause()
            }
    }
    
    private func setupPlayer() {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        queuePlayer = player
    }
}
