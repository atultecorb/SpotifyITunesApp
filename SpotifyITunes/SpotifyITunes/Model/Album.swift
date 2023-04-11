//
//  Album.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 28/03/23.
//

import Foundation
import SwiftyJSON


struct Album {
    var id = ""
    var copyrights = [Copyrights]()
    var totalTracks = 0
    var popularity = 0
    var href = ""
    var images = [ItemImages]()
    var availableMarkets = [Any]()
    var name = ""
    var type = ""
    var releaseDatePrecision = ""
    var releaseDate = ""
    var albumType = ""
    var albumGroup = ""
    var label = ""
    var artists = [Artists]()
    var externalUrls = ExternalUrls()
    var uri = ""
    var isPlayable = false
    var externalIds = ExternalIds()
    var tracks = Tracks()
    var track = [Tracks]()
    
    init(_ json:JSON) {
        id = json["id"].stringValue
        copyrights = json["copyrights"].arrayValue.map{Copyrights($0)}
        totalTracks = json["total_tracks"].intValue
        popularity = json["popularity"].intValue
        href = json["href"].stringValue
        images = json["images"].arrayValue.map{ItemImages($0)}
        availableMarkets = json["available_markets"].arrayObject ?? []
        name = json["name"].stringValue
        type = json["type"].stringValue
        releaseDatePrecision = json["release_date_precision"].stringValue
        releaseDate = json["release_date"].stringValue
        albumType = json["album_type"].stringValue
        albumGroup = json["album_group"].stringValue
        label = json["label"].stringValue
        artists = json["artists"].arrayValue.map{Artists($0)}
        externalUrls = ExternalUrls(json["external_urls"])
        uri = json["uri"].stringValue
        isPlayable = json["is_playable"].boolValue
        externalIds = ExternalIds(json["external_ids"])
        tracks =  Tracks(json["tracks"])
    }
    init() {
    }
}

struct Artists {
    var id = ""
    var name = ""
    var type = ""
    var externalUrls = ExternalUrls()
    var href = ""
    var uri = ""
    
    init(_ json:JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        type = json["type"].stringValue
        externalUrls = ExternalUrls(json["external_urls"])
        href = json["href"].stringValue
        uri = json["uri"].stringValue
    }
    
    init() {
        
    }
}

struct ExternalIds {
    var upc = ""
    init(_ json: JSON) {
        upc = json["upc"].stringValue
    }
    init() {
    }
}




struct Tracks {
    var total = 0
    var previous = 0
    var limit = 0
    var items = [TrackItem]()
    var next = ""
    var href = ""
    var offset = 0
   // var album = Album()
    
    init(_ json:JSON) {
        total = json["total"].intValue
        previous = json["previous"].intValue
        limit = json["limit"].intValue
        items = json["items"].arrayValue.map{TrackItem($0)}
        next = json["next"].stringValue
        href = json["href"].stringValue
        offset = json["offset"].intValue
       // album = Album(json["album"])
        
    }
    init() {
        
    }
}


struct Track {
    var total = 0
    var previous = 0
    var limit = 0
    var items = [TrackItem]()
    var next = ""
    var href = ""
    var offset = 0
    var album = Album()
    var artists = [Artists]()
    var name = ""
    var uri = ""
    
    init(_ json:JSON) {
        total = json["total"].intValue
        previous = json["previous"].intValue
        limit = json["limit"].intValue
        items = json["items"].arrayValue.map{TrackItem($0)}
        next = json["next"].stringValue
        href = json["href"].stringValue
        offset = json["offset"].intValue
        album = Album(json["album"])
        artists = json["artists"].arrayValue.map{Artists($0)}
        name = json["name"].stringValue
        uri = json["uri"].stringValue
    }
    init() {
        
    }
}

struct TrackItem {
    var trackNumber = 0
    var id = ""
    var previous = 0
    var durationMs = 0
    var explicit = false
    var previewUrl = ""
    var availableMarkets = [Any]()
    var artists = Artists()
    var isLocal = false
    var href = ""
    var discNumber = 1
    var name = ""
    var type = ""
    var externalUrls = ExternalUrls()
    var uri = ""
    var addedAt = ""
    var tracks = Tracks()
    var track = Track()
    
