//
//  FeedLoadingErrorViewModel.swift
//  CoreLayer
//
//  Created by Omran Khoja on 2/26/22.
//

public struct FeedLoadingErrorViewVM {
    public let errorMessage: String?
    
    static var noError: FeedLoadingErrorViewVM {
        return FeedLoadingErrorViewVM(errorMessage: nil)
    }
    
    
    static func error(message: String) -> FeedLoadingErrorViewVM {
        return FeedLoadingErrorViewVM(errorMessage: message)
    }
}
