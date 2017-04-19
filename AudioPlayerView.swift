//
//  AudioPlayerView.swift
//  ZINGMP3
//
//  Created by NhatMinh on 3/9/17.
//  Copyright © 2017 Nhật Minh. All rights reserved.
//

import UIKit
import AVFoundation
class AudioPlayerView: UIViewController {
    
    let audioPlayer = AudioPlayer.sharedInstance
    
    var checkAddObserverAudio = false
    
    @IBOutlet weak var btn_Play: UIButton!
    @IBOutlet weak var lbl_CurrentTime: UILabel!
    @IBOutlet weak var lbl_TotalTime: UILabel!
    @IBOutlet weak var sld_Duration: UISlider!
    @IBOutlet weak var sld_Volume: UISlider!
//    @IBOutlet weak var lbl_Title: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_Play.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(setupObserverAudio), name: NSNotification.Name(rawValue: "setupObserverAudio"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeInfoView()
    }
    
    func changeInfoView()
    {
//        changeInfoSong()
        addThumbImgForButton()
    }
    
//    func changeInfoSong()
//    {
//        lbl_Title.text = audioPlayer.titleSong
//    }
    
    func addThumbImgForButton()
    {
        
        if audioPlayer.playing == true
        {
            btn_Play.setBackgroundImage(UIImage(named: "pause.png"), for: .normal)
        }
        else
        {
            btn_Play.setBackgroundImage(UIImage(named: "play.png"), for: .normal)
        }
    }
    
    func setupObserverAudio()
    {
        if (audioPlayer.playing && !checkAddObserverAudio)
        {
            checkAddObserverAudio = true
            btn_Play.isEnabled = true
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.player.currentItem)
        }
        changeInfoView()
    }
    
    func playerItemDidReachEnd(notification: NSNotification)
    {
        if (audioPlayer.repeating)
        {
            audioPlayer.player.seek(to: kCMTimeZero)
            audioPlayer.player.play() 
        }
    }
    
    
    func timeUpdate()
    {
        audioPlayer.duration = Float((audioPlayer.player.currentItem?.duration.value)!)/Float((audioPlayer.player.currentItem?.duration.timescale)!)
        
        audioPlayer.currentTime = Float(audioPlayer.player.currentTime().value)/Float(audioPlayer.player.currentTime().timescale)
        
        let m = Int(floor(audioPlayer.currentTime/60))
        let s = Int(round(audioPlayer.currentTime - Float(m)*60))
        
        if (audioPlayer.duration > 0)
        {
            let mduration = Int(floor(audioPlayer.duration/60))
            let sduration = Int(round(audioPlayer.duration - Float(mduration)*60))
            self.lbl_CurrentTime.text = String(format: "%02d", m) + ":" + String(format: "%02d", s)
            self.lbl_TotalTime.text = String(format: "%02d", mduration) + ":" + String(format: "%02d", sduration)
            self.sld_Duration.value = Float(audioPlayer.currentTime/audioPlayer.duration)
            self.sld_Volume.value = audioPlayer.player.volume
        }
    }
    
    @IBAction func action_repeatSong(sender: UISwitch)
    {
        audioPlayer.action_Repeat(sender.isOn)
    }
    
    
    @IBAction func action_PlayPause(sender: AnyObject)
    {
        audioPlayer.action_PlayPause()
        addThumbImgForButton()
    }
    
    @IBAction func sld_Duration(sender: UISlider)
    {
        audioPlayer.sld_Duration(sender.value)
    }
    
    @IBAction func sld_Volume(sender: UISlider)
    {
        audioPlayer.sld_Volume(sender.value)
    }
    
    
    
    
    
    
    
    
}
