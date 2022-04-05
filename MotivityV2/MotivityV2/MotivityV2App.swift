//
//  MotivityV2App.swift
//  MotivityV2
//
//  Created by Tyler on 4/5/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase


@main
struct MotivityV2App: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            let viewModel = ViewController()
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
