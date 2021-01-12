//
//  CheckmarkShape.swift
//  Permissions
//
//  Created by Chris Eidhof on 05.01.21.
//

import SwiftUI

struct Checkmark: Shape {
    func path(in rect: CGRect) -> Path {
        let thirdX = rect.minX + rect.width/3
        return Path { p in
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: thirdX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
    }
}

struct Checkmark_Preview: PreviewProvider {
    static var previews: some View {
        Checkmark().stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .padding()
            .frame(width: 100, height: 100)
    }
}
