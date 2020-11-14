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

#if !os(watchOS)
import Foundation
import UIKit

@available(iOS 13, tvOS 13, *)
public final class LicensesTableViewController: UITableViewController {
    private struct LicenseKey: Hashable {
        let title: String
        let filePath: String

        init(license: License) {
            title = license.title
            filePath = license.file.path
        }
    }

    private static var licenseCellReuseIdentifier: String { "LicenseCell" }

    #if !os(tvOS)
    private var _preferredStatusBarStyle: UIStatusBarStyle = .default
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get { _preferredStatusBarStyle }
        set { _preferredStatusBarStyle = newValue }
    }
    #endif

    public var cellBackgroundColor: UIColor?

    private lazy var dataSource = UITableViewDiffableDataSource<Int8, LicenseKey>(tableView: tableView, cellProvider: { [weak self] in
        let cell = $0.dequeueReusableCell(withIdentifier: LicensesTableViewController.licenseCellReuseIdentifier, for: $1)
        cell.backgroundColor = self?.cellBackgroundColor
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = self?.licensesLookup[$2]?.title
        return cell
    })

    private var licensesLookup: [LicenseKey: License] = [:]
    public var licenses: [License] = [] {
        didSet {
            licensesLookup.removeAll(keepingCapacity: true)
            licensesLookup.reserveCapacity(licenses.count)
            licenses = licenses.filter {
                let key = LicenseKey(license: $0)
                if licensesLookup[key] != nil {
                    return false
                } else {
                    licensesLookup[key] = $0
                    return true
                }
            }
            guard isViewLoaded else { return }
            updateTableView(animated: true)
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Licenses", comment: String(describing: LicensesTableViewController.self))
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableFooterView?.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: LicensesTableViewController.licenseCellReuseIdentifier)
        updateTableView(animated: false)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assert(navigationController != nil, "LicenseViewController is not within a UINavigationController! Trouble ahead!")
        if clearsSelectionOnViewWillAppear, let ip = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: ip, animated: animated)
        }
    }

    private func updateTableView(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int8, LicenseKey>()
        snapshot.appendSections([0])
        snapshot.appendItems(licenses.map(LicenseKey.init), toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    // MARK: - Table view delegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = LicenseDetailViewController(license: licenses[indexPath.row])
        detailVC.view.backgroundColor = view.backgroundColor
        #if !os(tvOS)
        detailVC.preferredStatusBarStyle = preferredStatusBarStyle
        #endif
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
#endif
