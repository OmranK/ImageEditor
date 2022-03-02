//
//  SceneDelegate.swift
//  App
//
//  Created by Omran Khoja on 2/26/22.
//

import UIKit
import CoreLayer
import UILayer
import CoreData
 
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let getURL = URL(string: "https://eulerity-hackathon.appspot.com/image")!
        let postURL = URL(string: "https://eulerity-hackathon.appspot.com/upload")!
        
        // Networking Components (Downloads)
        let session = URLSession(configuration: .ephemeral)
        let getClient = URLSessionHTTPGetClient(session: session)
        let remoteFeedLoader = RemoteFeedLoader(url: getURL, client: getClient)
        let remoteImageLoader = RemoteImageLoader(client: getClient)
        let remoteEndpointLoader = RemoteEndpointLoader(url: postURL, client: getClient)
        
        // Image Rendering Components
        let context = CIContext()
        let filterSupplier = CoreImageFilterSupplier(context: context)
        let imageEnhancer = CoreImageImageEnhancer(context: context)
        
        // Networking Components (Uploads)
        let postClient = URLSessionHTTPPostClient()
        let imageUploader = RemoteImageUploader(client: postClient)
        
        // Cacheing Components (Store and Retrieve on no connection)
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        let localStore = try! CoreDataStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalImageLoader(store: localStore)
        
        // Bundle Loader (Demo items in case of no connection and no cache)
        let bundledFeedLoader = BundledFeedLoader()
        let bundledImageLoader = BundledImageLoader()
        
        
//      MARK: - 3 Way composition (Fetches from api if there is connectivity, caches it for when there isn't and uses a bundled demo feed for when there is no connectivity and the cache is empty or expired)

        let navController = UINavigationController()

        let feedViewController = FeedUIComposer.feedControllerComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderWithFallbackComposite(
                    primary: FeedLoaderCacheDecorator(
                        decoratee: remoteFeedLoader,
                        cache: localFeedLoader),
                    fallback: localFeedLoader),
                fallback: bundledFeedLoader),
            imageLoader: ImageLoaderWithFallbackComposite(
                primary: ImageLoaderWithFallbackComposite(
                    primary: bundledImageLoader,
                    fallback: localImageLoader),
                fallback: ImageLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader)),
            routing: { imageData, url in
                let imageController = FeedUIComposer.imageEditorControllerComposedWith (
                    imageUploader: imageUploader,
                    endpointLoader: remoteEndpointLoader,
                    filterSupplier: filterSupplier,
                    imageEnhancer: imageEnhancer,
                    for: imageData, at: url)
                navController.pushViewController(imageController, animated: true)
            })
        navController.addChild(feedViewController)
        window?.rootViewController = navController
//
        
        // MARK: - 2 way composition. Uses the api if there is connectivity or uses cached images otherwise.
        
//        let navController = UINavigationController()
//
//        let feedViewController = FeedUIComposer.feedControllerComposedWith(
//            feedLoader: FeedLoaderWithFallbackComposite(
//                primary:  FeedLoaderCacheDecorator(
//                    decoratee: remoteFeedLoader,
//                    cache: localFeedLoader),
//                fallback: localFeedLoader),
//            imageLoader: FeedImageDataLoaderWithFallbackComposite(
//                primary: localImageLoader,
//                fallback: ImageLoaderCacheDecorator(
//                    decoratee: remoteImageLoader,
//                    cache: localImageLoader)),
//            routing: { imageData, url in
//                let imageController = FeedUIComposer.imageEditorControllerComposedWith (
//                    imageUploader: imageUploader,
//                    endpointLoader: remoteEndpointLoader,
//                    filterSupplier: filterSupplier,
//                    imageEnhancer: imageEnhancer,
//                    for: imageData, at: url)
//                navController.pushViewController(imageController, animated: true)
//            })
//        navController.addChild(feedViewController)
//        window?.rootViewController = navController
//
        
        
        // MARK: - 2 way composition. Uses the api if there is connectivity or uses bundled images otherwise.
        
//        let navController = UINavigationController()
//
//        let feedViewController = FeedUIComposer.feedControllerComposedWith(
//            feedLoader: FeedLoaderWithFallbackComposite(
//                primary: remoteFeedLoader,
//                fallback: bundledFeedLoader),
//            imageLoader: FeedImageDataLoaderWithFallbackComposite(
//                primary: bundledImageLoader,
//                fallback: remoteImageLoader),
//            routing: { imageData, url in
//                let imageController = FeedUIComposer.imageEditorControllerComposedWith (
//                    imageUploader: imageUploader,
//                    endpointLoader: remoteEndpointLoader,
//                    filterSupplier: filterSupplier,
//                    imageEnhancer: imageEnhancer,
//                    for: imageData, at: url)
//                navController.pushViewController(imageController, animated: true)
//            })
//        navController.addChild(feedViewController)
//        window?.rootViewController = navController
        
        
        
//       MARK: - See How Bundle Loader Works (For no connectivity + no cache)
        
//        let navController = UINavigationController()
//        let feedViewController = FeedUIComposer.feedControllerComposedWith(
//            feedLoader: bundledFeedLoader,
//            imageLoader: bundledImageLoader,
//            routing: { imageData, url in
//                let imageController = FeedUIComposer.imageEditorControllerComposedWith (
//                    imageUploader: imageUploader,
//                    endpointLoader: remoteEndpointLoader,
//                    filterSupplier: filterSupplier,
//                    imageEnhancer: imageEnhancer,
//                    for: imageData, at: url)
//                navController.pushViewController(imageController, animated: true)
//            })
//        navController.addChild(feedViewController)
//        window?.rootViewController = navController
        
    }


}

