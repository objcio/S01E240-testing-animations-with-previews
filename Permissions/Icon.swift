//
//  Icon.swift
//  Permissions
//
//  Created by Chris Eidhof on 05.01.21.
//

import SwiftUI
import AVFoundation

extension Permissions.Device {
    var icon: Image {
        switch self {
        case .camera: return Image(systemName: "camera")
        case .microphone: return Image(systemName: "mic")
        case .screen: return Image(systemName: "rectangle.on.rectangle")
        }
    }
}

struct Icon: View {
    var device: Permissions.Device
    var isAuthorized: Bool
    
    var body: some View {
        device.icon
            .modifier(GreenCheckmark(enabled: isAuthorized))
    }
}

struct GreenCheckmark: AnimatableModifier {
    var enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(checkmark, alignment: .topTrailing)
    }
    
    var checkmark: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 16, height: 16)
            .overlay(Checkmark()
                .trim(from: 0, to: enabled ? 1 : 0)
                .stroke(lineWidth: 2)
                .animation(Animation.easeInOut(duration: 1).delay(1))

                .foregroundColor(.white)
                        .padding(5)
            )
            .animation(nil)
            .scaleEffect(enabled ? 1 : 0)
            .animation(.easeInOut(duration: 1))
            .offset(x: 8, y: -8)
    }
}

fileprivate struct InteractiveIcon: View {
    @State var isAuthorized: Bool = true
    var body: some View {
        Icon(device: .camera, isAuthorized: isAuthorized)
            .font(.largeTitle)
            .padding()
            .onTapGesture {
                isAuthorized.toggle()
            }
    }
}

struct Icon_Preview: PreviewProvider {
    static var previews: some View {
        InteractiveIcon()
    }
}
