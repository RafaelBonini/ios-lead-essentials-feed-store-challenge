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
    
    private let realm: Realm
    
    public init() throws {
        realm = try Realm()
    }
    
    private enum Error: Swift.Error {
        case invalidData
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do {
            try realm.write {
                realm.delete(realm.objects(Cache.self))
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let realmFeed = feed.map { RealmFeedImage(localFeed: $0) }
            let realmCache = Cache(feedImage: realmFeed, timestamp: timestamp)
            
            try realm.write {
                realm.delete(realm.objects(Cache.self))
                realm.add(realmCache)
            }
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        if let savedCache = realm.objects(Cache.self).first {
            
                completion(.found(feed: savedCache.localFeed, timestamp: savedCache.timestamp))
        } else {
            completion(.empty)
        }
    }
}

class Cache: Object {
    private let feedImage = RealmSwift.List<RealmFeedImage>()
    @objc dynamic var timestamp: Date = Date()
    
    convenience init(feedImage: [RealmFeedImage], timestamp: Date) {
        self.init()
        self.timestamp = timestamp
        self.feedImage.append(objectsIn: feedImage)
    }
    
    internal var localFeed: [LocalFeedImage] {
        var resultFeedImage = [LocalFeedImage]()
        
        feedImage.forEach {
            if let id = $0.id, let uuid = UUID(uuidString: id),
                let stringUrl = $0.url, let url = URL(string: stringUrl) {
                resultFeedImage.append(
                    LocalFeedImage(
                        id: uuid,
                        description: $0.desc,
                        location: $0.location,
                        url: url
                    )
                )
            }
        }
        
        return resultFeedImage
    }
}

class RealmFeedImage: Object {
    @objc internal dynamic var id: String? = ""
    @objc internal dynamic var desc: String?
    @objc internal dynamic var location: String?
    @objc internal dynamic var url: String? = ""
    
    convenience init(localFeed: LocalFeedImage) {
        self.init()
        id = localFeed.id.uuidString
        desc = localFeed.description
        location = localFeed.location
        url = localFeed.url.absoluteString
    }
}
