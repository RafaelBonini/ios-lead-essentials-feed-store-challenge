//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Rafael Bonini on 8/18/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class RealmFeedStore: FeedStore {
    
    public init() { }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
