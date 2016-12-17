//
//  ListViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 03/11/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit

var studentLocationListView = [StudentLocation]()

class ListViewController: UIViewController, UITableViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        studentLocationListView.removeAll()
    }
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return studentLocationListView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "\(studentLocationListView[indexPath.row].firstName) \(studentLocationListView[indexPath.row].lastName)"
        return cell
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: (studentLocationListView[indexPath.row].mediaURL)) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let alertView = UIAlertView(title: "Error Opening URL", message: "Not a VALID URL", delegate: self, cancelButtonTitle: "Cancel")
                alertView.show()
            }
        }

    }
}


