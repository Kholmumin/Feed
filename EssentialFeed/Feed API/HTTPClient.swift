//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Kholmumin Tursinboev on 1/7/25.
//

import Foundation

public protocol HTTPClient{
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
