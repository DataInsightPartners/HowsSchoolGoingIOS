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
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self.viewModel)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        self.webView.customUserAgent = "HowsSchoolGoingIOS/1.0"

        self.webView.allowsBackForwardNavigationGestures = true
        
        self.webView.navigationDelegate = context.coordinator

//        self.webView.load(URLRequest(url: self.viewModel.url))

        return self.webView
    }
    
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        let _ = print("Run updateUIView")
//        let request = URLRequest(url: viewModel.url)
//
//        uiView.load(request)
//    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        let _ = print("Run updateUIView")
        let _ = print(viewModel.url)
        
//        viewModel.isLoading = true
//        let request = URLRequest(url: viewModel.url)


//        uiView.load(request)
    }
    
    func updateView(){
        self.webView.load(URLRequest(url: self.viewModel.url))
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
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            let _ = print("didReceiveServerRedirectForProvisionalNavigation")
            if let url = webView.url, url.absoluteString.starts(with: "https://accounts.google.com") {
                let _ = print("Open Safari")
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

//    class WebViewController: UIViewController, WKUIDelegate {
//        var url: String? {
//            didSet(oldValue) {
//                if self.isViewLoaded {
//                    let myRequest = URLRequest(url: URL(string: url!)!)
//                    webView.load(myRequest)
//                }
//            }
//        }
//        
////        @objc func refreshData() {
//////            self.webView.load(URLRequest(url: self.viewModel.url))
////
////        }
//    }
}


