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
}

class PDFViewController: UIViewController, PDFViewDelegate {
    private var pdfView: PDFView!
    private var closeButton: UIButton!
    private var shareButton: UIButton!
    private var pageLabel: UILabel!
    private var scrollViewDelegate: ScrollViewDelegate?
    
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
        
        setupPDFView()
        setupCloseButton()
        setupShareButton()
        setupPageLabel()
        
        updatePageLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustPDFScale()
    }
    
    private func setupPDFView() {
        view.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false)
        pdfView.autoScales = true
        
        pdfView.delegate = self
        
        scrollViewDelegate = ScrollViewDelegate(updateHandler: { [weak self] in
            self?.updatePageLabel()
        })
        
        if let scrollView = pdfView.subviews.first as? UIScrollView {
            scrollView.delegate = scrollViewDelegate
            scrollView.maximumZoomScale = 4.0
            scrollView.minimumZoomScale = 1.0
        }
    }
    
    private func setupCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton.setTitle("X", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        styleButton(closeButton)
        
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupShareButton() {
        shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        styleButton(shareButton)
        
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func styleButton(_ button: UIButton) {
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        button.tintColor = .darkGray
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func setupPageLabel() {
        pageLabel = UILabel()
        pageLabel.textColor = .darkGray
        pageLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        pageLabel.textAlignment = .center
        pageLabel.layer.cornerRadius = 10
        pageLabel.clipsToBounds = true
        
        view.addSubview(pageLabel)
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            pageLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func adjustPDFScale() {
        guard let page = pdfView.document?.page(at: 0) else { return }
        
        let pdfPageSize = page.bounds(for: .mediaBox)
        let viewSize = pdfView.bounds.size
        
        let widthRatio = viewSize.width / pdfPageSize.width
        
        pdfView.scaleFactor = widthRatio
        pdfView.minScaleFactor = widthRatio
        pdfView.maxScaleFactor = widthRatio * 4
        
        // Ensure the content is positioned correctly after scaling
        pdfView.layoutDocumentView()
    }
    
    private func updatePageLabel() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let document = self.pdfView.document else { return }
            
            let visiblePages = self.pdfView.visiblePages
            guard let firstVisiblePage = visiblePages.first else { return }
            
            let currentPageIndex = document.index(for: firstVisiblePage) + 1
            let totalPages = document.pageCount
            self.pageLabel.text = "\(currentPageIndex) / \(totalPages)"
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func shareTapped() {
        guard let document = pdfView.document else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("shared_document.pdf")
        
        if document.write(to: tempURL) {
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = shareButton
                popover.sourceRect = shareButton.bounds
            }
            
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - PDFViewDelegate
    func pdfViewPageChanged(_ pdfView: PDFView) {
        updatePageLabel()
    }
}

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var updateHandler: () -> Void
    
    init(updateHandler: @escaping () -> Void) {
        self.updateHandler = updateHandler
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHandler()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
