import Foundation
import DescopeKit
import SwiftUI

@MainActor
final class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    static let shared = AuthService()
    private let projectId = "P2rIvbtGcXTcUfT68LGuVqPitlJd"
    
    private init() {
        Descope.setup(projectId: projectId) { config in
            config.baseURL = "https://auth.dev.hitcraft.ai"
        }
        
        Task {
            isAuthenticated = await checkAuthentication()
        }
    }
    
    private func checkAuthentication() async -> Bool {
        return Descope.sessionManager.session != nil
    }
    
    func startAuthFlow() {
        Task { @MainActor in
            let flowUrl = "https://auth.dev.hitcraft.ai/login/\(projectId)?flow=sign-in-v2"
            let flow = DescopeFlow(url: flowUrl)
            let flowVC = DescopeFlowViewController()
            flowVC.delegate = self
            flowVC.start(flow: flow)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(flowVC, animated: true)
            }
        }
    }
    
    func logout() async {
        await Descope.sessionManager.clearSession()
        isAuthenticated = false
    }
}

extension AuthService: DescopeFlowViewControllerDelegate {
    nonisolated func flowViewControllerDidFinish(_ controller: DescopeFlowViewController, response: AuthenticationResponse) {
        Task { @MainActor in
            let session = DescopeSession(from: response)
            Descope.sessionManager.manageSession(session)
            isAuthenticated = true
            controller.dismiss(animated: true)
        }
    }
    
    nonisolated func flowViewControllerDidFail(_ controller: DescopeFlowViewController, error: DescopeError) {
        Task { @MainActor in
            print("Auth Error:", error)
            controller.dismiss(animated: true)
        }
    }
    
    nonisolated func flowViewControllerDidUpdateState(_ controller: DescopeFlowViewController, to: DescopeFlowState, from: DescopeFlowState) {}
    nonisolated func flowViewControllerDidBecomeReady(_ controller: DescopeFlowViewController) {}
    nonisolated func flowViewControllerDidCancel(_ controller: DescopeFlowViewController) {
        Task { @MainActor in
            controller.dismiss(animated: true)
        }
    }
    nonisolated func flowViewControllerShouldShowURL(_ controller: DescopeFlowViewController, url: URL, external: Bool) -> Bool { true }
}
