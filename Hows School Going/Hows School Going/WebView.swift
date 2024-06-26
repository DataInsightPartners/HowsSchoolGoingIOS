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
    let webView = WKWebView()
    var updatedUrl: URL?
    
    fileprivate let defaultURL:URL = URL(string: "https://staging.doral.myeducationdata.com/")!
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self.viewModel)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.customUserAgent = "HowsSchoolGoingIOS/1.0"

        webView.allowsBackForwardNavigationGestures = true
        
        webView.navigationDelegate = context.coordinator

        webView.scrollView.isScrollEnabled = true

//        let _ = print("Run makeUIView: url: \(self.viewModel.url)")
//        webView.load(URLRequest(url: self.viewModel.url))

        return webView
    }
    
    fileprivate func load(url:URL?, in webView:WKWebView) {
        
        if let url = url {
            print("load url....: \(url)")
            let req = URLRequest(url: url)
            webView.load(req)
        } else {
            print("load default url case...")
            let req = URLRequest(url: defaultURL)
            webView.load(req)
        }
        
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let _ = print("Run updateUIView: url: \(String(describing: updatedUrl))")
        load(url: updatedUrl, in: uiView)
        
//        viewModel.isLoading = true
//        let request = URLRequest(url: self.newURL)
//        
//        uiView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let viewModel: WebViewModel
        
        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Done loading")
            self.viewModel.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Begin loading")
            self.viewModel.isLoading = true
        }
        
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            let _ = print("didReceiveServerRedirectForProvisionalNavigation")
            if let url = webView.url, url.absoluteString.starts(with: "https://accounts.google.com") {
                let _ = print("Open Safari")
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

}


