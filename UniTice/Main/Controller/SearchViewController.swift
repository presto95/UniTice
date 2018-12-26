//
//  SearchViewController.swift
//  UniTice
//
//  Created by Presto on 26/12/2018.
//  Copyright © 2018 presto. All rights reserved.
//

//import UIKit
//
//class SearchViewController: UIViewController {
//
//    private lazy var keywords = (User.fetch()?.keywords)!
//    
//    private var posts: [Post] = []
//    
//    private lazy var universityModel = University.generateModel()
//    
//    private var category
//    
//    @IBOutlet private weak var tableView: UITableView! {
//        didSet {
//            tableView.delegate = self
//            tableView.dataSource = self
//            tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "postCell")
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        registerForPreviewing(with: self, sourceView: tableView)
//    }
//    
//    private func requestPosts() {
//        
//    }
//}
//
//extension SearchViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return posts.count
//    }
//}
//
//extension SearchViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}
//
//extension SearchViewController: UIViewControllerPreviewingDelegate {
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        if let indexPath = tableView.indexPathForRow(at: location) {
//            let post = posts[indexPath.row]
//            let fullLink = universityModel.postURL(inCategory: <#T##(name: String, description: String)#>, link: <#T##String#>)
//        }
//    }
//    
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//        present(viewControllerToCommit, animated: true, completion: nil)
//    }
//}
