
import SwiftUI
import AVFoundation
import AppKit

// MARK: - Kamera boshqaruvi

final class CameraManager: ObservableObject {
    @Published var status = "Kamera ishga tushirilmagan"

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var isConfigured = false

    func startCamera() {
        let permission = AVCaptureDevice.authorizationStatus(for: .video)

        switch permission {
        case .authorized:
            configureAndStart()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureAndStart()
                    } else {
                        self.status = "Kamera ruxsati berilmadi"
                    }
                }
            }

        case .denied:
            status = "Ruxsat yo'q. Sozlamalardan kameraga ruxsat bering."

        case .restricted:
            status = "Kameradan foydalanish cheklangan"

        @unknown default:
            status = "Noma'lum ruxsat holati"
        }
    }

    func stopCamera() {
    sessionQueue.async {
        if self.session.isRunning {
            self.session.stopRunning()
        }

        DispatchQueue.main.async {
            self.status = "Kamera o'chirildi"
            print("KAMERA TO'XTATILDI")
        }
    }
}

    private func configureAndStart() {
        sessionQueue.async {
            do {
                if !self.isConfigured {
                    guard let camera = AVCaptureDevice.default(for: .video) else {
                        DispatchQueue.main.async {
                            self.status = "Kamera topilmadi"
                        }
                        return
                    }

                    let input = try AVCaptureDeviceInput(device: camera)

                    self.session.beginConfiguration()
                    self.session.sessionPreset = .high

                    guard self.session.canAddInput(input) else {
                        self.session.commitConfiguration()
                        DispatchQueue.main.async {
                            self.status = "Kamerani ulab bo'lmadi"
                        }
                        return
                    }

                    self.session.addInput(input)
                    self.session.commitConfiguration()
                    self.isConfigured = true
                }

                if !self.session.isRunning {
                    self.session.startRunning()
                }

                DispatchQueue.main.async {
                    self.status = "Kamera ishlayapti"
                    print("KAMERA ISHGA TUSHDI")
                }

            } catch {
                DispatchQueue.main.async {
                    self.status = "Xatolik: \(error.localizedDescription)"
                    print(error)
                }
            }
        }
    }
}

// MARK: - Jonli tasvir oynasi

final class CameraPreviewNSView: NSView {
    private let previewLayer: AVCaptureVideoPreviewLayer

    init(session: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame: .zero)

        wantsLayer = true
        previewLayer.videoGravity = .resizeAspect
        layer?.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) ishlatilmaydi")
    }

    override func layout() {
        super.layout()
        previewLayer.frame = bounds
    }
}

struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> CameraPreviewNSView {
        CameraPreviewNSView(session: session)
    }

    func updateNSView(_ nsView: CameraPreviewNSView, context: Context) {}
}

// MARK: - Asosiy oyna

struct ContentView: View {
    @StateObject private var camera = CameraManager()

    var body: some View {
        VStack(spacing: 15) {
            Text("MAC SECURITY")
                .font(.largeTitle)
                .bold()

            CameraPreview(session: camera.session)
                .frame(minWidth: 500, minHeight: 300)
                .background(Color.black)

            Text(camera.status)
                .foregroundColor(.secondary)

            Button("Kamerani ishga tushirish") {
                camera.startCamera()
            }
            .controlSize(.large)

            Button("Kamerani o'chirish") {
            camera.stopCamera()
}
.controlSize(.large)
.tint(.red)
        }
        .padding()
        .frame(width: 650, height: 500)
    }
}

// MARK: - Dastur

@main
struct CameraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
