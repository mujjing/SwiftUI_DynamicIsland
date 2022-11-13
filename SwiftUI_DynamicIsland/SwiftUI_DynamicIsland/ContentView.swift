//
//  ContentView.swift
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        VStack {
            Text("In App Push Notifications\nUsing Dynamic Island")
                .font(.title)
                .fontWeight(.semibold)
                .lineSpacing(12)
                .kerning(1.1)
                .multilineTextAlignment(.center)
                .onAppear(perform: authorizeNotifications)
        }
    }
    
    func authorizeNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
