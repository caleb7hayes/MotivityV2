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
import WebKit


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
        self.ref.child("Users").child(userID!).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            for event in snapshot.children.allObjects as! [DataSnapshot]{
                for data in event.children.allObjects as! [DataSnapshot]{
                    let post = data.value as! String
                    if !self.postData.contains(post) {
                        self.postData.append(data.value as! String)
                    }
                }
            }
            
        })
    }
    
    func createEvent(eventName: String, desc: String, startTime: String, endTime: String){
        self.ref.child("Users").child(userID!).child("Events").child(eventName).setValue(["Description": desc, "Start Time": startTime, "End Time": endTime])
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
    
    @State var userName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello!")

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
                
                NavigationLink("Input Users Data", destination: CreateView())
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
    
    @State var eventName = ""
    @State var description = ""
    @State var startTime = ""
    @State var endTime = ""
    
    
    var body: some View {
        VStack {
            TextField("Event Name", text: $eventName)
                .padding()
                .background(Color(.secondarySystemBackground))
            
            TextField("Description", text: $description)
                .padding()
                .background(Color(.secondarySystemBackground))
            
            TextField("Start Time", text: $startTime)
                .padding()
                .background(Color(.secondarySystemBackground))
            
            TextField("End Time", text: $endTime)
                .padding()
                .background(Color(.secondarySystemBackground))
            Button(action: {
                viewModel.createEvent(eventName: eventName, desc: description, startTime: startTime, endTime: endTime)
            }, label: {
                Text("Submit Data")
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
