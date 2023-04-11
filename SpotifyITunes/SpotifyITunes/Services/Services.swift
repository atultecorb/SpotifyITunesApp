//
//  Services.swift
//  TestDemoMVVM
//
//  Created by Tecorb Technologies on 21/03/23.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit


class Services: NSObject {
    static let shareInstance = Services()
    
    
    private let encodedID  = "\(spotifyClientId.toBase64()):\(spotifyClientSecretKey.toBase64())"
    let cache           = NSCache<NSString, UIImage>()
    private let limit           = "50"
    private let offset          = "0"

    func getPlaylist(accessToken: String, _ onCompletion:@escaping (PlayListParser?, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/me/playlists"
        AF.request(playListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let playList = PlayListParser(json)
               // let clothModel = json.arrayValue.map{ ClothModel($0)}
                print(playList)
                onCompletion(playList, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func getUserProfile(accessToken: String, _ onCompletion:@escaping (UserProfileParser?, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/me"
        AF.request(playListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let userProfile = UserProfileParser(json)
               // let clothModel = json.arrayValue.map{ ClothModel($0)}
                print(userProfile)
                onCompletion(userProfile, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func getPlayList(playListId:String, accessToken: String, _ onCompletion:@escaping(PlaylistRootClass?, Error?) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/playlists/\(playListId)"
        AF.request(playListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let userProfile = PlaylistRootClass(json)
               // let clothModel = json.arrayValue.map{ ClothModel($0)}
                print(userProfile)
                onCompletion(userProfile, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    //3l4aFewGXpPsQJbIa1AnGj
    
    func getAlbumList(albumId:String, accessToken: String, _ onCompletion:@escaping(AlbumRootClass?, Error?) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/albums/\(albumId)"
        AF.request(playListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let userProfile = AlbumRootClass(json)
               // let clothModel = json.arrayValue.map{ ClothModel($0)}
                print(userProfile)
                onCompletion(userProfile, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func getAllAlbumByArtist(artistId:String, accessToken: String, _ onCompletion:@escaping(AlbumRootClass?, Error?) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/artists/\(artistId)/albums"
        AF.request(playListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let userProfile = AlbumRootClass(json)
               // let clothModel = json.arrayValue.map{ ClothModel($0)}
                print(userProfile)
                onCompletion(userProfile, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func getUserQueue(_ accessToken: String, _ onCompletion:@escaping(AlbumRootClass?, Error?) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/me/player/queue"
        AF.request(playListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let userProfile = AlbumRootClass(json)
               // let clothModel = json.arrayValue.map{ ClothModel($0)}
                print(userProfile)
                onCompletion(userProfile, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func getTopTracker(artistId:String, accessToken: String, _ onCompletion:@escaping(TopTrackRootClass?, Error?) -> Void){
        
        var params = Dictionary<String,Any>()
        params.updateValue("IN", forKey: "market")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/artists/\(artistId)/top-tracks"
        AF.request(playListUrl, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let userProfile = TopTrackRootClass(json)
               // let clothModel = json.arrayValue.map{ ClothModel($0)}
                print(userProfile)
                onCompletion(userProfile, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func makeFavourite(trackId:String, token:String){
        let apiUrl = URL(string: "https://api.spotify.com/favorites")!
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let item = ["id": trackId]
        let jsonData = try! JSONSerialization.data(withJSONObject: item, options: [])
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            print(response)
            // Handle success response
        }
        task.resume()
    }
    
    
    
    func getCategorieslist(accessToken: String, _ onCompletion:@escaping (Categories?, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let playListUrl = "https://api.spotify.com/v1/browse/categories"
        AF.request(playListUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                print(json)
                let playList = RootClass(json)
                if playList.error?.status == 401{
                    AppSettings.shared.proceedToSpotifySignIn()
                } else {
                    onCompletion(playList.categories, nil)
                }
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    /*
    func getProductDetails(id:String, _ onCompletion:@escaping (ClothModel?, Error?) -> Void){
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let detailsUrl = "https://fakestoreapi.com/products"+"/\(id)"
        AF.request(detailsUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                let clothModel = ClothModel(json)
                print(json)
                onCompletion(clothModel, nil)
                
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func addProduct(title:String, price:String, descrip: String, category:String, _ onCompletion:@escaping (ClothModel?, Error?) -> Void){
        var params = Dictionary<String,Any>()
        params.updateValue(title, forKey: "title")
        params.updateValue(price, forKey: "price")
        params.updateValue(descrip, forKey: "description")
        params.updateValue(category, forKey: "category")
        params.updateValue("https://i.pravatar.cc", forKey: "image")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let detailsUrl = "https://fakestoreapi.com/products"
        AF.request(detailsUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                let clothModel = ClothModel(json)
                print(json)
                onCompletion(clothModel, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func updateProduct(id: Int, title:String, price:String, descrip: String, category:String, _ onCompletion:@escaping (ClothModel?, Error?) -> Void){
        var params = Dictionary<String,Any>()
        params.updateValue(title, forKey: "title")
        params.updateValue(price, forKey: "price")
        params.updateValue(descrip, forKey: "description")
        params.updateValue(category, forKey: "category")
        params.updateValue("https://i.pravatar.cc", forKey: "image")
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let detailsUrl = "https://dummyjson.com/products"+"/\(id)"
        AF.request(detailsUrl, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                let clothModel = ClothModel(json)
                print(json)
                onCompletion(clothModel, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    func deleteProduct(id: Int, _ onCompletion:@escaping (ClothModel?, Error?) -> Void){
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let deleteUrl = "https://fakestoreapi.com/products"+"/\(id)"
        AF.request(deleteUrl, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result{
            case .success(let jsonObj):
                let json = JSON(jsonObj)
                let clothModel = ClothModel(json)
                print(json)
                onCompletion(clothModel, nil)
            case .failure(let error):
                print(error)
                onCompletion(nil, error)
                break
            }
        }
    }
    
    */

    func completeAuthorizeRequest(with endpoint: String, completed: @escaping (String?) -> Void)
    {
        var requestBodyComponents = URLComponents()
        let requestHeaders: [String:String] = ["Authorization" : "Basic \(encodedID)",
                                               "Content-Type" : "application/x-www-form-urlencoded"]
        requestBodyComponents.queryItems = [URLQueryItem(name: "grant_type", value: "authorization_code"),
                                            URLQueryItem(name: "code", value: endpoint),
                                            URLQueryItem(name: "redirect_uri", value: "SpotifyITunes://callback")]
        guard let url = URL(string: "\(baseUrl)api/token") else { return }
        var request                 = URLRequest(url: url)
        request.httpMethod          = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody            = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
           
            if let _            = error { print("completeAuthorizeRequest: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("completeAuthorizeRequest: response"); return }
            guard let data      = data else { print("completeAuthorizeRequest: data"); return }
           
            do {
                let decoder                     = JSONDecoder()
                decoder.keyDecodingStrategy     = .convertFromSnakeCase
                let token                       = try decoder.decode(Token.self, from: data)
                
                AppSettings.shared.acToken = token.accessToken
                AppSettings.shared.refreshToken = token.refreshToken
                completed(token.accessToken)
                return
            } catch {
                print("completeAuthorizeRequest: catch")
            }
        }
        task.resume()
    }
    
    func getRefreshToken(completed: @escaping (String?) -> Void)
    {
        let refreshToken = AppSettings.shared.acToken
        if refreshToken == "" { return }
        let requestHeaders: [String:String] = ["Authorization" : "Basic \(encodedID)",
                                               "Content-Type" : "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                                            URLQueryItem(name: "HeaderField.refreshToken", value: refreshToken)]
        guard let url = URL(string: "\(baseUrl)api/token") else { return }
        var request                 = URLRequest(url: url)
        request.httpMethod          = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody            = requestBodyComponents.query?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _            = error { print("getRefreshToken: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getRefreshToken: response"); return }
            guard let data      = data else { print("getRefreshToken: data"); return }
            do {
                let decoder                     = JSONDecoder()
                decoder.keyDecodingStrategy     = .convertFromSnakeCase
                let token                       = try decoder.decode(Token.self, from: data)
                AppSettings.shared.acToken = token.accessToken
               // PersistenceManager.saveAccessToken(accessToken: token.accessToken!)
                completed(token.accessToken)
                return
            } catch {
                print("getRefreshToken: catch");
            }
        }
        task.resume()
    }
    
    func getAlbums(accessToken:String, _ onCompletion: @escaping(AlbumParser?, Error?)-> Void) {
        let token = accessToken
        let url = URL(string: "https://api.spotify.com/v1/me/albums")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: No data returned")
                return
            }
            do {
                let albumJson = JSON(data)
                let albumParser = AlbumParser(albumJson)
                onCompletion(albumParser, nil)
            } catch {
                print("Error: \(error.localizedDescription)")
                onCompletion(nil, error)
            }
        }

        task.resume()
    }
    
    /*
    // MARK: - PLAYLIST DATA
    
    func createPlaylist(OAuthtoken: String, playlistName: String, playlistDescription: String, songs: [String], isPublic: String, completed: @escaping (String?) -> Void)
    {
        guard let urlUser = URL(string: "\(baseUrl)v1/me") else { print("urlUser"); return }
        
        var requestUser         = URLRequest(url: urlUser)
        requestUser.httpMethod  = "GET"
        requestUser.addValue("application/json", forHTTPHeaderField: "Accept")
        requestUser.addValue("application/json", forHTTPHeaderField: "Content-Type")
        requestUser.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: "Authorization")
        
        let taskUserID = URLSession.shared.dataTask(with: requestUser) { data, response, error in
            
            if let _            = error { print("taskUserID: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("taskUserID: response"); return }
            guard let data      = data else { print("taskUserIDL: data"); return }
            
            do {
                let decoder                 = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let user                    = try decoder.decode(UserProfile.self, from: data)
                
                guard let uid = user.id else { return }
                guard let urlPlaylist = URL(string: "\(baseUrl)v1/users/\(uid)/playlists") else { print("urlPlaylist"); return }
                
                let requestPlaylistHeaders: [String:String] = ["Accept" : "application/json",
                                                               "Content-Type" : "application/json",
                                                               "Authorization" : "Bearer \(OAuthtoken)"]
                
                let parametersPlaylist: [String: Any] = [
                    "name" : playlistName,
                    "description" : playlistDescription,
                    "public": false
                ]
                
                let jsonPlaylistData = try? JSONSerialization.data(withJSONObject: parametersPlaylist)
                
                var requestPlaylist                 = URLRequest(url: urlPlaylist)
                requestPlaylist.httpMethod          = "POST"
                requestPlaylist.allHTTPHeaderFields = requestPlaylistHeaders
                requestPlaylist.httpBody            = jsonPlaylistData
                
                let taskPlaylist = URLSession.shared.dataTask(with: requestPlaylist) { data, response, error in
                    
                    if let _        = error { return }
                    guard let data  = data else { return } /// no error code, bc returns error object
                    
                    do {
                        let decoder                 = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let playlist                = try decoder.decode(Playlist.self, from: data)

                        guard let playlistID = playlist.id else { return }
                        guard let urlSongs = URL(string: "\(baseUrl)v1/playlists/\(playlistID)/tracks") else { print("urlSongs"); return }
                        
                        let requestSongsHeaders: [String:String] = ["Accept" : "application/json",
                                                                    "Content-Type" : "application/json",
                                                                    "Authorization" : "Bearer \(OAuthtoken)"]
                        
                        let parametersSongs: [String: Any] = ["uris" : songs]
                        let jsonSongsData = try? JSONSerialization.data(withJSONObject: parametersSongs)
                        
                        var requestSongs                 = URLRequest(url: urlSongs)
                        requestSongs.httpMethod          = "POST"
                        requestSongs.allHTTPHeaderFields = requestSongsHeaders
                        requestSongs.httpBody            = jsonSongsData
                        
                        let taskSongs = URLSession.shared.dataTask(with: requestSongs) { data, response, error in
                            
                            if let _        = error { print("taskSongs: error"); return }
                            guard let data  = data else { print("taskSongs: data"); return }
                            
                            do {
                                let decoder                 = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                let snapshot                = try decoder.decode(Snapshot.self, from: data)
                                completed(snapshot.snapshotId); return
                            } catch { print("taskSongs: catch") }
                        }
                        taskSongs.resume()
                    } catch { print("taskPlaylist: catch") }
                }
                taskPlaylist.resume()
            } catch { print("taskUserID: catch") }
        }
        taskUserID.resume()
    }
    
    // MARK: - FETCH MUSIC DATA
    
    func getArtistRequest(OAuthtoken: String, completed: @escaping (ArtistItem?) -> Void)
    {
        let type        = "artists"
        let timeRange   = "long_term"
        
        guard let url = URL(string: "\(baseUrl)v1/me/top/\(type)?time_range=\(timeRange)&limit=\(limit)&offset=\(offset)") else { print("getArtistRequest: url"); return }
        
        var request         = URLRequest(url: url)
        request.httpMethod  = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: "A")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let _            = error { print("getArtistRequest: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getArtistRequest: response"); return }
            guard let data      = data else { print("getArtistRequest: data"); return }
            
            do {
                let decoder                 = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let artists                 = try decoder.decode(ArtistItem.self, from: data)
                
                completed(artists)
                return
            } catch {
                print("getArtistRequest: catch");
            }
        }
        task.resume()
    }
    
    func getTrackRequest(OAuthtoken: String, completed: @escaping (TrackItem?) -> Void)
     {
     let type        = "tracks"
     let timeRange   = "long_term"
     guard let url = URL(string: "\(baseUrl)v1/me/top/\(type)?time_range=\(timeRange)&limit=\(limit)&offset=\(offset)") else { print("getTrackRequest: url"); return }
     var request         = URLRequest(url: url)
     request.httpMethod  = "GET"
     request.addValue("application/json", forHTTPHeaderField: "Accept")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: "Authorization")
     let task = URLSession.shared.dataTask(with: request) { data, response, error in
     if let _            = error { print("getTrackRequest: error:"); return }
     guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getTrackRequest: response:"); return }
     guard let data      = data else { print("getTrackRequest: data:"); return }
     do {
     let decoder                 = JSONDecoder()
     decoder.keyDecodingStrategy = .convertFromSnakeCase
     let tracks                  = try decoder.decode(TrackItem.self, from: data)
     
     completed(tracks); return
     } catch {
     print("getTrackRequest: catch")
     }
     }
     task.resume()
     }
    
    func getRecentTracks(OAuthtoken: String, completed: @escaping (TrackItem?) -> Void)
    {
        let type        = "tracks"
        let timeRange   = "short_term" /// 4 weeks
        let limit       = "50"
        
        guard let url = URL(string: "\(baseUrl)v1/me/top/\(type)?time_range=\(timeRange)&limit=\(limit)&offset=\(offset)") else { print("getRecentTracks: url"); return }
        
        var request         = URLRequest(url: url)
        request.httpMethod  = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let _            = error { print("getRecentTracks: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getRecentTracks: response"); return }
            guard let data      = data else { print("getRecentTracks: data"); return }
            
            do {
                let decoder                 = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let tracks                  = try decoder.decode(TrackItem.self, from: data)
                
                completed(tracks); return
            } catch {
                print("getRecentTracks: url")
            }
        }
        task.resume()
    }
    
    func getNewTrackRequest(OAuthtoken: String, completed: @escaping (NewReleases?) -> Void)
    {
        guard let url = URL(string: "\(baseUrl)v1/browse/new-releases?country=US") else { print("getNewTrackRequest: url"); return }
        
        var request         = URLRequest(url: url)
        request.httpMethod  = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let _            = error { print("getNewTrackRequest: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getNewTrackRequest: response"); return }
            guard let data      = data else { print("getNewTrackRequest: data"); return }
            
            do {
                let decoder                 = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let tracks                  = try decoder.decode(NewReleases.self, from: data)
                
                completed(tracks); return
            } catch {
                print("getNewTrackRequest: catch")
            }
        }
        task.resume()
    }
    
    // MARK: - DOWNLOAD IMAGES
    
    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void)
    {
        let cacheKey    = NSString(string: urlString)
        if let image    = cache.object(forKey: cacheKey) { completed(image); return }
        guard let url   = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let self = self,
                error == nil,
                let response    = response as? HTTPURLResponse, response.statusCode == 200,
                let data        = data,
                let image       = UIImage(data: data) else { return }
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        task.resume()
    }

    */
    
    
}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}


//https://accounts.spotify.com/
