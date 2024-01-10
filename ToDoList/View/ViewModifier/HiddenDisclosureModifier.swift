//
//  HiddenDisclosureModifier.swift
//  ToDoList
//
//  Created by Andre Frank on 31.12.23.
//

import SwiftUI


struct HiddenDisclosureModifier<D:View> : ViewModifier {
   
    let detail:D
    
    init(@ViewBuilder detail:() ->D ) {
        self.detail = detail()
    }
    
    
    func body(content: Content) -> some View {
        ZStack {
            content
            NavigationLink(destination: {
                detail
            }, label: {
                EmptyView()
            })
            .opacity(0)
            
        }
    }
}

extension View {
    func hiddenDisclosure(detail:() -> some View) -> some View {
        self
        .modifier(HiddenDisclosureModifier(detail: detail))
    }
}

