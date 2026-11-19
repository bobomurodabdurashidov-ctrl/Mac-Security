
import AVFoundation
import Foundation

let devices = AVCaptureDevice.DiscoverySession(
    deviceTypes: [.builtInWideAngleCamera],
    mediaType: .video,
    position: .unspecified
).devices

print("Topilgan kameralar: \(devices.count)")

for camera in devices {
    print("Kamera: \(camera.localizedName)")
}

if let camera = devices.first {
    do {
        let session = AVCaptureSession()
        let input = try AVCaptureDeviceInput(device: camera)

        if session.canAddInput(input) {
            session.addInput(input)
            print("Kamera ulashga tayyor.")
        }
    } catch {
        print("Xatolik: \(error)")
    }
}

