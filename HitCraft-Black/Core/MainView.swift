import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        VStack {
            Text("Welcome to Hitcraft!")
                .font(.largeTitle)
            
            Button("Logout") {
                Task {
                    await authService.logout()
                }
            }
            .padding()
            .background(HitCraftColors.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 20)
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthService.shared)
    }
}
