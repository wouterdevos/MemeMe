//
//  ViewController.swift
//  MemeMe
//
//  Created by Wouter de Vos on 2015/09/15.
//  Copyright (c) 2015 Wouter. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    let topText = "TOP"
    let bottomText = "BOTTOM"
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName : -3]
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.enabled = false
        
        // Set the default text.
        topTextField.text = topText
        bottomTextField.text = bottomText
        
        // Set the default text attributes.
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // Center the text.
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        topTextField.tag = 0
        bottomTextField.tag = 1
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func shareMeme(sender : AnyObject) {
        // Generate the memed image.
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        // Save the meme after the activity view controller has completed.
        activityViewController.completionWithItemsHandler = {
            (activity : String!, completed : Bool, items : [AnyObject]!, error : NSError!) -> Void in
            if completed {
                self.saveMeme()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(sender : AnyObject) {
        // Reset the meme editor.
        topTextField.text = topText
        bottomTextField.text = bottomText
        imageView.image = nil
        shareButton.enabled = false
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
        // Get an image picker controller with the provided source type.
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        return imagePickerController
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        // If and image is picked set the image view and enable the share button.
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Clear the text field of the default text.
        if let text = textField.text {
            if text == topText || text == bottomText {
                textField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Add the default text if the text field is blank.
        setDefaultText(textField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Add the default text if the text field is blank.
        setDefaultText(textField)
        textField.resignFirstResponder()
        return false
    }
    
    func setDefaultText(textField: UITextField) {
        if let text = textField.text {
            if text == "" {
                textField.text = topTextField.editing ? topText : bottomText
            }
        }
    }
    
    func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification : NSNotification) {
        // Shift the view up when the bottom text field starts editing.
        if bottomTextField.editing {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification : NSNotification) {
        // Shift the view down when the bottom text field ends editing.
        if bottomTextField.editing {
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
    
    func saveMeme() -> Meme {
        // Save a Meme object.
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imageView.image!, memedImage: memedImage)
        
        return meme
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide the navigation bar and toolbar.
        navigationBar.hidden = true
        toolbar.hidden = true
        
        // Render the screen view to an image.
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the navigation bar and toolbar.
        navigationBar.hidden = false
        toolbar.hidden = false
        
        return memedImage
    }
}
