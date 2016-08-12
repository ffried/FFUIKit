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

import UIKit

public class LicensesTableViewController: UITableViewController {
    
    private let LicenseCellReuseIdentifier = "LicenseCell"
    
    #if swift(>=3)
    private var _preferredStatusBarStyle: UIStatusBarStyle = .default
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return _preferredStatusBarStyle }
        set { _preferredStatusBarStyle = newValue }
    }
    #else
    private var _preferredStatusBarStyle: UIStatusBarStyle = .Default
    public func setPreferredStatusBarStyle(style: UIStatusBarStyle) {
        _preferredStatusBarStyle = style
    }
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return _preferredStatusBarStyle
    }
    #endif
    public var cellBackgroundColor: UIColor? = nil
    
    public var licenses: [License] = [] {
        didSet {
            #if swift(>=3)
                guard isViewLoaded else { return }
                tableView?.update(from: oldValue, to: licenses, in: 0, animated: true)
            #else
                guard isViewLoaded() else { return }
                tableView?.updateFromRows(oldValue, toRows: licenses, inSection: 0, animated: true)
            #endif
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Licenses", comment: NSStringFromClass(LicensesTableViewController.self))
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        #if swift(>=3)
            tableView.tableFooterView?.backgroundColor = .clear
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: LicenseCellReuseIdentifier)
        #else
            tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: LicenseCellReuseIdentifier)
        #endif
        tableView.reloadData()
    }
    
    #if swift(>=3)
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assert(navigationController != nil, "LicenseViewController is not within a UINavigationController! Trouble ahead!")
        if clearsSelectionOnViewWillAppear {
            if let ip = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: ip, animated: animated)
            }
        }
    }
    #else
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        assert(navigationController != nil, "LicenseViewController is not within a UINavigationController! Trouble ahead!")
        if clearsSelectionOnViewWillAppear {
            if let ip = tableView.indexPathForSelectedRow {
                tableView.deselectRowAtIndexPath(ip, animated: animated)
            }
        }
    }
    #endif
    
    // MARK: - Table view data source
    #if swift(>=3)
    public override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenses.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LicenseCellReuseIdentifier, for: indexPath)
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
        #if swift(>=3.0)
            detailVC.preferredStatusBarStyle = preferredStatusBarStyle
        #else
            detailVC.setPreferredStatusBarStyle(style: preferredStatusBarStyle())
        #endif
        navigationController!.pushViewController(detailVC, animated: true)
    }
    #else
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return licenses.count
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LicenseCellReuseIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = cellBackgroundColor
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.text = licenses[indexPath.row].title
        return cell
    }
    
    // MARK: - Table view delegate
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailVC = LicenseDetailViewController()
        detailVC.license = licenses[indexPath.row]
        detailVC.view.backgroundColor = self.view.backgroundColor
        detailVC.setPreferredStatusBarStyle(preferredStatusBarStyle())
        navigationController!.pushViewController(detailVC, animated: true)
    }
    #endif
}
