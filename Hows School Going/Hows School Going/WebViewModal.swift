//
//  WebViewModal.swift
//  Hows School Going
//
//  Created by Erik Gomez on 6/20/24.
//

import SwiftUI
import Combine

class WebViewModel: ObservableObject {
    @Published var url: URL
    @Published var isLoading: Bool = true
    
    init(url: URL) {
        self.url = url
    }
}

