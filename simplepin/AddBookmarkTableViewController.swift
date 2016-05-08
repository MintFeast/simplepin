//
//  AddBookmarkTableViewController.swift
//  simplepin
//
//  Created by Mathias Lindholm on 9.4.2016.
//  Copyright © 2016 Mathias Lindholm. All rights reserved.
//

import UIKit

class AddBookmarkTableViewController: UITableViewController, UITextViewDelegate {
    var addBookmarkTask: NSURLSessionTask?
    var toreadValue = "no"
    var sharedValue = "yes"
    var passedBookmark: BookmarkItem?
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet var privateSwitch: UISwitch!
    @IBOutlet var toreadSwitch: UISwitch!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var tagsTextField: UITextField!
    @IBOutlet var addButton: UIBarButtonItem!

    @IBAction func toreadSwitchPressed(sender: AnyObject) {
        if (toreadSwitch.on == true) {
            toreadValue = "yes"
        } else if (toreadSwitch.on == false) {
            toreadValue = "no"
        }
    }

    @IBAction func privateSwitchPressed(sender: AnyObject) {
        if (privateSwitch.on == true) {
            sharedValue = "no"
        } else if (privateSwitch.on == false) {
            sharedValue = "yes"
        }

    }

    @IBAction func addButtonPressed(sender: AnyObject) {

        guard let urlText = urlTextField.text,
            let url = NSURL(string: urlText),
            let title = titleTextField.text,
            let description = descriptionTextView.text,
            let tags = tagsTextField.text?.componentsSeparatedByString(" ") else {
                return
        }

        if urlText.isEmpty || title.isEmpty {
            self.alertError("Please Provide URL and Title", message: nil)
            return
        }

        if Reachability.isConnectedToNetwork() == false {
            alertError("Couldn't Add Bookmark", message: "Try again when you're back online.")
        } else {
            self.addBookmarkTask = Network.addBookmark(url, title: title, description: description, tags: tags, shared: sharedValue, toread: toreadValue ) { resultCode in
                if resultCode == "done" {
                    NSNotificationCenter.defaultCenter().postNotificationName("bookmarkAdded", object: nil)
                    self.performSegueWithIdentifier("closeAddBookmarkModal", sender: self)
                } else {
                    self.alertErrorWithReachability("Something Went Wrong", message: resultCode)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.delegate = self

        if passedBookmark != nil {
            urlTextField.text = passedBookmark?.link.absoluteString
            titleTextField.text = passedBookmark?.title
            descriptionTextView.text = passedBookmark?.description
            tagsTextField.text = passedBookmark?.tags.joinWithSeparator(" ")
            addButton.title = "Save"
            //TODO: huutomerkit pois
            sharedValue = passedBookmark!.shared
            toreadValue = passedBookmark!.toread
        }

        if (defaults.boolForKey("privateByDefault") == true) || sharedValue == "no" {
            privateSwitch.on = true
            sharedValue = "no"
        }

        if toreadValue == "yes" {
            toreadSwitch.on = true
            toreadValue = "yes"
        }

        if !descriptionTextView.text.isEmpty {
            descriptionTextView.backgroundColor = UIColor.whiteColor()
        }

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        addBookmarkTask?.cancel()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            guard let tags = defaults.stringArrayForKey("userTags") else { return nil }
            let title = "Your tags: "
            return title + tags.joinWithSeparator(", ")
        } else {
            return nil
        }
    }

    func textViewDidChange(textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.backgroundColor = nil
        } else {
            descriptionTextView.backgroundColor = UIColor.whiteColor()
        }
    }

}
