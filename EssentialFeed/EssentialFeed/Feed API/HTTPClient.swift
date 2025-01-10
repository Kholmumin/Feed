//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Kholmumin Tursinboev on 1/7/25.
//

import Foundation

public enum HTTPClientResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
