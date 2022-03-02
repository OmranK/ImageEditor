//
//  FeedViewVM.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/26/22.
//

import CoreLayer

public struct FeedViewVM {
    internal init(feed: [ImageData]) {
        self.feed = feed
    }
    
    public let feed: [ImageData]
}
