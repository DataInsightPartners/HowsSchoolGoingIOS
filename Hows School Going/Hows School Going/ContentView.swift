//
//  ContentView.swift
//  Hello World
//
//  Created by Erik Gomez on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var webViewModel = WebViewModel(url: URL(string: "https://staging.doral.myeducationdata.com/login")!)
    @State private var isLoading = false
    @State private var loading = true

    var body: some View {
        VStack{
            WebView(viewModel: webViewModel)
                .overlay(LoadingView(isShowing: $isLoading)
                            .onReceive(NotificationCenter.default.publisher(for: .webViewLoading)) { notification in
                                if let loading = notification.object as? Bool {
                                    print("ContentView: webViewLoading: \(loading)")
                                    isLoading = loading
                                }
                            })
                .onReceive(NotificationCenter.default.publisher(for: .didReceiveUniversalLink)) { notification in
                    if let url = notification.object as? URL {
                        print("ContentView: Received universal link: \(url)")
                        webViewModel.url = url
                    } else {
                        print("ContentView: Notification received without URL")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
