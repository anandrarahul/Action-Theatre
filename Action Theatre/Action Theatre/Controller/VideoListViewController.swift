//
//  VideoListViewController.swift
//  Action Theatre
//
//  Created by Rahul Anand on 08/10/21.
//

import UIKit
import Firebase

class VideoNavigationController: UINavigationController {}

class VideoListViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var refreshButton: UIButton!
    @IBOutlet weak private var errorLabel: UILabel!
    private let restApi = RestAPI()
    var videoDetailsList: [VideoDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.title = "VIDEOS"
        self.tableView.isHidden = true
        self.activityIndicator.isHidden = false
        self.errorLabel.isHidden = true
        self.refreshButton.isHidden = true
        self.activityIndicator.startAnimating()
        self.tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        self.performNetworkCall()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.signOutButtonTapped))
    }
    
    private func performNetworkCall() {
        
        if let endpoint = self.restApi.getUrlForVideos() {
            VideoListNetworkService.fetchVideoList(endpoint: endpoint) { videoDetails, error in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    if let err = error {
                        self.errorLabel.text = "An error occured during network call \(err).\nPlease Refresh."
                        self.errorLabel.isHidden = false
                        self.refreshButton.isHidden = false
                    } else {
                        self.tableView.isHidden = false
                        self.videoDetailsList.append(contentsOf: videoDetails ?? [])
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            self.errorLabel.text = "Invalid Endpoint.\nPlease Refresh."
            self.errorLabel.isHidden = false
            self.refreshButton.isHidden = false
        }
        
    }
    
    @IBAction private func refreshButtonTapped(_ sender: UIButton) {
        self.tableView.isHidden = true
        self.activityIndicator.isHidden = false
        self.errorLabel.isHidden = true
        self.refreshButton.isHidden = true
        self.activityIndicator.startAnimating()
        self.performNetworkCall()
    }
    
    @objc private func signOutButtonTapped() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.dismiss(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

}

extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoDetailsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.updateCell(self.videoDetailsList[indexPath.row].thumb, self.videoDetailsList[indexPath.row].title, self.videoDetailsList[indexPath.row].description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let videoDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoDetailsViewController") as! VideoDetailsViewController
        let relatedVideos = self.videoDetailsList.filter {
            return $0.id != self.videoDetailsList[indexPath.row].id
        }
        videoDetailsViewController.dataSource = VideoDetailsViewControllerDataSource(videoDetails: self.videoDetailsList[indexPath.row], recommended: relatedVideos)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(videoDetailsViewController, animated: true)
    }
    
}
