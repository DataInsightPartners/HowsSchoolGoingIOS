//
//  ContentView.swift
//  Hello World
//
//  Created by Erik Gomez on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel(url: URL(string: "https://www.google.com")!)
    
    let pub = NotificationCenter.default
            .publisher(for: NSNotification.Name("com.myeducationdata.Hows-School-Going.opened"))
    
    var body: some View {
        WebView(viewModel: webViewModel)
            // .edgesIgnoringSafeArea(.all) // This makes sure the WebView covers the entire screen
            .onAppear(perform: onLoad)
            .onReceive(pub) { (output) in
                self.onReceive()
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
