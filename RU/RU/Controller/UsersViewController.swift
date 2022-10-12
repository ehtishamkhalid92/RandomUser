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
    let sourceUrl = URL(string: "https://randomuser.me/api/?results=20")!
    
    //MARK: View Life Cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        applyNetworking()
        setupViews()
    }
    
    //MARK: Functions
    ///Intially fetch data from local storage
    ///If result does is n il or less than 20
    ///Apply Api call and fetch data from api call
    ///Through proper error if something is wrong.
    private func applyNetworking(){
        LocalDatabase.instance.fetchResultFromLocalStorage { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let data):
                    if data.results.count == 0 && data.results.count < 20 {
                        self.getDataFromApi(url: self.sourceUrl)
                    }else{
                        for items in data.results {
                            self.usersData.append(items)
                        }
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    Toast.show(message: error.localizedDescription, controller: self)
                }
            }
        }
    }
    
    /// Actual api call that get JSON response.
    /// Store all the incomming data into the local storage
    /// display the data on the list view.
    private func getDataFromApi(url: URL) {
        URLSession.shared.fetchData(at: url) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let data):
                    for items in data.results {
                        LocalDatabase.instance.saveDataInLocalStorage(instance: items)
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
    
    /// This function includes all the UI Settings
    private func setupViews() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Loading")
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    //MARK: Actions
    /// This is UIRefreshControl action
    /// after 1 sec delay remove all the previous data from Local database
    /// Apply Api call for fetching new data.
    @objc func refresh(_ sender: UIRefreshControl) {
        print("Start refresh")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.refreshControl?.endRefreshing()
            self.usersData.removeAll()
            LocalDatabase.instance.resetAllRecords { response in
                switch response {
                case .success:
                    self.getDataFromApi(url: self.sourceUrl)
                case .failure(let error):
                    Toast.show(message: error.localizedDescription, controller: self)
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
        //Downloading and cache the image for faster loading.
        cell.profileImage.loadImageUsingCache(withUrl: instance.picture.thumbnail)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Sending Data to the detail view after selecting the table view row.
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
                let uuid = self.usersData[indexPath.row].login.uuid
                LocalDatabase.instance.deleteSingleObject(userId: uuid) { response in
                    if response == true {
                        self.usersData.remove(at: indexPath.row)
                        // delete the table view row
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        // Fetch single data and store into the database.
                        let url = URL(string: "https://randomuser.me/api/")!
                        self.getDataFromApi(url: url)
                    }else {
                        Toast.show(message: "Something went wrong", controller: self)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    // This function is used to load more item by scrolling down
    // I was confused weather to load more item and delete previous or keep loading more items in the list
    // So I added a function that load more item by pull to refresh and delete previous.
    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.getDataFromUsers(url: sourceUrl)
        }
    }
    */
    
}
