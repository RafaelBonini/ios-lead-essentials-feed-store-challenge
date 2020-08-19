//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Rafael Bonini on 8/18/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmFeedStore: FeedStore {
    
    let realm: Realm
    
    public init(fileURLz: URL?) {
        let config = Realm.Configuration(
            fileURL: fileURLz
        )
        
        realm = try! Realm(configuration: config)
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        try! realm.write {
            realm.deleteAll()
            completion(nil)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let realmFeed = feed.map { RealmFeedImage(localFeed: $0) }
        let realmCache = Cache(feedImage: realmFeed, timestamp: timestamp)
        
        try! realm.write {
            realm.add(realmCache)
        }
        
        completion(nil)
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        if let savedCache = realm.objects(Cache.self).first {
            
            if let cacheToLocalFeed = savedCache.localFeed {
                completion(.found(feed: cacheToLocalFeed, timestamp: savedCache.timestamp ?? Date()))
            } else {
                completion(.failure(Error.invalidData))
            }
            
        } else {
            completion(.empty)
        }
    }
}

class Cache: Object {
    let feedImage = RealmSwift.List<RealmFeedImage>()
    @objc dynamic var timestamp: Date?
    
    convenience init(feedImage: [RealmFeedImage], timestamp: Date) {
        self.init()
        self.timestamp = timestamp
        self.feedImage.append(objectsIn: feedImage)
    }
    
    var localFeed: [LocalFeedImage]? {
        var feed = [LocalFeedImage]()
        feedImage.forEach {
            feed.append(
                LocalFeedImage(
                    id: UUID(uuidString: $0.id ?? "") ?? UUID(),
                    description: $0.desc ?? "",
                    location: $0.location ?? "",
                    url: URL(string: $0.url ?? "")!
                )
            )
        }
        return feed
    }
}

class RealmFeedImage: Object {
    @objc dynamic var id: String? = ""
    @objc dynamic var desc: String?
    @objc dynamic var location: String?
    @objc dynamic var url: String? = ""
    
    convenience init(localFeed: LocalFeedImage) {
        self.init()
        id = localFeed.id.uuidString
        desc = localFeed.description
        location = localFeed.location
        url = localFeed.url.absoluteString
    }
}

public enum Error: Swift.Error {
    case invalidData
}
