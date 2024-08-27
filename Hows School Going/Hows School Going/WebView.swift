//
//  WebView.swift
//  Hows School Going
//
//  Created by Erik Gomez on 6/20/24.
//


import SwiftUI
import WebKit
import PDFKit

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
            if let url = navigationAction.request.url, url.pathExtension.lowercased() == "pdf" {
                decisionHandler(.cancel)
                downloadAndPresentPDF(url: url)
            } else {
                decisionHandler(.allow)
            }
        }
        
        func downloadAndPresentPDF(url: URL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        if let pdfDocument = PDFDocument(data: data) {
                            let pdfViewController = PDFViewController(document: pdfDocument)
                            
                            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                                rootViewController.present(pdfViewController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }.resume()
        }
    }
    
    class PDFViewController: UIViewController {
        private var pdfView: PDFView!
        private var closeButton: UIButton!
        
        init(document: PDFDocument) {
            super.init(nibName: nil, bundle: nil)
            pdfView = PDFView()
            pdfView.document = document
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.addSubview(pdfView)
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pdfView.topAnchor.constraint(equalTo: view.topAnchor),
                pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            closeButton = UIButton(type: .system)
            closeButton.setTitle("X", for: .normal)
            closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

            // Style the button with transparent background
            closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.3) // 30% opaque white
            closeButton.setTitleColor(.darkGray, for: .normal)
            closeButton.layer.cornerRadius = 22 // Half of the button's width/height for circular shape
            closeButton.clipsToBounds = true
            
            // Add a subtle border to make the button visible on light backgrounds
            closeButton.layer.borderWidth = 1
            closeButton.layer.borderColor = UIColor.gray.cgColor
            
            view.addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                closeButton.widthAnchor.constraint(equalToConstant: 44),
                closeButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        @objc private func closeTapped() {
            dismiss(animated: true, completion: nil)
        }
    }
}

