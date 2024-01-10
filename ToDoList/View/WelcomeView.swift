//
//  WelcomeView.swift
//  ToDoList
//
//  Created by Andre Frank on 30.12.23.
//

import SwiftUI

struct WelcomeView: View {
    let message:String
    
    var body: some View {
       Text(message)
            .font(.system(.headline,design: .rounded))
            .bold()
    }
}

#Preview {
    WelcomeView(message:"Mit + neue Aufgabe anlegen...")
}
