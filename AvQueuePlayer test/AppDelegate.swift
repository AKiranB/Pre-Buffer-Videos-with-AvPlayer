//
//  AppDelegate.swift
//  AvPlayertest
//
//  Created by Kiran Boyle on 30.10.25.
//

import AVFoundation
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .green
        w.rootViewController = PlayerViewController()
        w.makeKeyAndVisible()
        window = w
        return true
    }
}


final class GhostPlayer {
    private let queuePlayer = AVQueuePlayer()
    private var preheatedItems: [URL:AVPlayerItem] = [:]
    private var observers:[NSKeyValueObservation] = []
    
    func preheat (urls:[URL]){
        queuePlayer.removeAllItems()
        observers.removeAll()
        
        for (index, url) in urls.enumerated() {
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            preheatedItems[url] = item
            
            if(queuePlayer.canInsert(item, after: nil)){
                queuePlayer.insert(item, after:nil)
            }
            
            observers.append(item.observe(\.isPlaybackLikelyToKeepUp) { item, _ in
                print("item \(String(describing: index)) is likelyToKeepUp = \(item.isPlaybackLikelyToKeepUp)")
                print(item.loadedTimeRanges)
            })
            
            observers.append(item.observe(\.isPlaybackBufferEmpty) { item, _ in
                print("playbackBufferIsEmpty for item \(String(describing:index)) is \(item.isPlaybackBufferEmpty)")
                print(item.loadedTimeRanges)
            })
            
            observers.append(item.observe(\.isPlaybackBufferFull) { item, _ in
                print("playbackBufferIsFull for item \(String(describing:index)) is \(item.isPlaybackBufferFull)")
                print(item.loadedTimeRanges)
            })
        }
    }
    
    func getItem(for url: URL) -> AVPlayerItem? {
        guard let item = preheatedItems[url] else { return nil }
        queuePlayer.pause()
        if queuePlayer.currentItem === item {
            queuePlayer.replaceCurrentItem(with: nil)
        } else {
            queuePlayer.remove(item)
        }
        preheatedItems.removeValue(forKey: url)
        
        return item
    }
}



final class VideoPlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private let player = AVPlayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        player.automaticallyWaitsToMinimizeStalling = true
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    // This throws here because the QueuePlayer still owns, or holds a reference to the item, even though
    // I've tried everything to stop it from doing so. I suspected it was a race conditon,
    // but even deferring this to the next tick doesn't fix it.
    func set(item: AVPlayerItem) { player.replaceCurrentItem(with: item) }
    func play() { player.play() }
    func pause() { player.pause() }
}


final class PlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

final class PlayerViewController: UIViewController {
    
    let videoPlayerView = VideoPlayerView()
    let ghostPlayer = GhostPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(videoPlayerView)
        let urlStrings = [
           "https://cdn.flowkey.com/courseSlidesV3/dX4cvXcMWR2K9Spqi/en/2021-11-01_19-57-06/050101_Einleitung_dX4cvXcMWR2K9Spqi-en.m3u8",
          "https://cdn.flowkey.com/courseSlidesV3/XuYYngHXfgKsW8YzD/en/2021-11-01_19-57-06/050102_Groove_Patterns_XuYYngHXfgKsW8YzD-en.m3u8",
           "https://cdn.flowkey.com/courseSlidesV3/hbngf2zQ97ecnBP5v/en/2021-11-01_19-57-06/050103_Die_Synkope_hbngf2zQ97ecnBP5v-en.m3u8",
           "https://cdn.flowkey.com/courseSlidesV3/gRaBFLCEssszW9TPq/en/2021-11-01_19-57-06/050104_Einleitung_Quintbaesse_gRaBFLCEssszW9TPq-en.m3u8"
        ]
        
        let urls = urlStrings.compactMap {URL(string: $0.trimmingCharacters(in: .whitespaces))}
        ghostPlayer.preheat(urls: urls)
        if let itemToPlay = ghostPlayer.getItem(for: urls[0]) {
            videoPlayerView.set(item: itemToPlay)
        } else {
            print("No preheated item found")
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPlayerView.frame = view.bounds
    }
}
