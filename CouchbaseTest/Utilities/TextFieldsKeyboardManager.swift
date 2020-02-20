//
//  TextFieldsKeyboardManager.swift
//  CouchbaseTestTests
//
//  Created by Gabriele Nardi on 10/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit


class TextFieldsKeyboardManager: NSObject, UIGestureRecognizerDelegate {

    // MARK: - private Attributes
    private var textFields: [UITextField] = []
    private var viewsWithoutAutoDismissingGestureRecognizer: [UIView] = []

    weak private var viewController: UIViewController!
    weak private var scrollView: UIScrollView?

    private var info:[AnyHashable : Any]?
    
    
    // MARK: - Attributes
    var offset = CGFloat(60.0)
    var tapGestureRecognizer = UITapGestureRecognizer()
    var viewInitialPosition:CGFloat?
    var scrollInitialBottomConstraint:CGFloat?

    
    // MARK: - Methods
    init(viewController: UIViewController, gestureRecognizerDelegate: UIGestureRecognizerDelegate? = nil, textFields: UITextField..., disableDismissGestureFor: [UIView]? = nil, scrollView: UIScrollView? = nil) {

        self.viewController = viewController
        self.scrollView = scrollView

        super.init()

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1

        if let delegate = gestureRecognizerDelegate {
            tapGestureRecognizer.delegate = delegate
        } else {
            tapGestureRecognizer.delegate = self
        }

        for textField in textFields {
            self.addtextFields(textField: textField)
        }

        if let textFields = disableDismissGestureFor {
            for textField in textFields {
                viewsWithoutAutoDismissingGestureRecognizer.append(textField)
            }
        }

        for textField in textFields {
            viewsWithoutAutoDismissingGestureRecognizer.append(textField)
        }

        self.viewInitialPosition = self.viewController.view.frame.origin.y

        if let scrollView = scrollView {
            self.scrollInitialBottomConstraint = scrollView.constraints.first(where: {$0.firstAttribute == NSLayoutConstraint.Attribute.bottom})?.constant
        }


        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    func addtextFields(textField: UITextField) {

        if !textFields.contains(textField) {
            textFields.append(textField)
        }

        if !viewsWithoutAutoDismissingGestureRecognizer.contains(textField) {
            viewsWithoutAutoDismissingGestureRecognizer.append(textField)
        }
    }


    func addtextFields(textFields: [UITextField]) {

        for textField in textFields {
            self.textFields.append(textField)
        }
    }


    func empty() {
        self.textFields.removeAll()
    }

    @objc
    func dismissKeyboard(sender: UITapGestureRecognizer) {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05){ [weak self] in

            if let self = self, let selectedTextField = self.getSelectedTextField() {
                selectedTextField.resignFirstResponder()
            }
        }
    }


    func getSelectedTextField() -> UITextField? {

        for textField in textFields {

            if textField.isFirstResponder {
                return textField
            }
        }

        return nil
    }


    @objc func keyboardWillShow(notification: NSNotification) {

        self.viewController.view.addGestureRecognizer(tapGestureRecognizer)

        if let selectedTextField = getSelectedTextField(), self.scrollView == nil {

            info = notification.userInfo
            let keyboardFrame: CGRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

            let selectedTextFieldY = viewController.view.convert(CGPoint(x:0, y:0), from: selectedTextField).y

            var keyboardFrameOriginY = keyboardFrame.origin.y

            if #available(iOS 13.0, *) {
                keyboardFrameOriginY = keyboardFrameOriginY - (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0)
            }

            var navigationAndStatusoffset = CGFloat(0)

            if let parent = self.viewController.parent, parent is UINavigationController && !self.viewController.navigationController!.navigationBar.isHidden && !self.viewController.navigationController!.navigationBar.isTranslucent {

                keyboardFrameOriginY -= self.viewController.navigationController!.navigationBar.frame.height
                navigationAndStatusoffset = self.viewController.navigationController!.navigationBar.frame.height
                
                if let statusBarIsHidden = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.isStatusBarHidden) {
                    if (!statusBarIsHidden) {
                        keyboardFrameOriginY -= UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                        navigationAndStatusoffset += UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                    }
                }
            }

