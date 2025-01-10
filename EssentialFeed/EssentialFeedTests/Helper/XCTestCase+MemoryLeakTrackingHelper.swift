//
//  XCTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by Kholmumin Tursinboev on 1/9/25.
//

import XCTest

extension XCTestCase{
   public func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated! Potential Memory Leak", file: file, line: line)
        }
    }
}



