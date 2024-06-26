//
//  ContentView.swift
//  Hello World
//
//  Created by Erik Gomez on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var webViewModel = WebViewModel(url: URL(string: "https://staging.doral.myeducationdata.com/")!)
    
    var body: some View {
        LoadingView(isShowing: self.$webViewModel.isLoading) {
            WebView(viewModel: webViewModel, updatedUrl: webViewModel.url)
                .onReceive(NotificationCenter.default.publisher(for: .didReceiveUniversalLink)) { notification in
                    if let url = notification.object as? URL {
                        print("ContentView: Received universal link: \(url)")
                        webViewModel.url = url
                        // Perform any additional actions you need
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