            if selectedTextFieldY+selectedTextField.frame.height + offset >= keyboardFrameOriginY {

                let y = selectedTextFieldY+selectedTextField.frame.height - keyboardFrameOriginY

                UIView.animate(withDuration: 0.3, animations: {

                    self.viewController.view.frame.origin.y =  y+self.offset<keyboardFrame.height ? -y - self.offset + navigationAndStatusoffset : -keyboardFrame.height + navigationAndStatusoffset

                })

            }

        } else if let scrollView = self.scrollView {

            info = notification.userInfo
            let keyboardFrame: CGRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

            var keyboardFrameOriginY = keyboardFrame.origin.y

            if #available(iOS 13.0, *) {
                keyboardFrameOriginY = keyboardFrameOriginY - (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0)
            }

            scrollView.constraints.first(where: {$0.firstAttribute == NSLayoutConstraint.Attribute.bottom})?.constant = self.viewController.view.frame.height - keyboardFrameOriginY
        }
    }


    @objc func keyboardWillChange(notification: NSNotification) {

        self.viewController.view.addGestureRecognizer(tapGestureRecognizer)

        if let selectedTextField = getSelectedTextField(), self.scrollView == nil {

            info = notification.userInfo
            let keyboardFrame: CGRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

            let selectedTextFieldY = viewController.view.convert(CGPoint(x:0, y:0), from: selectedTextField).y

            var keyboardFrameOriginY = keyboardFrame.origin.y

            if #available(iOS 13.0, *) {
                keyboardFrameOriginY = keyboardFrameOriginY - (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0)
            }

            var navigationAndStatusoffset = CGFloat(0)

            if let parent = self.viewController.parent, parent is UINavigationController && !self.viewController.navigationController!.navigationBar.isHidden && !self.viewController.navigationController!.navigationBar.isTranslucent {

                keyboardFrameOriginY -= self.viewController.navigationController!.navigationBar.frame.height
                navigationAndStatusoffset = self.viewController.navigationController!.navigationBar.frame.height

                if let statusBarIsHidden = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.isStatusBarHidden) {
                    if (!statusBarIsHidden) {
                        keyboardFrameOriginY -= UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                        navigationAndStatusoffset += UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                    }
                }
            }

            if selectedTextFieldY+selectedTextField.frame.height + offset >= keyboardFrameOriginY {

                let y = selectedTextFieldY+selectedTextField.frame.height - keyboardFrameOriginY

                UIView.animate(withDuration: 0.3, animations: {

                    self.viewController.view.frame.origin.y =  y+self.offset<keyboardFrame.height ? -y - self.offset + navigationAndStatusoffset : -keyboardFrame.height + navigationAndStatusoffset

                })
            }

        } else if let scrollView = self.scrollView {

            info = notification.userInfo
            let keyboardFrame: CGRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

            var keyboardFrameOriginY = keyboardFrame.origin.y

            if #available(iOS 13.0, *) {
                keyboardFrameOriginY = keyboardFrameOriginY - (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0)
            }

            scrollView.constraints.first(where: {$0.firstAttribute == NSLayoutConstraint.Attribute.bottom})?.constant = self.viewController.view.frame.height - keyboardFrameOriginY

            self.viewController.view.setNeedsUpdateConstraints()
            self.viewController.view.updateConstraintsIfNeeded()

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                if let self = self, let selectedTextField = self.getSelectedTextField() {

                    let rect =  scrollView.convert(selectedTextField.frame, from: selectedTextField)
                    let rect2 = CGRect.init(x: rect.origin.x, y: rect.origin.y - 50, width: rect.size.width, height: rect.size.height)

                    scrollView.scrollRectToVisible(rect2, animated: true)
                }
            }
        }
    }


    @objc func keyboardWillHide(notification: NSNotification) {

        info = notification.userInfo
        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: duration, animations: {

            if self.scrollView == nil {

                if let parent = self.viewController.parent, parent is UINavigationController {

                    var originalPosition = self.viewInitialPosition!

                    if !self.viewController.navigationController!.navigationBar.isHidden && !self.viewController.navigationController!.navigationBar.isTranslucent {
                        originalPosition += self.viewController.navigationController!.navigationBar.frame.height
                    }

                    if let statusBarIsHidden = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.isStatusBarHidden) {
                        if (!statusBarIsHidden) && !self.viewController.navigationController!.navigationBar.isTranslucent {
                            originalPosition += UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                        }
                    }

                    self.viewController.view.frame.origin.y = originalPosition

                } else {

                    self.viewController.view.frame.origin.y = self.viewInitialPosition!

                }

            } else if let scrollView = self.scrollView, let scrollInitialBottomConstraint = self.scrollInitialBottomConstraint {
                scrollView.constraints.first(where: {$0.firstAttribute == NSLayoutConstraint.Attribute.bottom})?.constant = scrollInitialBottomConstraint
            }

            self.viewController?.view.endEditing(true)
            self.viewController.view.layoutIfNeeded()

        }, completion: { completed in

            self.info = notification.userInfo
            let keyboardFrame: CGRect = self.info?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

            if keyboardFrame.origin.y == 0 {
                self.viewController?.view.removeGestureRecognizer(self.tapGestureRecognizer)
            }
        })


    }


    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        for view in viewsWithoutAutoDismissingGestureRecognizer {
            if otherGestureRecognizer.view!.isDescendant(of: view) || gestureRecognizer.view!.isDescendant(of: view) {
                return false
            }
        }

        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        for view in viewsWithoutAutoDismissingGestureRecognizer {

            if touch.view!.isDescendant(of: view){
                return false
            }
        }

        return true
    }
}
