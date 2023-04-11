//
//  ViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 23/03/23.
//

/*
 ["expires_in": 3600, "access_token": BQDCzLFmZUql8deEXvr6_WMQ8yg8hOemnz0NDe6L5HO5Vwruuf6_9GsFGgQ0PWnGvRqhIMbwXyTUsf21USpLZRmEH5CE0pz5AOVxAXvx3zM_JJiPAspRIK3Uailg4T4aWw_koEKxgfonnVlwViX4JIreow57CbFiuSdAmDkP4dhL8CuONPwcR7CqsUeT17fBecsMzMyeUl3cgaox7LmlDlrUcNaYaE96p0PzDWYSha7JwD479sGaLeiKc85c8m6ACpJvCb54XCEecUxCA4EzKwsMdzboOJAKgjVYUqZKbyrw_Iqb5J2HGCCXc8NB7b4LV2D88f8ElPRHoQ, "scope": playlist-read-private playlist-read-collaborative user-follow-read playlist-modify-private user-read-email user-read-private streaming app-remote-control user-follow-modify user-modify-playback-state user-library-read user-library-modify playlist-modify-public user-read-playback-state user-read-currently-playing user-top-read, "token_type": Bearer, "refresh_token": AQDT6cbRJ9AhWnOFuQ7y7mua2dckG8sfyjOMAgrUuQfmoa1QOn3gF-6iRIo7LlGVqGQkMINOiaG6qt0IzMkeRUChkkdfCXPR3kQ4YzJZFj-SnkhZPmO5qkfsQIPdcjLnZxw]
 */

import UIKit
import SafariServices

class ViewController: UIViewController {
    
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
//                    self.appRemote.connectionParameters.accessToken = accessToken
//                    self.appRemote.connect()
                    AppSettings.shared.proceedToDashboard()
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

    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    private var lastPlayerState: SPTAppRemotePlayerState?
    let connectLabel = UILabel()
    let connectButton = UIButton(type: .system)
    let imageView = UIImageView()
    let trackLabel = UILabel()
    let playPauseButton = UIButton(type: .system)
    let signOutButton = UIButton(type: .system)
    let myPlayList = UIButton(type: .system)
    let myAlbumList = UIButton(type: .system)
    
    var appDelegate = UIApplication.shared.delegate
    var window: UIWindow?

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
            self.style()
        //MARK:- Developer code
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
//         let encodedID  = "\(spotifyClientId.toBase64()):\(spotifyClientSecretKey.toBase64())"
//         print(encodedID)
        
       // self.window = (UIApplication.shared.delegate?.window)!
        
       // NotificationCenter.default.addObserver(self, selector: #selector(updateRootViewController), name: .SET_ROOT_CONTROLLER, object: nil)
        
    }
    
    @objc func updateRootViewController(_ notification:Notification) {
        self.pushController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         updateViewBasedOnConnected()
        self.viewDidLayoutSubviews()
    }
    
    @objc func willResignActive(_ notification: Notification) {
        // code to execute
        self.appRemote.playerAPI?.pause()
    }

    func update(playerState: SPTAppRemotePlayerState) {
        if lastPlayerState?.track.uri != playerState.track.uri {
            fetchArtwork(for: playerState.track)
        }
        lastPlayerState = playerState
        trackLabel.text = playerState.track.name

        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        if playerState.isPaused {
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
        }
    }

    // MARK: - Actions
    @objc func didTapPauseOrPlay(_ button: UIButton) {
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
        } else {
            appRemote.playerAPI?.pause(nil)
        }
    }

    @objc func didTapSignOut(_ button: UIButton) {
        if appRemote.isConnected == true {
            appRemote.disconnect()
        }
    }

    @objc func didTapConnect(_ button: UIButton) {
        
        let requestedScopes: SPTScope = [.appRemoteControl]
        sessionManager?.initiateSession(with: requestedScopes, options: .default)

        
//        guard let sessionManager = sessionManager else { return }
//        sessionManager.initiateSession(with: scopes, options: .clientOnly)

    }

    // MARK: - Private Helpers
    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
    
    func pushController(){
        let playlistVC = self.storyboard?.instantiateViewController(withIdentifier: "PlaylistViewController") as! PlaylistViewController
        playlistVC.view.backgroundColor = .black
        self.navigationController?.pushViewController(playlistVC, animated: true)
     //  self.present(playlistVC, animated: true)
        
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let playlistVC = storyBoard.instantiateViewController(withIdentifier: "PlaylistViewController") as! PlaylistViewController
//        self.navigationController?.pushViewController(playlistVC, animated: true)
//
    }
    
    
    @objc func seenToPlayList(sender:UIButton){
        self.pushController()
    }
    
    @objc func seenToAlbumList(sender:UIButton){
        let albumVC = AppStoryboard.Main.viewController(AlbumlistViewController.self)
        albumVC.view.backgroundColor = .white
        self.navigationController?.pushViewController(albumVC, animated: true)
        //self.present(registerViewController, animated: true)
    }
    
}

