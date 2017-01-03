//
//  ListViewController.swift
//  On The Map
//
//  Created by Ajay Mann on 03/11/16.
//  Copyright © 2016 Ajay Mann. All rights reserved.
//

import UIKit


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
    @IBAction func logoutPressed(_ sender: Any) {
        UdacityClient.sharedInstance().taskForLogout(url: "https://www.udacity.com/api/session") { (success, data, error) in
            if success == true {
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    let alert = UIAlertController(title: "Error", message: "Could Not Log Out. Try Again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "\(studentLocations[indexPath.row].firstName) \(studentLocations[indexPath.row].lastName)"
        return cell
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: (studentLocations[indexPath.row].mediaURL)) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let alertView = UIAlertView(title: "Error Opening URL", message: "Not a VALID URL", delegate: self, cancelButtonTitle: "Cancel")
                alertView.show()
            }
        }

    }
}


