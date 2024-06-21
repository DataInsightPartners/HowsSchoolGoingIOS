//
//  WebView.swift
//  Hows School Going
//
//  Created by Erik Gomez on 6/20/24.
//


import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    func makeUIView(context: Context) -> WKWebView {
        let wkwebView = WKWebView()
//        let request = URLRequest(url: viewModel.url)
        wkwebView.customUserAgent = "MyApp/1.0"
//        wkwebView.load(request)
        
//        NotificationCenter.default.addObserver(self,/* selector: #selector(self.urlLoaded(notification:)), name: Notification.Name("com.app.ios.application.url.opened"), object: nil)*/
        
        wkwebView.navigationDelegate = context.coordinator
        
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let _ = print("Run updateUIView")
        let request = URLRequest(url: viewModel.url)

        uiView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Done loading")
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            let _ = print("didReceiveServerRedirectForProvisionalNavigation")
            if let url = webView.url, url.absoluteString.starts(with: "https://accounts.google.com") {
                let _ = print("Open Safari")
                UIApplication.shared.open(url, options: [:])
            }
        }

//        @objc func urlLoaded(notification: Notification) {
//          let url = notification.userInfo!["url"]! as! URL
////            self.load(url: url)
//          self.WebView(URLRequest(url: url))
//        }
        
    }
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
    
//    NotificationCenter.default.addObserver(self, selector: #selector(self.urlLoaded(notification:)), name: Notification.Name("com.app.ios.application.url.opened"), object: nil)
//
//    @objc func urlLoaded(notification: Notification) {
//      let url = notification.userInfo!["url"]! as! URL
//      self.webView.load(URLRequest(url: url))
//    }
}


