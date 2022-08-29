//
//  ViewController.swift
//  LocalNotification
//
//  Created by Rustem Manafov on 29.08.22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted) {
                print("Permission Denied")
            }
        }
    }
    
    @IBAction func schedule(_ sender: Any) {
        
        notificationCenter.getNotificationSettings { (settings) in
            
            DispatchQueue.main.async {
                
                let title = self.titleTextField.text!
                let message = self.messageTextField.text!
                let date = self.datePicker.date
                
                if(settings.authorizationStatus == .authorized) {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour,.minute], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if(error != nil) {
                            print("Error " + error.debugDescription)
                            return
                        }
                        
                    }
                    let alert = UIAlertController(title: "Notification Scheduled", message: "At " + self.formattedDate(date: date), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    }))
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Enabled Notifications?", message: "To use this feature you must enable notifications in settings", preferredStyle: .alert)
                    let goToSetting = UIAlertAction(title: "Settings", style: .default) { (_) in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        
                        if(UIApplication.shared.canOpenURL(settingsURL)) {
                            UIApplication.shared.open(settingsURL) { (_) in }
                        }
                        
                    }
                    alert.addAction(goToSetting)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
                    }))
                    self.present(alert, animated: true)
                }
            }
            
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
}

