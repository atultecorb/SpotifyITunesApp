//
//  PlayerDetailsViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 29/03/23.
//

import UIKit

class PlayerDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var btnForNext: UIButton!
    
    @IBOutlet weak var btnForPrevious: UIButton!
    
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var favUnFavBtn: UIButton!
    
    @IBOutlet weak var btnForShuffle: UIButton!
    
    var trackId: String = ""
    
    // MARK: - Spotify Authorization & Configuration
    var responseCode: String? {
        didSet {
            fetchAccessToken { (dictionary, error) in
                if let error = error {
                    print("Fetching token request error \(error)")
                    return
                }
                let accessToken = dictionary!["access_token"] as! String
                DispatchQueue.main.async {
                    print(accessToken)
                    AppSettings.shared.acToken = accessToken
                    self.appRemote.connectionParameters.accessToken = accessToken
                    self.appRemote.connect()
                   // AppSettings.shared.proceedToDashboard()
                  //  self.setRootViewController()
                }
            }
        }
    }
    
    
    
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

    private var lastPlayerState: SPTAppRemotePlayerState?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
        self.connectToSpotify()
        self.updateView()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.favUnFavBtn.setImage(UIImage(named: "unfav"), for: .normal)
    }
    
    func updateView(){
        self.playPauseButton.backgroundColor = .clear
        self.btnForNext.backgroundColor = .clear
        self.btnForPrevious.backgroundColor = .clear
        self.btnForShuffle.layer.cornerRadius = 15
        self.btnForShuffle.clipsToBounds = true
    }
    
    func connectToSpotify(){
        self.appRemote.connectionParameters.accessToken = AppSettings.shared.acToken
        self.appRemote.connect()
     
    }

    
    @objc func willResignActive(_ notification: Notification) {
        // code to execute
        self.appRemote.playerAPI?.pause()
    }
    
    
    
    func fetchArtwork(for track: SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.imageView.image = image
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
    
    func update(playerState: SPTAppRemotePlayerState) {
        if lastPlayerState?.track.uri != playerState.track.uri {
            fetchArtwork(for: playerState.track)
        }
        lastPlayerState = playerState
        trackLabel.text = playerState.track.name
        self.artistName.text = playerState.track.artist.name
        self.desc.text = playerState.track.album.name
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        if playerState.isPaused {
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
        }
    }
    
    func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((spotifyClientId + ":" + spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]

        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ")

        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: spotifyClientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: responseCode!),
            URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
            URLQueryItem(name: "code_verifier", value: ""), // not currently used
            URLQueryItem(name: "scope", value: scopeAsString),
        ]

        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                      print("Error fetching token \(error?.localizedDescription ?? "")")
                      return completion(nil, error)
                  }
            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("Access Token Dictionary=", responseObject ?? "")
            completion(responseObject, nil)
        }
        task.resume()
    }
    
    @IBAction func actionOnPlaypause(_ sender: UIButton) {
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
        } else {
            appRemote.playerAPI?.pause(nil)
        }
        
    }
    
    func makeFavUnfavTrack(trackId:String, accessToken:String){
        let token = AppSettings.shared.acToken
        Services.shareInstance.makeFavourite(trackId: trackId, token: token)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func actionToNext(_ sender: UIButton) {
        appRemote.playerAPI?.skip(toNext: { (play, error) in
            print(play)
        })
    }
    
    @IBAction func actionToPrevious(_ sender: UIButton) {
        appRemote.playerAPI?.skip(toPrevious: {(play, error) in
            print(play)
        })
    }
    
    @IBAction func actionOnFavUnFav(_ sender: UIButton) {
        print("Hit find")
        
        
        
       // appRemote.playerAPI?.play("spotify:artist:5VQE4WOzPu9h3HnGLuBoA6")
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected{
//            self.favUnFavBtn.setImage(UIImage(named: "fav"), for: .selected)
//        } else {
//            self.favUnFavBtn.setImage(UIImage(named: "unfav"), for: .normal)
//        }
//        let access = AppSettings.shared.acToken
//        let id = appRemote.userAPI
//        self.makeFavUnfavTrack(trackId: "15", accessToken: access)
        
        
    }
    
    @IBAction func actionOnRepeatOrShuffle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            //self.appRemote.playerAPI?.setRepeatMode(.context)
            self.appRemote.playerAPI?.setShuffle(true)
            print("Shuffle On")
            self.showToast(message: "Shuffle On", font: UIFont(name: "Helvetica Bold", size: 15)!)
        } else {
           // self.appRemote.playerAPI?.setRepeatMode(.off)
            self.appRemote.playerAPI?.setShuffle(false)
            print("Shuffle Off")
            self.showToast(message: "Shuffle Off", font: UIFont(name: "Helvetica Bold", size: 15)!)
        }
    }   
}

// MARK: - SPTAppRemoteDelegate
extension PlayerDetailsViewController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
       // updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
       // updateViewBasedOnConnected()
        lastPlayerState = nil
        if !appRemote.isConnected {
            AppSettings.shared.proceedToSpotifySignIn()
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
       // updateViewBasedOnConnected()
        lastPlayerState = nil
        if !appRemote.isConnected {
           AppSettings.shared.proceedToSpotifySignIn()
        }
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension PlayerDetailsViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
        update(playerState: playerState)
        
        print("player state changed")
        print("isPaused", playerState.isPaused)
        print("track.uri", playerState.track.uri)
        print("track.name", playerState.track.name)
        print("track.imageIdentifier", playerState.track.imageIdentifier)
        print("track.artist.name", playerState.track.artist.name)
        print("track.album.name", playerState.track.album.name)
        print("track.isSaved", playerState.track.isSaved)
        print("playbackSpeed", playerState.playbackSpeed)
        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
        print("playbackPosition", playerState.playbackPosition)
        
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
