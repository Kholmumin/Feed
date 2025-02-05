//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Kholmumin Tursinboev on 1/20/25.
//

import Foundation

func anyNSError() -> NSError{
    return NSError(domain: "Test", code: 1)
}

func anyURL() -> URL{
    return URL(string: "https://any-given.com")!
}
