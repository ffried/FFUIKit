//
//  LicensesTableViewController.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 31.1.15.
//  Copyright 2015 Florian Friedrich
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import struct Foundation.IndexPath
import enum UIKit.UIStatusBarStyle
import enum UIKit.UITableViewCellAccessoryType
import class UIKit.UIColor
import class UIKit.UIView
import class UIKit.UITableViewCell
import class UIKit.UITableView
import class UIKit.UITableViewController

public final class LicensesTableViewController: UITableViewController {
    
    private let licenseCellReuseIdentifier = "LicenseCell"
    
    private var _preferredStatusBarStyle: UIStatusBarStyle = .default
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return _preferredStatusBarStyle }
        set { _preferredStatusBarStyle = newValue }
    }
    
    public var cellBackgroundColor: UIColor? = nil
    
    public var licenses: [License] = [] {
        didSet {
            guard isViewLoaded else { return }
            tableView?.update(from: oldValue, to: licenses, in: 0, animated: true)
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Licenses", comment: String(describing: LicensesTableViewController.self))
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableFooterView?.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: licenseCellReuseIdentifier)
        tableView.reloadData()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assert(navigationController != nil, "LicenseViewController is not within a UINavigationController! Trouble ahead!")
        if clearsSelectionOnViewWillAppear, let ip = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: ip, animated: animated)
        }
    }
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenses.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: licenseCellReuseIdentifier, for: indexPath)
        cell.backgroundColor = cellBackgroundColor
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = licenses[indexPath.row].title
        return cell
    }
    
    // MARK: - Table view delegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = LicenseDetailViewController()
        detailVC.license = licenses[indexPath.row]
        detailVC.view.backgroundColor = view.backgroundColor
        detailVC.preferredStatusBarStyle = preferredStatusBarStyle
        navigationController!.pushViewController(detailVC, animated: true)
    }
}
