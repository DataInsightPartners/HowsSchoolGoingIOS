//
//  ContentView.swift
//  Hello World
//
//  Created by Erik Gomez on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel(url: URL(string: "https://www.google.com")!)
    @State private var url: URL?
    
    var body: some View {
        WebView(viewModel: webViewModel)
            // .edgesIgnoringSafeArea(.all) // This makes sure the WebView covers the entire screen
            .onAppear(perform: onLoad)
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
    
    func onLoad(){
        let _ = print("on load")
        webViewModel.url = URL(string: "https://staging.doral.myeducationdata.com/")!
    }
    
    func onReceive() {
        let _ = print("on receive")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
