//
//  lyricVC.swift
//  ZINGMP3
//
//  Created by NhatMinh on 3/22/17.
//  Copyright © 2017 Nhật Minh. All rights reserved.
//

import UIKit

class lyricVC: UIViewController {

    @IBOutlet weak var lyricView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let passingLyric = PassingLyric.sharedInstance
        if let lyric = passingLyric.lyric
        {
            lyricView.text = lyric
            lyricView.textAlignment = .center
        }
    }


}
