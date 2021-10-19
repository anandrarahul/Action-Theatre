//
//  VideoDetailsViewController.swift
//  Action Theatre
//
//  Created by Rahul Anand on 08/10/21.
//

import UIKit
import AVFoundation

class VideoDetailsViewControllerDataSource {
    var videoDetail: VideoDetails
    let recommendedVideos: [VideoDetails]
    
    init(videoDetails: VideoDetails, recommended: [VideoDetails]) {
        self.videoDetail = videoDetails
        self.recommendedVideos = recommended
    }
}

class VideoDetailsViewController: UIViewController {

    @IBOutlet weak private var videoView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var relatedTableView: UITableView!
    @IBOutlet weak private var playPauseButton: UIButton!
    @IBOutlet weak private var currentTime: UILabel!
    @IBOutlet weak private var endTime: UILabel!
    @IBOutlet weak private var seekVedioTime: UISlider!
    @IBOutlet weak private var backwardButton: UIButton!
    @IBOutlet weak private var forwardButton: UIButton!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var isVideoPlaying: Bool = false
    
    var dataSource: VideoDetailsViewControllerDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateVideoPlayer()
        self.updateView()
        self.navigationItem.title = self.dataSource.videoDetail.title
        self.relatedTableView.dataSource = self
        self.relatedTableView.delegate = self
        self.relatedTableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(gesture:)))
        self.videoView.addGestureRecognizer(tapGesture)
        self.videoView.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        self.playerLayer.frame = self.videoView.bounds
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        _ = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            guard let strongSelf = self else { return }
            guard let currentItem = strongSelf.player.currentItem else { return }
            strongSelf.seekVedioTime.minimumValue = 0
            strongSelf.seekVedioTime.maximumValue = Float(currentItem.duration.seconds) > 0 ? Float(currentItem.duration.seconds) : 0
            strongSelf.seekVedioTime.value = Float(currentItem.currentTime().seconds)
            strongSelf.currentTime.text = strongSelf.getTimeString(from: currentItem.currentTime())
        })
    }
    
    private func updateVideoPlayer() {
        self.player = AVPlayer(url: URL(string: self.dataSource.videoDetail.url!)!)
        self.player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        self.addTimeObserver()
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = .resize
        self.videoView.layer.addSublayer(playerLayer)
        self.showControls()
    }
    
    private func updateView() {
        if let imageUrl = self.dataSource.videoDetail.thumb {
            self.setImageFromUrl(imageURL: imageUrl)
        }
        if let videoTitle = self.dataSource.videoDetail.title {
            self.titleLabel.text = videoTitle
        }
        if let videoDesc = self.dataSource.videoDetail.description {
            self.descriptionLabel.text = videoDesc
        }
    }
    
    private func setImageFromUrl(imageURL: String) {
        URLSession.shared.dataTask(with: NSURL(string: imageURL)! as URL) { data, response, error in
            DispatchQueue.main.async {
                if let _ = error {
                    self.videoView.image = UIImage(named: "noImage")
                } else {
                    if let data = data {
                        self.videoView?.image = UIImage(data: data)
                    }
                }
            }
        }.resume()
    }
    private func hideControls() {
        self.playPauseButton.isHidden = true
        self.backwardButton.isHidden = true
        self.forwardButton.isHidden = true
    }
    
    private func showControls() {
        self.playPauseButton.isHidden = false
        self.backwardButton.isHidden = false
        self.forwardButton.isHidden = false
    }
    
    @objc private func imageViewTapped(gesture: UIGestureRecognizer) {
        self.showControls()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.hideControls()
        }
    }
    
    @IBAction private func backButtonPressed(_ sender: UIButton) {
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 10.0
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player.seek(to: time)
    }
    
    @IBAction private func playPauseButtonPressed(_ sender: UIButton) {
        if self.isVideoPlaying {
            self.player.pause()
            sender.setImage(UIImage(named: "play"), for: .normal)
        } else {
            self.player.play()
            sender.setImage(UIImage(named: "pause"), for: .normal)
        }
        self.isVideoPlaying = !self.isVideoPlaying
        self.showControls()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.hideControls()
        }
    }
    
    @IBAction private func forwardButtonClicked(_ sender: UIButton) {
        
        guard let duration = player.currentItem?.duration else {
            print("Invalid Duration")
            return
        }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10.0
        if newTime < (CMTimeGetSeconds(duration)) {
            let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    
    @IBAction private func timeSliderValueChanged(_ sender: UISlider) {
        self.player.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = self.player.currentItem?.duration.seconds, duration > 0.0 {
            self.endTime.text = getTimeString(from: player.currentItem!.duration)
        }
    }
    
    private func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return "\(hours):\(minutes):\(seconds)"
        } else {
            return "\(minutes):\(seconds)"
        }
    }
    
}

extension VideoDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource.recommendedVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.relatedTableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
        cell.updateCell(self.dataSource.recommendedVideos[indexPath.row].thumb, self.dataSource.recommendedVideos[indexPath.row].title, self.dataSource.recommendedVideos[indexPath.row].description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dataSource.videoDetail = self.dataSource.recommendedVideos[indexPath.row]
        self.player.pause()
        self.isVideoPlaying = false
        self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        self.navigationItem.title = self.dataSource.videoDetail.title
        self.updateView()
        self.updateVideoPlayer()
        
    }
}
