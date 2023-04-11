//
//  SpotifyTabbarController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 29/03/23.
//

import UIKit

class SpotifyTabbarController: UITabBarController {
    
    var playerView : CustomPlayerView!
    
    
    private var lastPlayerState: SPTAppRemotePlayerState?
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }
    
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating
        // otherwise another app switch will be required
        configuration.playURI = ""
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubViewPlayerViewOnTab()
        self.connectToSpotify()
    }

    func connectToSpotify(){
        self.appRemote.connectionParameters.accessToken = AppSettings.shared.acToken
        self.appRemote.connect()
    }
    
    
    func addSubViewPlayerViewOnTab(){
        print(self.tabBar.frame.height)
        playerView = CustomPlayerView.instanceFromNib()
        playerView.frame = CGRect(x: 10, y: self.view.frame.height-(self.tabBar.frame.height*2), width: self.view.frame.width-20, height: 50)
        playerView.backgroundColor = UIColor(hexString: "#3B3B3B")
        playerView.layer.cornerRadius = 7
        playerView.songName.font = UIFont(name: "Helvetica Neue Medium", size: 14)
        playerView.singerName.font = UIFont(name: "Helvetica Neue", size: 12)
        playerView.btnForPlayPause.addTarget(self, action: #selector(SpotifyTabbarController.actionOnPlayPause(sender:)), for: .touchUpInside)
        playerView.btnForView.addTarget(self, action: #selector(SpotifyTabbarController.actionOnPlayerDetails(sender:)), for: .touchUpInside)
        self.view.addSubview(playerView)
        self.tabBar.bringSubviewToFront(playerView)
        self.view.bringSubviewToFront(playerView)
    }
    
    @objc func actionOnPlayPause(sender:UIButton){
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
        } else {
            appRemote.playerAPI?.pause(nil)
        }
    }
    
    
    @objc func actionOnPlayerDetails(sender:UIButton){
        self.connectToSpotify()
        let playerDetails = AppStoryboard.Main.viewController(PlayerDetailsViewController.self)
        playerDetails.view.backgroundColor = .black
        self.navigationController?.present(playerDetails, animated: true)
    }
}




// MARK: - SPTAppRemoteDelegate
extension SpotifyTabbarController : SPTAppRemoteDelegate {
    
    func fetchArtwork(for track: SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.playerView.image.image = image
            }
        })
    }

    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }
    
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        lastPlayerState = nil
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension SpotifyTabbarController: SPTAppRemotePlayerStateDelegate {
    
    func update(playerState: SPTAppRemotePlayerState) {
        if lastPlayerState?.track.uri != playerState.track.uri {
            fetchArtwork(for: playerState.track)
        }
        lastPlayerState = playerState
        self.playerView.songName.text = playerState.track.name.capitalized
        self.playerView.singerName.text = playerState.track.artist.name.capitalized
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        if playerState.isPaused {
            self.playerView.btnForPlayPause.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
        } else {
            self.playerView.btnForPlayPause.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
        }
    }
    
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
        update(playerState: playerState)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
      if self.appRemote.isConnected {
        self.appRemote.disconnect()
      }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      if let _ = self.appRemote.connectionParameters.accessToken {
        self.appRemote.connect()
      }
    }
}
