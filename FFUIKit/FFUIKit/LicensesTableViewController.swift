//
//  LicensesTableViewController.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 31.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit

public class LicensesTableViewController: UITableViewController {
    
    private let LicenseCellReuseIdentifier = "LicenseCell"
    
    private var _preferredStatusBarStyle: UIStatusBarStyle = .Default
    public func setPreferredStatusBarStyle(style: UIStatusBarStyle) {
        _preferredStatusBarStyle = style
    }
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return _preferredStatusBarStyle
    }
    public var cellBackgroundColor: UIColor? = nil
    
    public var licenses: [License] = [] {
        didSet {
            if isViewLoaded() {
                tableView?.updateFromRows(oldRows: oldValue, toRows: licenses, inSection: 0, animated: true)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("Licenses", comment: NSStringFromClass(LicensesTableViewController.self))
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: LicenseCellReuseIdentifier)
        tableView.reloadData()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        assert(navigationController != nil, "LicenseViewController is not within a UINavigationController! Trouble ahead!")
        if clearsSelectionOnViewWillAppear {
            if let ip = tableView.indexPathForSelectedRow() {
                tableView.deselectRowAtIndexPath(ip, animated: animated)
            }
        }
    }
    
    // MARK: - Table view data source
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return licenses.count
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LicenseCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
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
}
