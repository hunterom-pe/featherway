import AVFoundation
import SwiftUI
import UIKit

struct BirdCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var stage = Stage.checking

    let onSave: (URL) -> Void
    @State private var course = ""
    @State private var hole: Int?
    @State private var birdName = ""
    @State private var saving = false
    @State private var saveFailed = false

    private enum Stage {
        case checking, camera, denied, restricted, unavailable, failed
        case review(UIImage)
    }

    var body: some View {
        Group {
            switch stage {
            case .checking:
                ProgressView("Opening camera…")
                    .task { await checkCamera() }
            case .camera:
                BirdCamera(onCancel: { dismiss() }) { image in
                    stage = image.map(Stage.review) ?? .failed
                }
                .ignoresSafeArea()
            case .review(let image):
                VStack(spacing: 0) {
                    HStack {
                        Image(.heronMark)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 29, height: 42)
                            .accessibilityHidden(true)
                        Text("Featherway")
                            .font(.system(.title, design: .serif))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(HomeView.Palette.ivory)
                    .background(HomeView.Palette.forest)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(.rect(cornerRadius: 16))
                                .accessibilityLabel("Your captured photo")
                            Text("Your bird photo")
                                .font(.system(.largeTitle, design: .serif))
                                .accessibilityAddTraits(.isHeader)
                            TextField("Bird name (optional)", text: $birdName)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                                .disabled(saving)
                            TextField("Golf course (optional)", text: $course)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                                .disabled(saving)
                            holePicker
                        }
                        .padding()
                    }
                    Button(saving ? "Saving…" : "Save Sighting") {
                        guard !saving else { return }
                        saving = true
                        Task {
                            do {
                                let url = try await Self.save(image, name: birdName, location: SightingLocation(course: course, hole: hole))
                                onSave(url)
                                dismiss()
                            } catch {
                                saving = false
                                saveFailed = true
                            }
                        }
                    }
                    .disabled(saving)
                        .foregroundStyle(HomeView.Palette.ivory)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.top)
                    Button("Discard Photo", role: .cancel) { dismiss() }
                        .disabled(saving)
                        .padding(.top, 20)
                        .padding(.bottom)
                }
                .interactiveDismissDisabled(saving)
                .alert("Couldn’t save the sighting", isPresented: $saveFailed) {
                    Button("OK") {}
                } message: {
                    Text("Check the available storage on this iPhone and try again. Your photo is still here.")
                }
            case .denied:
                notice("Camera access is off", "Turn on Camera in Featherway’s Settings to take a bird photo.", settings: true)
            case .restricted:
                notice("Camera access is restricted", "This iPhone’s restrictions prevent Featherway from using the camera.")
            case .unavailable:
                notice("Camera unavailable", "Open Featherway on an iPhone with an available camera.")
            case .failed:
                notice("Photo unavailable", "Return home and try taking another photo.")
            }
        }
        .foregroundStyle(HomeView.Palette.forest)
        .tint(HomeView.Palette.forest)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HomeView.Palette.ivory.ignoresSafeArea())
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, case .denied = stage,
               AVCaptureDevice.authorizationStatus(for: .video) != .denied {
                stage = .checking
            }
        }
    }

    private var holePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hole number (optional)")
                .font(.system(.headline, design: .serif))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 6)], spacing: 6) {
                ForEach(1...18, id: \.self) { number in
                    Button {
                        hole = hole == number ? nil : number
                    } label: {
                        Text(number.formatted())
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(hole == number ? HomeView.Palette.ivory : HomeView.Palette.forest)
                            .background(hole == number ? HomeView.Palette.copper : HomeView.Palette.stone,
                                        in: .rect(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hole \(number)")
                    .accessibilityAddTraits(hole == number ? .isSelected : [])
                }
            }
        }
        .disabled(saving)
    }

    nonisolated private static func save(_ image: UIImage, name: String, location: SightingLocation?) async throws -> URL {
        guard let jpeg = image.jpegData(compressionQuality: 0.9) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return try SightingFiles.local.save(jpeg, name: name, location: location)
    }

    @MainActor
    private func checkCamera() async {
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                stage = .unavailable
                return
            }
            _ = await AVCaptureDevice.requestAccess(for: .video)
        }
        guard !Task.isCancelled else { return }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: stage = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .unavailable
        case .denied: stage = .denied
        case .restricted: stage = .restricted
        default: stage = .unavailable
        }
    }

    private func notice(_ title: String, _ message: String, settings: Bool = false) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: "camera")
        } description: {
            Text(message)
        } actions: {
            if settings, let url = URL(string: UIApplication.openSettingsURLString) {
                Button("Open Settings") { openURL(url) }
            }
            Button("Back to Home") { dismiss() }
        }
    }
}

private struct BirdCamera: UIViewControllerRepresentable {
    let onCancel: () -> Void
    let onPhoto: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let camera: BirdCamera

        init(_ camera: BirdCamera) { self.camera = camera }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            camera.onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            camera.onPhoto(info[.originalImage] as? UIImage)
        }
    }
}
