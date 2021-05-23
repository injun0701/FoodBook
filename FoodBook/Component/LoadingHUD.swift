//
//  LoadingHUD.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/23.
//
import UIKit

class LoadingHUD: NSObject {
    private static let sharedInstance = LoadingHUD()
    private var backgroundView: UIView?
    private var popupView: UIImageView?

    class func show() {
        let backgroundView = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        let popupView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 90, height: 90))
        popupView.animationImages = LoadingHUD.getAnimationImageArray()
        popupView.animationDuration = 1.0
        popupView.animationRepeatCount = 0

        if let window = UIApplication.shared.keyWindow {
            window.addSubview(backgroundView)
            window.addSubview(popupView)
            
            
            backgroundView.frame = CGRect(x: 0, y: 0, width: window.frame.maxX, height: window.frame.maxY)
            backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            
            popupView.center = window.center
            popupView.startAnimating()
            
            sharedInstance.backgroundView?.removeFromSuperview()
            sharedInstance.popupView?.removeFromSuperview()
            sharedInstance.backgroundView = backgroundView
            sharedInstance.popupView = popupView
        }
    }

    class func hide() {
        if let popupView = sharedInstance.popupView, let backgroundView = sharedInstance.backgroundView {
            //딜레이
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                popupView.stopAnimating()
                backgroundView.removeFromSuperview()
                popupView.removeFromSuperview()
            }
        }
    }

    private class func getAnimationImageArray() -> [UIImage] {
        var animationArray: [UIImage] = []
        animationArray.append(UIImage(named: "loading00")!)
        animationArray.append(UIImage(named: "loading01")!)
        animationArray.append(UIImage(named: "loading02")!)
        animationArray.append(UIImage(named: "loading03")!)
        animationArray.append(UIImage(named: "loading04")!)
        animationArray.append(UIImage(named: "loading05")!)
        animationArray.append(UIImage(named: "loading06")!)
        animationArray.append(UIImage(named: "loading07")!)
        animationArray.append(UIImage(named: "loading08")!)
        animationArray.append(UIImage(named: "loading09")!)
        animationArray.append(UIImage(named: "loading10")!)
        animationArray.append(UIImage(named: "loading11")!)
        animationArray.append(UIImage(named: "loading12")!)
        animationArray.append(UIImage(named: "loading13")!)
        animationArray.append(UIImage(named: "loading14")!)
        animationArray.append(UIImage(named: "loading15")!)
        animationArray.append(UIImage(named: "loading16")!)
        animationArray.append(UIImage(named: "loading17")!)
        animationArray.append(UIImage(named: "loading18")!)
        animationArray.append(UIImage(named: "loading19")!)
        animationArray.append(UIImage(named: "loading20")!)
        animationArray.append(UIImage(named: "loading21")!)
        animationArray.append(UIImage(named: "loading22")!)
        animationArray.append(UIImage(named: "loading23")!)
        return animationArray
    }
}
