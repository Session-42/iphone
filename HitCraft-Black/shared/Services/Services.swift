// File: HitCraft-Black/Services/Services.swift

import Foundation
import DescopeKit
import UIKit  // Add this import to fix the UIApplication and UIWindowScene errors

@MainActor
final class HCServices {
    // MARK: - Shared Instance
    static let shared = HCServices()
    
    // MARK: - Services
    let auth: HCAuthService
    let chatService: ChatService
    
    // MARK: - Initialization
    private init() {
        auth = HCAuthService.shared
        chatService = ChatService.shared
    }
}

// MARK: - Auth Service
@MainActor
final class HCAuthService: ObservableObject {
    // MARK: - Properties
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    static let shared = HCAuthService()
    private let projectId = Constants.Auth.descopeProjectId
    
    // MARK: - Initialization
    private init() {
        Descope.setup(projectId: projectId) { config in
            config.baseURL = HCNetwork.Endpoints.authBaseURL
        }
        
        Task {
            isAuthenticated = await checkAuthentication()
        }
    }
    
    // MARK: - Public Methods
    private func checkAuthentication() async -> Bool {
        return Descope.sessionManager.session != nil
    }
    
    func startAuthFlow() {
        Task { @MainActor in
            let flowUrl = "\(HCNetwork.Endpoints.authBaseURL)/login/\(projectId)?flow=sign-in-v2"
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

// MARK: - Auth Delegate Extension
extension HCAuthService: DescopeFlowViewControllerDelegate {
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
