//
//  MainViewController.swift
//  SchoolNoticeNotifier
//
//  Created by Presto on 10/11/2018.
//  Copyright © 2018 presto. All rights reserved.
//

import UIKit
import Kanna
import StoreKit
import SafariServices
import SVProgressHUD

class MainViewController: UIViewController {

    var posts: [Post] = []
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        kanna()
    }
    
    func kanna() {
        guard let url = URL(string: "http://www.seoultech.ac.kr/service/info/notice/?bidx=4691&bnum=4691&allboard=false&page=\(1)&size=9&searchtype=1&searchtext=") else { return }
        guard let doc = try? HTML(url: url, encoding: .utf8) else { return }
        // 글번호 / 타이틀 / 빈칸 / 조회수 / 날짜 / 작성자
        let rows = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td")
        // 링크
        let links = doc.xpath("//div[@class='wrap_list']//tr[@class='body_tr']//td[@class='tit']//a/@href")
        for (index, element) in links.enumerated() {
            let numberIndex = index * 6
            let titleIndex = index * 6 + 1
            let dateIndex = index * 6 + 4
            let number = Int(rows[numberIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? 0
            let title = rows[titleIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
            let date = rows[dateIndex].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
            let link = element.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "?"
            let post = Post(number: number, title: title, date: date, link: link)
            posts.append(post)
        }
        tableView.reloadData()
        SVProgressHUD.dismiss()
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let post = posts[indexPath.row]
        if post.number == 0 {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        }
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.date
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let link = posts[indexPath.row].link
        guard let url = URL(string: "http://www.seoultech.ac.kr/service/info/notice\(link)") else { return }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        let viewController = SFSafariViewController(url: url, configuration: config)
        present(viewController, animated: true, completion: nil)        
    }
}