//
//  TitleModifier.swift
//  HoneyMoon
//
//  Created by Sandesh on 27/02/21.
//

import SwiftUI

struct TitleModifier: ViewModifier {
   
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.pink)
    }
    
}

 
