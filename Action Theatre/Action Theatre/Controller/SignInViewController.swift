//
//  SignInViewController.swift
//  Action Theatre
//
//  Created by Rahul Anand on 08/10/21.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController {

    @IBAction private func signInButtonTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Authentication Error \(error.localizedDescription)")
                } else {
                    // User is signed in
                    if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                        GIDSignIn.sharedInstance.restorePreviousSignIn { userID, error in
                            if let error = error {
                                print("Error in restorePreviousSignIn \(error.localizedDescription)")
                            } else {
                                print("UserID\(String(describing: userID?.authentication.clientID))")
                            }
                        }
                    }
                    let videoListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoListViewController") as! VideoListViewController
                    let navController = UINavigationController(rootViewController: videoListViewController)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
