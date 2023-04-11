//
//  HomeViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 29/03/23.
//

import UIKit
import SpotifyiOS

enum MediaFlow {
case playlist, album, topTracker
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    var mediaType:MediaFlow?
    
    /*
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    */
    
   // let spotifyAppRemote = SpotifyAppRemote(configuration: SpotifyAppRemoteConfiguration(clientID: "YOUR_CLIENT_ID", clientSecret: "YOUR_CLIENT_SECRET", redirectURL: URL(string: "spotify-ios-quick-start://spotify-login-callback")!))

    
    
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
    
    var categorires = [Items]()
    var playList = PlaylistRootClass()
    var albumList = AlbumRootClass()
    var topTrackers = TopTrackRootClass()

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.view.backgroundColor = .black
       // self.title = "Home"
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
        self.connectToSpotify()
        self.registerCell()
      //  self.getCategoresList()
        let accessToken = AppSettings.shared.acToken
        if AppSettings.shared.acToken != ""{
            self.getPlayList(playListId: "1W872cuF8dGUUbPAHxio76", accessToken: accessToken)
            self.getAlbumList(albumId: "3l4aFewGXpPsQJbIa1AnGj", accessToken: accessToken)
            self.getUserQueue(accessToken: accessToken)
            self.getTopTrackerList(artistId: "3bAFvRjPZrpRz9Ox1sElQa", token: accessToken)
            NotificationCenter.default.addObserver(self, selector: #selector(playSpotify), name: .STARTSPOTIFYPLAYER, object: nil)
        }
    }
    
    @objc func playSpotify(_ notification:Notification) {
        if let userInfo = notification.userInfo{
            if let uriId = userInfo["uri"] as? String{
                self.appRemote.playerAPI?.play(uriId)
            }
        }
    }
    
    func connectToSpotify(){
        self.appRemote.connectionParameters.accessToken = AppSettings.shared.acToken
        self.appRemote.connect()
    }
    
    func getUserQueue(accessToken:String){
        Services.shareInstance.getUserQueue(accessToken, {(responseData, error) in
            if error == nil{
                
            } else {
                
            }
        })
    }
    
    
    func getPlayList(playListId:String, accessToken:String){
        Services.shareInstance.getPlayList(playListId: playListId, accessToken: accessToken, {(responseData, error) in
            if error == nil{
                if let playListData = responseData{
                    self.playList = playListData
                    self.tblView.reloadData()
                }
            }
        })
    }
    
    func getTopTrackerList(artistId:String, token:String){
        Services.shareInstance.getTopTracker(artistId: artistId, accessToken: token, {(responseData, error) in
            if error == nil{
                if let data = responseData{
                    self.topTrackers = data
                    self.tblView.reloadData()
                }
            }
            
        })
    }
    
    func getAlbumList(albumId:String, accessToken:String){
        Services.shareInstance.getAlbumList(albumId: albumId, accessToken: accessToken, {(responseData, error) in
            if error == nil{
                if let albumListData = responseData{
                    self.albumList = albumListData
                    self.tblView.reloadData()
                }
            }
        })
    }
    
    func getCategoresList(){
        let accessToken = AppSettings.shared.acToken
        Services.shareInstance.getCategorieslist(accessToken: accessToken, {(catData, error) in
            if error == nil{
                guard let categories = catData else {
                    return
                }
                self.categorires = categories.items ?? []
              //  self.collectionViewForCategories.reloadData()
            } else {
                print("access token has been expired.")
            }
        })
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
               // self?.imageView.image = image
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
       // trackLabel.text = playerState.track.name

        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        if playerState.isPaused {
           // playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
        } else {
          //  playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
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
       /*
        self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
            
        })
        */
        
        
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
          //  appRemote.playerAPI?.play("spotify:track:58s6EuEYJdlb0kO7awm3Vp")
        } else {
            appRemote.playerAPI?.pause(nil)
           // appRemote.playerAPI?.play("spotify:track:58s6EuEYJdlb0kO7awm3Vp")
           
        }
        
    }
    

}

