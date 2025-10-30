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
        print("BOOT OK")
        return true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(videoPlayerView)
        let url = URL(string:"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
        
        let item = AVPlayerItem(url: url)
        videoPlayerView.set(item: item)
        videoPlayerView.play()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPlayerView.frame = view.bounds
    }
}
