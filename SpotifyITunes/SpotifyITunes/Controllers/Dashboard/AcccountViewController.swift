//
//  AcccountViewController.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 29/03/23.
//

import UIKit

class AcccountViewController: UIViewController {
    

    @IBOutlet weak var tblViewForAccount: UITableView!
    
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
    
    
   
    
   // var userProfile : UserProfileParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.connectToSpotify()
        // Do any additional setup after loading the view.
    }
    
    func connectToSpotify(){
        self.appRemote.connectionParameters.accessToken = AppSettings.shared.acToken
        self.appRemote.connect()
    }
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showWarningMessage(){
        let refreshAlert = UIAlertController(title: "Spotify", message: "Are you sure to Sign Out Spotify.", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
              print("Handle Ok logic here")
            self.makeSignOutFromSpotify()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
        }))
        refreshAlert.view.tintColor = .cyan
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func switchToPeofileViewController(){
        let profileVC = AppStoryboard.Main.viewController(ProfieViewController.self)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

}

extension AcccountViewController: UITableViewDataSource, UITableViewDelegate{
    
    
    func setRootController(){
        AppSettings.shared.proceedToSpotifySignIn()
    }
    
    
     func makeSignOutFromSpotify(){
         if appRemote.isConnected == true {
             appRemote.playerAPI?.pause(nil)
             appRemote.disconnect()
         }
         self.setRootController()
    }
    
    func registerCell(){
        self.tblViewForAccount.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        self.tblViewForAccount.dataSource = self
        self.tblViewForAccount.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblViewForAccount.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.titleName.text = "View Profile"
            cell.titleName.textColor = .white
        } else {
            cell.titleName.text = "Sign Out"
            cell.titleName.textColor = .red
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "Account"
            label.font = UIFont(name: "Helvetica Bold", size: 20)
            label.textColor = .cyan
            headerView.addSubview(label)
            return headerView
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.switchToPeofileViewController()
        } else if indexPath.row == 1 {
            self.showWarningMessage()
        }
    }
}


// MARK: - SPTAppRemoteDelegate
extension AcccountViewController : SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
    
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        lastPlayerState = nil
    }
}
