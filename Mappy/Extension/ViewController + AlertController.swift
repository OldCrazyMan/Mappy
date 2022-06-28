//
//  ViewController + AlertController.swift
//  Mappy
//
//  Created by Тim Akhm on 27.06.2022.
//


import Foundation
import UIKit

extension UIViewController {
    
    func presentSearchAlertConroller(withTitle title: String?,
                                     message: String?,
                                     style: UIAlertController.Style,
                                     completionHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
       
        alertController.addTextField {someCitiesAddress in
            let address = ["Калининград, Театральная 2", "Ульяновск, Авиастроителей 10"]
            someCitiesAddress.placeholder = address.randomElement()
        }
        
        let search = UIAlertAction(title: "Найти", style: .default) { action in
            let textField = alertController.textFields?.first
            guard let cityName = textField?.text else {return}
            if cityName != "" {
                let city = cityName.capitalizingFirstLetter()
                completionHandler(city)
            } else {
                self.alertOkCancel(title: "", message: "Введите корректный адрес") {
                    self.dismiss(animated: true)
                }
            }
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(search)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertOkCancel(title: String, message: String?, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func alert(title: String, message: String?, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
             
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
    }
}
