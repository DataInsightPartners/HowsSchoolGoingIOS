//
//  Hows_School_GoingApp.swift
//  Hows School Going
//
//  Created by Erik Gomez on 6/20/24.
//

import SwiftUI

@main
struct Hows_School_GoingApp: App {  
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleUniversalLink(url: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    print("applicationDidBecomeActive")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    print("applicationWillEnterForeground")
                }
        }
    }
    
    func handleUniversalLink(url: URL) {
        // Handle the URL accordingly
        print("Universal Link opened: \(url)")
        // You can add your custom logic here to navigate to a specific view or perform an action
        NotificationCenter.default.post(name: .didReceiveUniversalLink, object: url)
    }
}

extension Notification.Name {
    static let didReceiveUniversalLink = Notification.Name("didReceiveUniversalLink")
    static let webViewLoading = Notification.Name("webViewLoading")
}
