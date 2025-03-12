import SwiftUI
import UniformTypeIdentifiers

struct SketchUploadView: View {
    let sketchId: String
    let postProcess: String?
    @State private var isShowingFilePicker = false
    
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
            FilePicker()
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// Simple file picker that doesn't actually do anything with the selected file
struct FilePicker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.image, .pdf, .png, .jpeg]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}