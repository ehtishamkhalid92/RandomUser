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
    var usersData = [Result]()
    
    //MARK: View Life Cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromUsers()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    //MARK: Actions
    @IBAction func updateUserButtonPressed(_ sender: UIButton) {
        self.usersData.removeAll()
        getDataFromUsers()
    }
    
    //MARK: Functions
    private func getDataFromUsers() {
        let url = URL(string: "https://randomuser.me/api/?page=3&results=10&seed=abc")!
        URLSession.shared.fetchData(at: url) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let data):
                    print("Users found successfully")
                    self.usersData = data.results
                    print(self.usersData)
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

}
extension UsersViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersData.count
     }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UsersTableViewCell
        guard indexPath.row < usersData.count else {return cell}
        let instance = usersData[indexPath.row]
        cell.nameLabel.text = "\(instance.name.first) \(instance.name.last)"
        cell.emailLabel.text = "\(instance.email)"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
