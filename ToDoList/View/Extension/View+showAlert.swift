//
//  View+showAlert.swift
//  ToDoList
//
//  Created by Andre Frank on 02.01.24.
//

import SwiftUI

extension View {
    func showAlert(alertMessage:Binding<String?>,title:String,onAction:@escaping()->Void)->some View {
        self
            .alert(title, isPresented: Binding(get: {
                alertMessage.wrappedValue != nil
            }, set: { newValue in
                if newValue == false {
                    alertMessage.wrappedValue = nil
                }
            }), presenting: alertMessage) { message in
                Button {
                    onAction()
                } label: {
                    Text("Ok")
                }

            } message: { alertMessage in
                Text(alertMessage.wrappedValue ?? "")
            }
    }
}
