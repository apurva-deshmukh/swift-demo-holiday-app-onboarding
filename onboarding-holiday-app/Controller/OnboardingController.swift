//
//  ViewController.swift
//  onboarding-holiday-app
//
//  Created by Apurva Deshmukh on 7/31/20.
//  Copyright © 2020 Apurva Deshmukh. All rights reserved.
//

import UIKit
import AVFoundation
import Combine

class OnboardingController: UIViewController {

    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var darkView: UIView!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private let notificationCenter = NotificationCenter.default
    private var appEventSubscribers = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        observeAppEvents()
        setupPlayerIfNeeded()
        restartVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        removeAppEventSubscriber()
        removePlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupViews() {
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height / 2
        getStartedButton.layer.masksToBounds = true
        darkView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
    }
    
    private func buildPlayer() -> AVPlayer? {
        guard let filepath = Bundle.main.path(forResource: "bg_video", ofType: "mp4") else { return nil }
        let url = URL(fileURLWithPath: filepath)
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.isMuted = true
        return player
    }
    
    private func buildPlayerLayer() -> AVPlayerLayer? {
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    private func playVideo() {
        player?.play()
    }
    
    private func restartVideo() {
        player?.seek(to: .zero)
        playVideo()
    }
    
    private func pauseVideo() {
        player?.pause()
    }
    
    private func setupPlayerIfNeeded() {
        player = buildPlayer()
        playerLayer = buildPlayerLayer()
        
        if let layer = self.playerLayer, view.layer.sublayers?.contains(layer) == false  {
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    
    private func removePlayer() {
        pauseVideo()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    private func observeAppEvents() {
        notificationCenter.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { [weak self] _ in
            self?.restartVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self] _ in
            self?.pauseVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
            self?.playVideo()
        }.store(in: &appEventSubscribers)
    }
    
    private func removeAppEventSubscriber() {
        appEventSubscribers.forEach { (subscriber) in
            subscriber.cancel()
        }
    }
}

