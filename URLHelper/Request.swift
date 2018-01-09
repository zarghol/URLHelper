//
//  Request.swift
//  URLHelper
//
//  Created by clement on 05/01/2018.
//  Copyright © 2018 Clement Nonn. All rights reserved.
//

import Foundation

struct SentRequest: Codable {
    var request: Request
    var sentQuery: String?
    var date: Date
}

extension SentRequest: Equatable {
    static func ==(lhs: SentRequest, rhs: SentRequest) -> Bool {
        return lhs.request == rhs.request && lhs.sentQuery == rhs.sentQuery && lhs.date == rhs.date
    }
}

struct Request: Codable {
    let name: String
    let scheme: String
    let path: String
 
    let parameters: [QueryParameter]
    
    var defaultUrl: URL {
        var components = URLComponents(string: "\(scheme)://\(path)")!
        let items = parameters.map { $0.buildItem(with: nil) }
        components.queryItems = items
        return components.url!
    }
    
    func url(handleParameter: (QueryParameter) -> String?) -> URL {
        var components = URLComponents(string: "\(scheme)://\(path)")!
        let items = parameters.map { $0.buildItem(with: $0.isParameterizable ? handleParameter($0) : nil) }
        components.queryItems = items
        return components.url!
    }
}

extension Request: Equatable {
    static func ==(lhs: Request, rhs: Request) -> Bool {
        return lhs.name == rhs.name
            && lhs.scheme == rhs.scheme
            && lhs.path == rhs.path
            && lhs.parameters == rhs.parameters
    }
}

struct QueryParameter: Codable {
    let name: String
    let defaultValue: String?
    var isParameterizable: Bool
    
    func buildItem(with parameter: String?) -> URLQueryItem {
        return URLQueryItem(name: self.name, value: self.isParameterizable && parameter != nil ? parameter : defaultValue)
    }
}

extension QueryParameter: Equatable {
    static func ==(lhs: QueryParameter, rhs: QueryParameter) -> Bool {
        return lhs.name == rhs.name && lhs.defaultValue == rhs.defaultValue && lhs.isParameterizable == rhs.isParameterizable
    }
}

extension QueryParameter: Hashable {
    var hashValue: Int {
        return "\(self.name)\(self.defaultValue ?? "no")".hashValue
    }
}
