//
//  DetailViewController.swift
//  RU
//
//  Created by Ehtisham Khalid on 10.10.22.
//

import UIKit

class DetailViewController: UIViewController {

    //MARK: Properties.
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var user : Result?
    
    //MARK: View Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        displayDataOnViews()
        UISetup()
    }
    
    //MARK:- Functions
    private func displayDataOnViews(){
        self.ageLbl.text = "\(user?.dob.age ?? 0 ) years old"
        self.emailLbl.text = user?.email
        self.nameLbl.text = "\(user?.name.first ?? "") \(user?.name.last ?? "")"
        self.phoneLbl.text = user?.phone
        let address = "\(user?.location.street.name ?? "") \(user?.location.street.number ?? 0), \(user!.location.postcode) \(user?.location.city ?? "") \(user?.location.country ?? "")"
        self.addressLbl.text = address
        self.imageView.loadImageUsingCache(withUrl: user?.picture.large ?? "")
    }
    
    private func UISetup() {
        imageView.withRoundedAndBorder()
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