// MARK: - SPTAppRemoteDelegate
extension HomeViewController: SPTAppRemoteDelegate {
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
extension HomeViewController: SPTAppRemotePlayerStateDelegate {
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

extension HomeViewController:UITableViewDataSource, UITableViewDelegate{
    @objc func actionOnSeeAllArtists(sender:UIButton){
        if sender.tag == 0 {
            
        } else if sender.tag == 1 {
            let artisvC = AppStoryboard.Main.viewController(ArtistsViewController.self)
            artisvC.albumList = self.albumList
            self.navigationController?.pushViewController(artisvC, animated: true)
        } else if sender.tag == 2 {
            let albumVC = AppStoryboard.Main.viewController(AlbumViewController.self)
            albumVC.artistId = "3bAFvRjPZrpRz9Ox1sElQa"
            albumVC.artistTrack = .topTracker
            self.navigationController?.pushViewController(albumVC, animated: true)
        }
        
    }
    
    func registerCell(){
        self.tblView.register(UINib(nibName: "PlaylistTableCell", bundle: nil), forCellReuseIdentifier: "PlaylistTableCell")
        self.tblView.dataSource = self
        self.tblView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3//2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblView.dequeueReusableCell(withIdentifier: "PlaylistTableCell", for: indexPath) as! PlaylistTableCell
        cell.selectionStyle = .none
        cell.playListDelagte = self
        cell.backgroundColor = .white
        if indexPath.section == 0 {
            cell.playList = self.playList
            cell.mediaType = .playlist
        } else if indexPath.section == 1 {
            cell.albumList = self.albumList
            cell.mediaType = .album
        } else if indexPath.section == 2 {
            cell.topTrackers = self.topTrackers
            cell.mediaType = .topTracker
        }
        cell.collectionView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel()
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        let subLabelBtn = UIButton()
        subLabelBtn.frame = CGRect.init(x: headerView.frame.width-160, y: 5, width: 200, height: headerView.frame.height-10)
        
        if section == 0 {
            label.text = "Playlist"
            subLabelBtn.setTitle("See Playlist", for: .normal)
        } else if section == 1 {
            label.text = "Album"
            subLabelBtn.setTitle("See Artists", for: .normal)
        } else if section == 2 {
            label.text = "Top Tracker"
            subLabelBtn.setTitle("See Top Tracker", for: .normal)
        }
        label.font = UIFont(name: "Helvetica Bold", size: 20)
        label.textColor = .white
        subLabelBtn.titleLabel?.font = UIFont(name: "Helvetica Bold", size: 15)
        subLabelBtn.setTitleColor(.systemBlue, for: .normal)
        subLabelBtn.tag = section
        subLabelBtn.addTarget(self, action: #selector(HomeViewController.actionOnSeeAllArtists(sender:)), for: .touchUpInside)
        headerView.addSubview(label)
        headerView.addSubview(subLabelBtn)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
   
}

/*
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    func registerCell(){
        self.collectionViewForCategories.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionViewForCategories.setCollectionViewLayout(layout, animated: true)
        // self.collectionViewForCategory.isPagingEnabled = true
        self.collectionViewForCategories.decelerationRate = .fast
        self.collectionViewForCategories.showsHorizontalScrollIndicator = false
        self.collectionViewForCategories.reloadData()
        self.collectionViewForCategories.dataSource = self
        self.collectionViewForCategories.delegate = self
    }
    
    //MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.playList.tracks?.items{
            return count.count
        } else {
            return 0
        }
        //self.categorires.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionViewForCategories.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
     /*   let catData = self.categorires[indexPath.item]
        let url = URL(string: catData.icons?.first?.url ?? "")
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data!)
            }
        }
        cell.titleName.text = catData.name?.capitalized
        */
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
               let width  = (view.frame.width)/3
               return CGSize(width: width, height: width)
       } 
}
*/

extension HomeViewController:OnPlayPlaylistProtocol{
    func playFromPlayList(id: String) {
        self.appRemote.playerAPI?.play(id)
    }
}