    init(_ json:JSON) {
        trackNumber = json["track_number"].intValue
        id = json["id"].stringValue
        previous = json["previous"].intValue
        durationMs = json["duration_ms"].intValue
        explicit = json["explicit"].boolValue
        previewUrl = json["preview_url"].stringValue
        
        if json["available_markets"].arrayObject?.count != 0 && json["available_markets"].arrayObject?.count != nil {
            availableMarkets = json["available_markets"].arrayObject!
        }
        artists = Artists(json["artists"])
        isLocal = json["is_local"].boolValue
        href = json["href"].stringValue
        discNumber = json["disc_number"].intValue
        name = json["name"].stringValue
        type = json["type"].stringValue
        externalUrls = ExternalUrls(json["external_urls"])
        uri = json["uri"].stringValue
        addedAt = json["added_at"].stringValue
        tracks = Tracks(json["tracks"])
        track = Track(json["track"])
    }
    init() {
        
    }
}

struct Copyrights {
    var text = ""
     var type = ""
    
    init(_ json:JSON) {
        text = json["text"].stringValue
        type = json["type"].stringValue
    }
    init() {
        
    }
}

struct AlbumParser {
    var next = false
    var href = ""
    var offset = 0
    var items = [ItemAlbum]()
    
    init(_ json:JSON) {
        next = json["next"].boolValue
        href = json["href"].stringValue
        offset = json["offset"].intValue
        items = json["items"].arrayValue.map{ItemAlbum($0)}
    }
    
    init() {
        
    }
}

struct ItemAlbum {
    var album = Album()
    var addedAt = ""
    
    init(_ json:JSON) {
        album = Album(json["album"])
        addedAt = json["added_at"].stringValue
    }
    
    init() {
        
    }
}


struct AlbumRootClass {

    var albumGroup: String?
    var albumType: String?
    var artists: [Artists]?
    var availableMarkets: [String]?
    var copyrights: [Copyrights]?
    var externalIds: ExternalIds?
    var externalUrls: ExternalUrls?
    var genres: [Any]?
    var href: String?
    var id: String?
    var itemImages: [ItemImages]?
    var label: String?
    var name: String?
    var popularity: Int?
    var releaseDate: String?
    var releaseDatePrecision: String?
    var totalTracks: Int?
    var tracks: Tracks?
    var type: String?
    var uri: String?
    var albums = [Album]()

    init(_ json: JSON) {
        albumGroup = json["album_group"].stringValue
        albumType = json["album_type"].stringValue
        artists = json["artists"].arrayValue.map { Artists($0) }
        availableMarkets = json["available_markets"].arrayValue.map { $0.stringValue }
        copyrights = json["copyrights"].arrayValue.map { Copyrights($0) }
        externalIds = ExternalIds(json["external_ids"])
        externalUrls = ExternalUrls(json["external_urls"])
        genres = json["genres"].arrayValue.map { $0 }
        href = json["href"].stringValue
        id = json["id"].stringValue
        itemImages = json["images"].arrayValue.map { ItemImages($0) }
        label = json["label"].stringValue
        name = json["name"].stringValue
        popularity = json["popularity"].intValue
        releaseDate = json["release_date"].stringValue
        releaseDatePrecision = json["release_date_precision"].stringValue
        totalTracks = json["total_tracks"].intValue
        tracks = Tracks(json["tracks"])
        type = json["type"].stringValue
        uri = json["uri"].stringValue
        albums = json["items"].arrayValue.map { Album($0) }
    }
    
    init() {
        
    }

}

struct TopTrackRootClass {

    var tracks : [TopTracks]?
    init(_ json: JSON) {
        tracks = json["tracks"].arrayValue.map { TopTracks($0) }
    }

    init() {
    }
    
}


struct TopTracks {
    
    var id: String?
    var isPlayable: Bool?
    var explicit: Bool?
    var album: Album?
    var isLocal: Bool?
    var externalUrls: ExternalUrls?
    var trackNumber: Int?
    var type: String?
    var artists: [Artists]?
    var durationMs: Int?
    var externalIds: ExternalIds?
    var popularity: Int?
    var name: String?
    var previewUrl: String?
    var uri: String?
    var href: String?
    var discNumber: Int?
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        isPlayable = json["is_playable"].boolValue
        explicit = json["explicit"].boolValue
        album = Album(json["album"])
        isLocal = json["is_local"].boolValue
        externalUrls = ExternalUrls(json["external_urls"])
        trackNumber = json["track_number"].intValue
        type = json["type"].stringValue
        artists = json["artists"].arrayValue.map { Artists($0) }
        durationMs = json["duration_ms"].intValue
        externalIds = ExternalIds(json["external_ids"])
        popularity = json["popularity"].intValue
        name = json["name"].stringValue
        previewUrl = json["preview_url"].stringValue
        uri = json["uri"].stringValue
        href = json["href"].stringValue
        discNumber = json["disc_number"].intValue
    }
    
    init() {
        
    }
}
