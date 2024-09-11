//
//  ScrollViewDelegate.swift
//  Hows School Going
//
//  Created by Erik Gomez on 9/11/24.
//

import SwiftUI

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
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // This method is called when zooming ends. You can add custom behavior here if needed.
    }
}
