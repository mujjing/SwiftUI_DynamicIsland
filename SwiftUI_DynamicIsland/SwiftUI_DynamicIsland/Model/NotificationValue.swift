//
//  NotificationValue.swift
//

import SwiftUI
import UserNotifications

struct NotificationValue: Identifiable {
    var id: String = UUID().uuidString
    var content: UNNotificationContent
    var dateCreated: Date = Date()
    var showNotification: Bool = false
}
