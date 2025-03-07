import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        if authService.isAuthenticated {
            MainView()
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthService.shared)
            .environmentObject(ThemeManager.shared)
    }
}
