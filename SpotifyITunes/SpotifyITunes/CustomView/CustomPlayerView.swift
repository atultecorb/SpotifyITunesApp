//
//  CustomPlayerView.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 29/03/23.
//

import Foundation
import UIKit


class CustomPlayerView: UIView {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var singerName: UILabel!
    @IBOutlet weak var btnForPlayPause: UIButton!
    
    @IBOutlet weak var btnForView: UIButton!
    
    class func instanceFromNib() -> CustomPlayerView {
        return UINib(nibName: "CustomPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomPlayerView
    }
    
}


