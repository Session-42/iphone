import SwiftUI
import UniformTypeIdentifiers

struct SketchUploadRequestView: View {
    let sketchId: String
    let sketchUploadRequestId: String
    let postProcess: String?
    @State private var isShowingFilePicker = false
    @State private var isUploading = false
    @State private var error: Error?
    @State private var showError = false
    
    var body: some View {
        Button(action: {
            isShowingFilePicker = true
        }) {
            HStack {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(HitCraftColors.accent)
                
                VStack(alignment: .leading) {
                    Text("Upload Sketch")
                        .font(.headline)
                        .foregroundColor(HitCraftColors.text)
                    
                    Text("Tap to select a file")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                    if let process = postProcess {
                        Text("Will \(process.replacingOccurrences(of: "_", with: " "))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $isShowingFilePicker) {
            FilePicker(
                onFileSelected: { url in
                    Task {
                        await uploadFile(url)
                    }
                }
            )
            .edgesIgnoringSafeArea(.bottom)
        }
        .alert("Upload Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    private func uploadFile(_ url: URL) async {
        isUploading = true
        do {
            // let response = try await SketchService.shared.uploadSketch(
            //     fileURL: url,
            //     postProcess: postProcess
            // )
            let mock_sketch_id = "67bf0e2206841ceacce8baa3"
            
            // Send a message to the chat with the upload complete
            await ChatPersistenceManager.shared.sendMessage(
                content: .sketchUploadComplete(
                    // sketchId: response.sketchId,
                    sketchId: mock_sketch_id,
                    sketchUploadRequestId: sketchUploadRequestId
                )
            )
        } catch {
            self.error = error
            self.showError = true
        }
        isUploading = false
    }
}

struct FilePicker: UIViewControllerRepresentable {
    let onFileSelected: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.image, .pdf, .png, .jpeg]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePicker
        
        init(_ parent: FilePicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onFileSelected(url)
            controller.dismiss(animated: true)
        }
    }
}