//
//  BlankView.swift
//  ToDoList
//
//  Created by Andre Frank on 30.12.23.
//

import SwiftUI

struct BlankView : View {

    var bgColor: Color

    var body: some View {
        VStack {
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(bgColor)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    BlankView(bgColor: Color.black.opacity(0.7))
}
