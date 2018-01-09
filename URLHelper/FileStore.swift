//
//  FileStore.swift
//  URLHelper
//
//  Created by clement on 05/01/2018.
//  Copyright © 2018 Clement Nonn. All rights reserved.
//

import Foundation

protocol FileStore {
    var storeBaseURL: URL { get }
    var fileManager: FileManager { get }
}

extension FileStore {
    var fileManager: FileManager {
        return FileManager.default
    }
}

class GlobalFileStore: FileStore {
    static var `default`: GlobalFileStore = {
        do {
            return try GlobalFileStore()
        } catch {
            print("error at initializing default GlobalFileStore...")
            fatalError()
        }
    }()
    
    let storeBaseURL: URL
    
    init(baseURL: URL) throws {
        storeBaseURL = baseURL        
    }
    
    convenience init() throws {
        try self.init(baseURL: try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
    }
}
