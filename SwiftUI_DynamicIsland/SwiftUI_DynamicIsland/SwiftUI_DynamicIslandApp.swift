//
//  SwiftUI_DynamicIslandApp.swift
//

import SwiftUI
import UserNotifications

@main
struct SwiftUI_DynamicIslandApp: App {
    //MARK: Linking App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    //MARK: All Notifications
    @State var notifications: [NotificationValue] = []
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    GeometryReader { proxy in
                        let size = proxy.size
                        ForEach(notifications) { notification in
                            NotificationPreView(size: size, value: notification, notifications: $notifications)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                    }
                    .ignoresSafeArea()
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NOTIFY"))) { output in
                    if let content = output.userInfo?["content"] as? UNNotificationContent {
                        // MARK: Creating New Notification
                        let newNotification = NotificationValue(content: content)
                        notifications.append(newNotification)
                    }
                }
        }
    }
}

struct NotificationPreView: View {
    var size: CGSize
    // MARK: for demo purpose
    var value: NotificationValue
    @Binding var notifications: [NotificationValue]
    var body: some View {
        HStack {
            //MARK: UI
            // NOTE: App Icon File Can Be Accessed with this string "AppIcon60x60"
            if let image = UIImage(named: "AppIcon60x60") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(value.content.title)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(value.content.body)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .padding(.horizontal, 12)
        .padding(.vertical, 18)
        //MARK: Adding some blur
        .blur(radius: value.showNotification ? 0 : 30)
        .opacity(value.showNotification ? 1 : 0)
        .scaleEffect(value.showNotification ? 1 : 0.5, anchor: .top)
        //dynamin island size
        .frame(width: value.showNotification ? size.width - 22 : 126, height: value.showNotification ? nil : 37.33)
        .background {
            // Radius = 126/2 => 63
            RoundedRectangle(cornerRadius: value.showNotification ? 50 : 63, style: .continuous)
                .fill(.black)
        }
        .clipped()
        .offset(y: 11)
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: value.showNotification)
        // MARK: Auto Closed
        .onChange(of: value.showNotification, perform: { newValue in
            if newValue && notifications.indices.contains(index) {
                
                //MARK: Adding Multiple Notifications as overlay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if notifications.indices.contains(index + 1) {
                        notifications[index + 1].showNotification = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        notifications[index].showNotification = false
                        
                        //MARK: Safe Check goes here
                        //before removing item from the array
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if notifications.indices.contains(index + 1) {
                                notifications[index + 1].showNotification = true
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            notifications.remove(at: index)
                        }
                    }
                }
            }
        })
        .onAppear {
            // MARK: Animating When A New Notification is Added
            if index == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    notifications[index].showNotification = true
                }
            }
        }
    }
    var index: Int {
        return notifications.firstIndex { CValue in
            CValue.id == value.id
        } ?? 0
    }
}

//MARK: App Delegate to Listen for In App Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if UIApplication.shared.haveDynamicIsland {
            //MARK: Observing Notifications
            NotificationCenter.default.post(name: NSNotification.Name("NOTIFY"), object: nil, userInfo: ["content" : notification.request.content])
            return [.sound]
        } else {
            return [.sound, .banner]
        }
    }
}

extension UIApplication {
    var haveDynamicIsland: Bool {
        return deviceName == "iPhone 14 Pro" || deviceName == "iPhone 14 Pro Max"
    }
    
    var deviceName: String {
        return UIDevice.current.name
    }
}
