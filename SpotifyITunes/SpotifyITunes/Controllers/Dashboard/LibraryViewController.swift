//
//  LibraryViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 29/03/23.
//

import UIKit

class LibraryViewController: UIViewController {
    @IBOutlet weak var tblViewForPlaylist: UITableView!
    
    
    var playList =  PlayListParser()
    
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
      //  self.title = "Library"
        self.registerCell()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Album",
                                                                         style: .plain,
                                                                         target: self,
                                                                         action: #selector(albumAction))
    }
    
    @objc
        func albumAction() {
            let albumVC = AppStoryboard.Main.viewController(AlbumlistViewController.self)
            albumVC.view.backgroundColor = .black
            self.navigationController?.pushViewController(albumVC, animated: true)
    }
    
    func getPlayList(token:String){
        Services.shareInstance.getPlaylist(accessToken: token, {(responseData, error) in
            if error == nil{
                if let data = responseData{
                    self.playList = data
                    self.tblViewForPlaylist.reloadData()
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let token = AppSettings.shared.acToken
        self.getPlayList(token: token)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension LibraryViewController: UITableViewDataSource, UITableViewDelegate{
    
    func registerCell(){
        self.tblViewForPlaylist.register(UINib(nibName: "PlayListCell", bundle: nil), forCellReuseIdentifier: "PlayListCell")
        self.tblViewForPlaylist.dataSource = self
        self.tblViewForPlaylist.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblViewForPlaylist.dequeueReusableCell(withIdentifier: "PlayListCell", for: indexPath) as! PlayListCell
        cell.selectionStyle = .none
        let playListData = self.playList.items[indexPath.row]
       // cell.songImage.sd_setImage(with: URL(string:playListData.images.first?.url ?? ""), placeholderImage: UIImage(named: "SpotifyTrack"))
        cell.songImage.downloadImage(url: playListData.images.first?.url ?? "")
        cell.songImage.image = UIImage(named: "2")
        cell.trackName.text = "\(playListData.name.capitalized)"
        cell.ownerName.text = "Playlist . " +  "\(playListData.owner.displayName.capitalized)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Playlist"
            label.font = .systemFont(ofSize: 17)
            label.textColor = .cyan
            headerView.addSubview(label)
            return headerView
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackId = self.playList.items[indexPath.row].uri
        self.chnagePlayerState(trackId: trackId)
    }
    
    
    func chnagePlayerState(trackId:String){
        appRemote.authorizeAndPlayURI(trackId)
    }
}


// MARK: - SPTAppRemoteDelegate
extension LibraryViewController: SPTAppRemoteDelegate {
    
    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
               // self?.update(playerState: playerState)
            }
        })
    }
    
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
           // AppSettings.shared.proceedToSpotifySignIn()
        }
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension LibraryViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
       // update(playerState: playerState)
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
