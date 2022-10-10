//
//  ViewController.swift
//  RU
//
//  Created by Ehtisham Khalid on 10.10.22.
//

import UIKit

class UsersViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Life Cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromUsers()
        
    }
    
    //MARK: Functions
    private func getDataFromUsers() {
        let url = URL(string: "https://randomuser.me/api/?results=2")!
        URLSession.shared.fetchData(at: url) { result in
            print(result)
        }
    }


}
