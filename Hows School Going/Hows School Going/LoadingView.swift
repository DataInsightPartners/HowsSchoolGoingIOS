//
//  LoadingView.swift
//  Hows School Going
//
//  Created by Erik Gomez on 6/25/24.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    HStack {
                        Text("Loading...")
                            .foregroundColor(Color.gray)
                        ActivityIndicatorView(isAnimating: .constant(true), style: .large)
                    }
                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .cornerRadius(20)
                    Spacer()
                }

                Spacer()
            }
            .disabled(self.isShowing)
        }
        .opacity(self.isShowing ? 1 : 0)
    }
}

#Preview {
    LoadingView(isShowing: .constant(true))
}
