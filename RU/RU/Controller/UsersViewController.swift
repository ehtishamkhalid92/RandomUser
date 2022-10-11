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
        getDataFromUsers(numberOfItem: 20)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    //MARK: Actions
    @IBAction func updateUserButtonPressed(_ sender: UIButton) {
        print("Stack count", self.usersData.count)
        if self.usersData.count == 20 {
            Toast.show(message: "Stack is full please delete one", controller: self)
        }else {
            getDataFromUsers(numberOfItem: 20)
        }
        
    }
    
    //MARK: Functions
    private func getDataFromUsers(numberOfItem: Int) {
        let url = URL(string: "https://randomuser.me/api/?results=\(numberOfItem)")!
        URLSession.shared.fetchData(at: url) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let data):
                    print("Users found successfully")
                    for items in data.results {
                        self.usersData.append(items)
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    Toast.show(message: "\(error.localizedDescription)", controller: self)
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
        cell.profileImage.loadImageUsingCache(withUrl: instance.picture.thumbnail)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
        let instance = usersData[indexPath.row]
        vc.user = instance
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
