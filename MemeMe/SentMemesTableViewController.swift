//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Wouter de Vos on 2015/10/18.
//  Copyright (c) 2015 Wouter. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    var memes : [Meme] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewMeme:")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        if memes.count == 0 {
            addNewMeme(navigationItem.rightBarButtonItem!)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemesTableViewCell")!
        
        let meme = memes[indexPath.item]
        cell.imageView!.image = meme.memedImage
        cell.textLabel!.text = meme.topText + "..." + meme.bottomText
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        
        detailController.meme = memes[indexPath.item]
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    func addNewMeme(sender : UIBarButtonItem) {
        let editorController = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        presentViewController(editorController, animated: true, completion: nil)
    }
}
