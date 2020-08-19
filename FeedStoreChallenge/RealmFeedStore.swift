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
        completion(.empty)
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
