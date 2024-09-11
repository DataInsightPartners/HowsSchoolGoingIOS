//
//  DocXViewController.swift
//  Hows School Going
//
//  Created by Erik Gomez on 9/11/24.
//

import SwiftUI
import UIKit
import QuickLook

class DocXViewController: UIViewController, QLPreviewControllerDataSource {
    private var documentURL: URL
    private var previewController: QLPreviewController!
    private var closeButton: UIButton!
    private var shareButton: UIButton!

    init(documentURL: URL) {
        self.documentURL = documentURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPreviewController()
        setupCloseButton()
        setupShareButton()
    }

    private func setupPreviewController() {
        previewController = QLPreviewController()
        previewController.dataSource = self
        addChild(previewController)
        view.addSubview(previewController.view)
        previewController.view.frame = view.bounds
        previewController.didMove(toParent: self)
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

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func shareTapped() {
        let activityViewController = UIActivityViewController(activityItems: [documentURL], applicationActivities: nil)
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = self.shareButton
            popover.sourceRect = self.shareButton.bounds
        }
        
        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: - QLPreviewControllerDataSource

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURL as QLPreviewItem
    }
}

// SwiftUI wrapper for DocXViewController
struct DocXViewControllerWrapper: UIViewControllerRepresentable {
    let documentURL: URL

    func makeUIViewController(context: Context) -> DocXViewController {
        return DocXViewController(documentURL: documentURL)
    }

    func updateUIViewController(_ uiViewController: DocXViewController, context: Context) {
        // Update the view controller if needed
    }
}
