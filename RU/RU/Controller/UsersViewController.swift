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
        let url = URL(string: "https://randomuser.me/api/?results=20")!
        getDataFromUsers(url: url)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    //MARK: Functions
    private func getDataFromUsers(url: URL) {
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

//MARK: Table View 
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure?", message: "You want to delete the user?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (yes) in
                // remove the item from the data model
                self.usersData.remove(at: indexPath.row)
                // delete the table view row
                tableView.deleteRows(at: [indexPath], with: .fade)
                let url = URL(string: "https://randomuser.me/api/")!
                self.getDataFromUsers(url: url)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}
