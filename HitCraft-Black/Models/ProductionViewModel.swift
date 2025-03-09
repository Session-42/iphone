// File: HitCraft-Black/UI/ViewModels/HCProductionsViewModel.swift

import Foundation
import SwiftUI

// Renamed to HCProductionsViewModel to avoid conflict with existing ProductionsViewModel
class HCProductionsViewModel: ObservableObject {
    @Published var productions: [Production] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    private let productionsService = ProductionsService.shared
    
    init() {
        // Listen for refresh notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefreshNotification),
            name: NSNotification.Name("RefreshProductions"),
            object: nil
        )
    }
    
    @objc private func handleRefreshNotification() {
        loadData()
    }
    
    func loadData() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                // Fetch all productions without limiting
                let allProductions = try await productionsService.getRecentProductions()
                
                await MainActor.run {
                    self.productions = allProductions
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                    print("Error loading productions: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func refresh() async {
        do {
            let allProductions = try await productionsService.getRecentProductions()
            
            await MainActor.run {
                self.productions = allProductions
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = error
                print("Error refreshing productions: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadProduction(url: String, fileName: String) {
        Task {
            do {
                _ = try await productionsService.downloadProduction(audioUrl: url, fileName: fileName)
                
                // Show success message
                await MainActor.run {
                    self.alertTitle = "Download Started"
                    self.alertMessage = "The production is being downloaded to your device."
                    self.showAlert = true
                }
            } catch {
                // Show error message
                await MainActor.run {
                    self.alertTitle = "Download Failed"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    func selectProduction(productionId: String) {
        Task {
            do {
                let success = try await productionsService.selectProduction(productionId: productionId)
                
                if success {
                    await MainActor.run {
                        self.alertTitle = "Production Selected"
                        self.alertMessage = "The production has been selected successfully."
                        self.showAlert = true
                    }
                } else {
                    await MainActor.run {
                        self.alertTitle = "Selection Failed"
                        self.alertMessage = "Could not select the production."
                        self.showAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.alertTitle = "Error"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}
