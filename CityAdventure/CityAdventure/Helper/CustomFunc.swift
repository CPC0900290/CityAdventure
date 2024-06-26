//
//  CustomFunc.swift
//  CityAdventure
//
//  Created by Pin Chen on 2024/4/30.
//

import Foundation
import UIKit

class CustomFunc {
    /// 提示框
    /// - Parameters:
    ///   - title: 提示框標題
    ///   - message: 提示訊息
    ///   - vc: 要在哪一個 UIViewController 上呈現
    ///   - actionHandler: 按下按鈕後要執行的動作，沒有的話，就填 nil
    class func customAlert(title: String, message: String, viewController: UIViewController, actionHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "關閉", style: .default) { _ in
            actionHandler?()
        }
        alertController.addAction(closeAction)
        viewController.present(alertController, animated: true)
    }
}
