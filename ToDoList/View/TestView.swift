//
//  TestView.swift
//  ToDoList
//
//  Created by Andre Frank on 04.01.24.
//

import SwiftUI


struct TestView: View {
    @State var input:String=""
    @State var text:String=""
    @FocusState var isFocused:Bool
    @FocusState var isText:Bool
    @State private var selection:Category = Category.project
    
    var body: some View {
        VStack {
            TextField("Input Text", text: $text)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .focused($isText)
            
            TextEditor(text: $input)
                .scrollDismissesKeyboard(.interactively)
                .focused($isFocused)
                .frame(width:200,height: 400,alignment: .center)
                .border(Color.black)
                .onChange(of: isFocused) { oldValue, newValue in
                    print("TextEditor",oldValue,newValue)
                }
                .onChange(of: isText) { oldValue, newValue in
                    print("TextField",oldValue,newValue)
                }
            
            Picker(selection: $selection) {
                ForEach(Category.allCases,id:\.self){ item in
                    Text(item.rawValue).tag(item.rawValue)
                }
            } label: {
                Text("Type")
                
            }
            .onChange(of: selection) { oldValue, newValue in
                print(selection)
            }
        }
    }
}

