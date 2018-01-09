//
//  FileStore+Request.swift
//  URLHelper
//
//  Created by clement on 05/01/2018.
//  Copyright © 2018 Clement Nonn. All rights reserved.
//

import Foundation

protocol RequestStore {
    var collections: [String: [Request]] { get set }
    var history: [SentRequest] { get set }
}

extension GlobalFileStore: RequestStore {
    var collections: [String : [Request]] {
        get {
            do {
                let data = try Data(contentsOf: collectionUrl)
                let decoder = JSONDecoder()
                return try decoder.decode([String: [Request]].self, from: data)
            } catch {
                print("unable to get from store : \(error)")
                return [:]
            }
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                try data.write(to: collectionUrl)
            } catch {
                print("unable to save to store : \(error)")
            }
        }
    }
    
    var history: [SentRequest] {
        get {
            do {
                let data = try Data(contentsOf: historyUrl)
                let decoder = JSONDecoder()
                return try decoder.decode([SentRequest].self, from: data)
            } catch {
                print("unable to get from store : \(error)")
                return []
            }
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                try data.write(to: historyUrl)
            } catch {
                print("unable to save to store : \(error)")
            }
        }
    }
    
    private var collectionUrl: URL {
        return storeBaseURL.appendingPathComponent("collection.json")
    }
    
    private var historyUrl: URL {
        return storeBaseURL.appendingPathComponent("history.json")
    }
}
