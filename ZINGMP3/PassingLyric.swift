//
//  PassingLyric.swift
//  ZINGMP3
//
//  Created by NhatMinh on 3/22/17.
//  Copyright © 2017 Nhật Minh. All rights reserved.
//

import UIKit
class PassingLyric {
    static let sharedInstance = PassingLyric()
    private init() {}
    var lyric: String!
    init(lyric: String)
    {
        self.lyric = lyric
    }
}
