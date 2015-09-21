//
//  ViewController.swift
//  MemeMe
//
//  Created by Wouter de Vos on 2015/09/15.
//  Copyright (c) 2015 Wouter. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    let topText = "TOP"
    let bottomText = "BOTTOM"
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3]
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.enabled = false
        
        topTextField.text = topText
        bottomTextField.text = bottomText
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.tag = 0
        bottomTextField.tag = 1
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func shareMeme(sender : AnyObject) {
        let meme = saveMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [meme.targetImage], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(sender : AnyObject) {
        topTextField.text = topText
        bottomTextField.text = bottomText
        imageView.image = nil
    }
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePickerController = getImagePickerController(.PhotoLibrary)
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePickerController = getImagePickerController(.Camera)
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func getImagePickerController(sourceType : UIImagePickerControllerSourceType) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        return imagePickerController
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFill
            imageView.image = pickedImage
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let text = textField.text {
            if text == topText || text == bottomText {
                textField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = textField.text {
            if text == "" {
                textField.text = textField.tag == 0 ? topText : bottomText
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text == "" {
            textField.text = textField.tag == 0 ? topText : bottomText
        }
        textField.resignFirstResponder()
        return false
    }
    
    func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification : NSNotification) {
        if !topTextField.editing {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification : NSNotification) {
        if !topTextField.editing {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func saveMemedImage() -> Meme {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, sourceImage: memedImage, targetImage: memedImage)
        
        return meme
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide the navigation bar and toolbar
        navigationController?.navigationBarHidden = true
        navigationController?.setToolbarHidden(true, animated: false)
        
        // Render the screen view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the navigation bar and toolbar
        navigationController?.navigationBarHidden = false
        navigationController?.setToolbarHidden(false, animated: false)
        
        return memedImage
    }
}

