//
//  ContentView.swift
//  CapstoneTestingP2
//
//  Created by Tyler on 4/3/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase


class ViewController: ObservableObject {
    var ref: DatabaseReference = Database.database().reference()
    var databaseHandle: DatabaseHandle?
    let auth = Auth.auth()
    var userID = Auth.auth().currentUser?.uid
    
    @Published var signedIn = false
    @Published var postData = [String]()
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String){
        auth.signIn(withEmail: email, password: password) {[weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            self?.signedIn = true
            self?.userID = Auth.auth().currentUser?.uid
        }
    }
    
    func signUp(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            self?.signedIn = true
            self?.userID = Auth.auth().currentUser?.uid
        }
    }
    
    func signOut(){
        try? auth.signOut()
        self.postData = [String]()
        self.signedIn = false
    }
    
    
    func displayPosts(){
        databaseHandle = self.ref.child("users").child(userID!).observe(.childAdded, with: { (snapshot) in
            let post = snapshot.value as? String
            
            if let actualPost = post {
                if !self.postData.contains(actualPost) {
                    self.postData.append(actualPost)
                }
            }
        })
    }
    
    func createPost(post: String){
        self.ref.child("users").child(userID!).childByAutoId().setValue(post)
    }
    
}

struct ContentView: View {
    
    @ObservedObject var appView = ViewController()
    
    @EnvironmentObject var viewModel: ViewController
    
    
    var body: some View {
        NavigationView {
            if viewModel.signedIn {
                AccountView()
            } else {
                SignInView()
            }
        }
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}

struct SignInView: View {
    
    @State var email = ""
    @State var password = ""
    
    @ObservedObject var appView = ViewController()
    
    @EnvironmentObject var viewModel: ViewController
    
    var body: some View {
        VStack {
            VStack {
                TextField("Email Address", text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                Button(action: {
                    
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    
                    viewModel.signIn(email: email, password: password)
                    
                }, label: {
                    Text("Sign In")
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .cornerRadius(8)
                        .background(Color.blue)
                })
                
                NavigationLink("Create account", destination: SignUpView())
                    .padding()


            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Sign In")
    }
}

    
struct SignUpView: View {
    
    @State var email = ""
    @State var password = ""
    
    @ObservedObject var appView = ViewController()
    
    @EnvironmentObject var viewModel: ViewController
    
    var body: some View {
        VStack {
            VStack {
                TextField("Email Address", text: $email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                
                Button(action: {
                    
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    
                    viewModel.signIn(email: email, password: password)
                    
                }, label: {
                    Text("Create Account")
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .cornerRadius(8)
                        .background(Color.blue)
                })

            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Create Account")
    }
}

struct AccountView: View {
    @ObservedObject var appView = ViewController()
    @EnvironmentObject var viewModel: ViewController
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("You are signed in")
                
                Button(action: {
                    viewModel.signOut()
                }, label: {
                    Text("Sign Out")
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .cornerRadius(8)
                        .background(Color.blue)
                        .padding()
                })
                NavigationLink("Create post", destination: CreateView())
                    .padding()
                NavigationLink("View Data", destination: DataView())
                    .padding()
            }
        }
    }
}

struct CreateView: View {
    @ObservedObject var appView = ViewController()
    @EnvironmentObject var viewModel: ViewController
    
    @State var post = ""
    
    var body: some View {
        VStack {
            TextField("Compose", text: $post)
                .padding()
                .background(Color(.secondarySystemBackground))
            
            Button(action: {
                viewModel.createPost(post: post)
            }, label: {
                Text("Create Post")
            })
        }
    }
}

struct DataView: View {
    @ObservedObject var appView = ViewController()
    @EnvironmentObject var viewModel: ViewController
    
    var body: some View {
        NavigationView {
            VStack {
                Text(viewModel.postData.joined(separator: ", "))
            }
            .onAppear {
                viewModel.displayPosts()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
