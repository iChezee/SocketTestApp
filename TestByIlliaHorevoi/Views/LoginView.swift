import SwiftUI
import NetworkLayer

struct LoginView: View {
    @EnvironmentObject var apiService: APIService
    @State var username: String = ""
    @State var password: String = ""
    @State var navigateToMainView: Bool?
    @State var loginUnsucceed: Bool = false
    
    var body: some View {
        VStack {
            Text("Please login")
            
            Group {
                textFields
                loginButton
            }
            .font(.system(size: 20, weight: .medium))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .navigationDestination(item: $navigateToMainView) { value in
            MainView(apiService)
        }
    }
    
    var textFields: some View {
        Group {
            TextField("Username", text: $username)
                .textContentType(.emailAddress)
            TextField("Password", text: $password)
                .onSubmit {
                    authorize()
                }
            
        }
        .padding(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 1)
        }
    }
    
    var loginButton: some View {
        Button {
            authorize()
        } label: {
            Text("Login")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 1)
        }
        .offset(x: loginUnsucceed ? -10 : 0)
    }
    
    func authorize() {
        if !username.isEmpty && !password.isEmpty {
            Task(priority: .background) {
                let result = await apiService.getToken(username: username, password: password)
                await MainActor.run {
                    if result {
                        navigateToMainView = true
                    } else {
                        loginUnsucceed = true
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
                            loginUnsucceed = false
                        }
                    }
                }
            }
        }
    }
}
