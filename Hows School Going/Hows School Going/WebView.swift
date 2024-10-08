//
//  WebView.swift
//  Hows School Going
//
//  Created by Erik Gomez on 6/20/24.
//


import SwiftUI
import WebKit
import PDFKit
import UniformTypeIdentifiers
import QuickLook


struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    let webView = WKWebView()
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.customUserAgent = "HowsSchoolGoingIOS/0.1"
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.load(URLRequest(url: self.viewModel.url))

        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: viewModel.url))
    }    

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ webView: WebView) {
            self.parent = webView
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Begin loading")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .webViewLoading, object: true)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Done loading")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .webViewLoading, object: false)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Loading Failed")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .webViewLoading, object: false)
            }
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            let _ = print("didReceiveServerRedirectForProvisionalNavigation")
            
            if let url = webView.url, url.absoluteString.starts(with: "https://accounts.google.com") {
                let _ = print("Open Safari")
                UIApplication.shared.open(url, options: [:])
                webView.stopLoading()
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let allowedDomains = ["myeducationdata.com", "howsschoolgoing.com"]
            
            // Check if this is a main frame navigation (user clicked a link)
            if navigationAction.targetFrame?.isMainFrame == true {
                if allowedDomains.contains(where: { url.host?.contains($0) == true }) {
                    // URL is from allowed domains, handle it within the app
                    let fileExtension = url.pathExtension.lowercased()
                    if fileExtension == "pdf" {
                        decisionHandler(.cancel)
                        downloadAndPresentPDF(url: url)
                    } else if ["docx", "doc", "xlsx", "xls"].contains(fileExtension) {
                        decisionHandler(.cancel)
                        downloadAndPresentQuickLook(url: url)
                    } else {
                        decisionHandler(.allow)
                    }
                } else {
                    // URL is external, open in Safari
                    decisionHandler(.cancel)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                // This is not a main frame navigation, likely an asset or resource
                decisionHandler(.allow)
            }
        }
        
        func downloadAndPresentPDF(url: URL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        if let pdfDocument = PDFDocument(data: data) {
                            let pdfViewController = PDFViewController(document: pdfDocument)
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootViewController = window.rootViewController {
                                rootViewController.present(pdfViewController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }.resume()
        }
        
        func downloadAndPresentQuickLook(url: URL) {
             URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
                 guard let tempURL = tempURL else { return }
                 
                 let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                 let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                 
                 do {
                     if FileManager.default.fileExists(atPath: destinationURL.path) {
                         try FileManager.default.removeItem(at: destinationURL)
                     }
                     try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                     
                     DispatchQueue.main.async {
                         let quickLookViewController = QuickLookViewController(documentURL: destinationURL)
                         self.presentViewController(quickLookViewController)
                     }
                 } catch {
                     print("Error handling QuickLook file: \(error)")
                 }
             }.resume()
         }
         
        private func presentViewController(_ viewController: UIViewController) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(viewController, animated: true, completion: nil)
            }
        }
    }
}
