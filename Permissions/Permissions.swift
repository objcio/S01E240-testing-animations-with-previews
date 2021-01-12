//
//  Permissions.swift
//  Narrated
//
//  Created by Chris Eidhof on 10.12.20.
//

import AppKit
import AVFoundation

// To remove the app from privacy settings:
// `tccutil reset CATEGORY BUNDLEID`, e.g.:
/*
tccutil reset Camera io.objc.Narrated
tccutil reset Microphone io.objc.Narrated
tccutil reset ScreenCapture io.objc.Narrated
defaults delete io.objc.Narrated
 */
//
// To reset user defaults:
//
// `defaults delete io.objc.Narrated`
// https://apple.stackexchange.com/questions/339363/how-can-i-remove-applications-from-security-privacy

extension CGDirectDisplayID {
    static var main: Self { CGMainDisplayID() }
}

final class Permissions: ObservableObject {
    enum Device: Hashable {
        case screen
        case microphone
        case camera
    }
    
    @Published var camera: AVAuthorizationStatus = .notDetermined
    @Published var microphone: AVAuthorizationStatus = .notDetermined
    @Published var screen: AVAuthorizationStatus = .notDetermined
    
    @Published var currentDevice = Device.camera
    var status: [Device:AVAuthorizationStatus] {
        [.camera: camera, .microphone: microphone, .screen: screen]
    }
    
    init() {
        reloadPermissions()
    }
    
    func reloadPermissions() {
        camera = AVCaptureDevice.authorizationStatus(for: .video)
        microphone = AVCaptureDevice.authorizationStatus(for: .audio)
        screen = canRecordScreen() ? .authorized : (screenPermissionsRequested ? .denied : .notDetermined)
        currentDevice = .camera
        if camera == .authorized {
            currentDevice = .microphone
            if microphone == .authorized {
                currentDevice = .screen
            }
        }       
    }
    
    var s: CGDisplayStream?
    
    private let permissionsRequestedKey = "\(Bundle.main.bundleIdentifier!).requested"
    var screenPermissionsRequested: Bool {
        get {
            UserDefaults.standard.bool(forKey: permissionsRequestedKey)
        }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue, forKey: permissionsRequestedKey)
        }
    }
    
    func authorize(_ type: Device) {
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.reloadPermissions()
                }
            }
        case .microphone:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.reloadPermissions()
                }
            }
        case .screen:
            if screenPermissionsRequested {
                openSystemPreferences(.screen)
            } else {
                screenPermissionsRequested = true
                let screenInput = AVCaptureScreenInput(displayID: .main)!
                let session = AVCaptureSession()
                session.addInput(screenInput)
                let output = AVCaptureVideoDataOutput()
                session.addOutput(output)
                session.startRunning()
                session.stopRunning()
                reloadPermissions()
            }
        }
    }
    
    func openSystemPreferences(_ type: Device) {
        let path: String
        switch type {
        case .camera: path = "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera"
        case .microphone: path = "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
        case .screen: path = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        }
        NSWorkspace.shared.open(URL(string: path)!)
    }
    
    var allAuthorized: Bool {
        camera == .authorized && microphone == .authorized && screen == .authorized
    }
    
    subscript(device device: Device) -> AVAuthorizationStatus {
        switch device {
        case .screen:
            return screen
        case .microphone:
            return microphone
        case .camera:
            return camera
        }
    }
    
    static let global = Permissions()
}
