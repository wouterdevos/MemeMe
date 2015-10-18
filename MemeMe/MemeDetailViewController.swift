//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Wouter de Vos on 2015/10/18.
//  Copyright (c) 2015 Wouter. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    var meme : Meme!
    @IBOutlet weak var memeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")

        memeImageView.contentMode = .ScaleAspectFit
        memeImageView.image = meme.memedImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false
    }
    
    func cancel() {
        navigationController!.popToRootViewControllerAnimated(true)
    }
}