// MARK: Style & Layout
extension ViewController {
    func style() {
        myPlayList.frame = CGRect(x: self.view.frame.width-130, y: 40, width: 120, height: 40)
        myPlayList.setTitle("My Playlist", for: .normal)
        myPlayList.setTitleColor(.white, for: .normal)
        myPlayList.backgroundColor = .red
        myPlayList.layer.cornerRadius = 6
        
        myAlbumList.frame = CGRect(x: self.view.frame.width-130, y: myPlayList.frame.origin.y+myPlayList.frame.height+20, width: 120, height: 40)
        myAlbumList.setTitle("My Album", for: .normal)
        myAlbumList.setTitleColor(.white, for: .normal)
        myAlbumList.backgroundColor = .red
        myAlbumList.layer.cornerRadius = 6
        
        signOutButton.frame = CGRect(x: 10, y: self.view.frame.height-20, width: self.view.frame.width-20, height: -50)
        connectButton.frame = CGRect(x: 10, y: signOutButton.frame.origin.y-(signOutButton.frame.height+15), width: self.view.frame.width-20, height: 50)
        connectLabel.frame = CGRect(x: 10, y: connectButton.frame.origin.y-(connectButton.frame.height+10), width: self.view.frame.width-20, height: 50)
        connectLabel.textAlignment = .center
        playPauseButton.frame = CGRect(x: connectLabel.frame.width/2-20, y: connectLabel.frame.origin.y-(connectLabel.frame.height+10), width: 60, height: 60)
        
        imageView.frame = CGRect(x: 10, y: 0, width: self.view.frame.width-20, height: self.view.frame.height-(signOutButton.frame.height+connectButton.frame.height+connectLabel.frame.height+playPauseButton.frame.height+trackLabel.frame.height+10))
        imageView.image = UIImage(named: "spotify")
        imageView.contentMode = .scaleAspectFit
        
        trackLabel.frame = CGRect(x: 10, y: imageView.frame.origin.y+(imageView.frame.height+20), width: self.view.frame.width-20, height: 60)
        trackLabel.textAlignment = .center
        trackLabel.numberOfLines = 0
        trackLabel.font = UIFont(name: "Helvetica", size: 14)
        
        signOutButton.backgroundColor = .red
        signOutButton.setTitleColor(.white, for: .normal)
        connectButton.backgroundColor = .black
        connectLabel.backgroundColor = .clear
        playPauseButton.backgroundColor = .white
        trackLabel.backgroundColor = .clear
        imageView.backgroundColor = .clear
        self.view.addSubview(signOutButton)
        self.view.addSubview(connectButton)
        self.view.addSubview(connectLabel)
        self.view.addSubview(playPauseButton)
        self.view.addSubview(trackLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(myPlayList)
        self.view.addSubview(myAlbumList)
        connectLabel.text = "Connect your Spotify account"
        connectLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        connectLabel.textColor = .systemGreen
       // connectButton.configuration = .filled()
        connectButton.setTitle("Continue with Spotify", for: [])
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        connectButton.addTarget(self, action: #selector(didTapConnect), for: .primaryActionTriggered)
        trackLabel.text = "Track Name"
       // trackLabel.font = UIFont.preferredFont(forTextStyle: .body)
        trackLabel.textAlignment = .center
        playPauseButton.addTarget(self, action: #selector(didTapPauseOrPlay), for: .primaryActionTriggered)
        playPauseButton.backgroundColor = .black
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        signOutButton.addTarget(self, action: #selector(didTapSignOut(_:)), for: .touchUpInside)
        myPlayList.addTarget(self, action: #selector(ViewController.seenToPlayList(sender:)), for: .touchUpInside)
        myAlbumList.addTarget(self, action: #selector(ViewController.seenToAlbumList(sender:)), for: .touchUpInside)
    }

    func updateViewBasedOnConnected() {
        if appRemote.isConnected == true {
            connectButton.isHidden = true
            signOutButton.isHidden = false
            connectLabel.isHidden = true
            imageView.isHidden = false
            trackLabel.isHidden = false
            playPauseButton.isHidden = false
            myPlayList.isHidden = false
            myAlbumList.isHidden = false
        }
        else { // show login
            signOutButton.isHidden = true
            connectButton.isHidden = false
            connectLabel.isHidden = false
            imageView.isHidden = true
            trackLabel.isHidden = true
            playPauseButton.isHidden = true
            myPlayList.isHidden = true
            myAlbumList.isHidden = true
        }
        self.viewDidLoad()
        self.viewWillAppear(true)
    }
}

// MARK: - SPTAppRemoteDelegate
extension ViewController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension ViewController: SPTAppRemotePlayerStateDelegate {
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

// MARK: - SPTSessionManagerDelegate
extension ViewController: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            print("AUTHENTICATE with WEBAPI")
            guard let sessionManager = sessionManager else { return }
           // print(sessionManager.session.stateRestorationActivity?.webpageURL)
            self.authorizeUser()
        } else {
            presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
        }
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
    }
}

// MARK: - Networking
extension ViewController {

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
    
}


//MARK:- Manage redirection when device not installed Spotify...
/*
https://accounts.spotify.com/authorize?
nolinks=true&nosignup=true&
response_type=token&
scope=streaming&
utm_source=spotify-sdk&
utm_medium=ios-sdk&
utm_campaign=ios-sdk&
redirect_uri=messages-app%3A%2F%2F&
show_dialog=true&
client_id=xxx
*/

extension ViewController{
    
    @objc func authorizeUser()
        {
            let redirectURI = "SpotifyITunes://callback"
            guard let url = URL(string: "\(baseUrl)authorize?client_id=\(spotifyClientId)&response_type=token&scope=streaming&utm_source=ios-sdk&redirect_uri=\(redirectURI)&show_dialog=true") else {
              //  presentSSAlertOnMainThread(title: "Sorry", message: Message.authorization, isPlaylistAlert: false)
                return
            }
            presentSafariVC(with: url)
        }
        
        private func presentSafariVC(with url: URL)
        {
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredControlTintColor  = .systemGreen
            safariVC.preferredBarTintColor      = .green
            safariVC.delegate                   = self
            present(safariVC, animated: true)
        }
    
    
    func authorizeFirstTimeUser(with url: String)
       {
           // if can't get request token --> auth user
           // get token from the URL: you might need to change your index here
           let index = url.index(url.startIndex, offsetBy: 33)
           let token = url.suffix(from: index)
           
           Services.shareInstance.completeAuthorizeRequest(with: String(token)) { results in
               guard let accessToken = results else {
                   print(results)
                   // self.dismissLoadingView()
                  // self.presentSSAlertOnMainThread(title: "Sorry", message: Message.authorization, isPlaylistAlert: false)
                   return
               }
               
               guard let accesToken = results else {return}
                   DispatchQueue.main.async {
                       AppSettings.shared.acToken = accesToken
                       self.appRemote.connectionParameters.accessToken = accesToken
                       self.appRemote.connect()
                       self.fetchPlayerState()
                   }
               
           }
       }
}

// MARK: - SFSafariViewControllerDelegate

extension ViewController: SFSafariViewControllerDelegate{
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL)
    {
        let currentURL = URL.absoluteString
        
        if currentURL.contains("\(baseUrl)?code=")
        {
            if AppSettings.shared.acToken == "" {
                self.authorizeFirstTimeUser(with: currentURL)
            } else {
                Services.shareInstance.getRefreshToken() { results in
                    guard let accessToken = results else {
                       // self.presentSSAlertOnMainThread(title: "Sorry", message: Message.authorization, isPlaylistAlert: false)
                        return
                    }
                        
                    DispatchQueue.main.async {
                      //  self.dismissLoadingView()
//                        let homeVC = HomeViewController()
//                        homeVC.OAuthtoken = accessToken
//                        self.navigationController?.pushViewController(homeVC, animated: true)
                    }
                }
            }
        }
    }
}
