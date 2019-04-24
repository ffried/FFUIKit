//
//  UITableView+AnimatedArrayUpdate.swift
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

import struct Foundation.IndexSet
import struct Foundation.IndexPath
import enum UIKit.UITableViewRowAnimation
import class UIKit.UITableView

public protocol UITableViewReloadableObject: Equatable {
    func needsReload(from other: Self) -> Bool
}

// public protocol UITableViewRowObject: UITableViewReloadableObject {}

public protocol UITableViewSectionObject: UITableViewReloadableObject {
    associatedtype Row: Equatable // UITableViewRowObject
    
    var rows: [Row] { get }
}

extension UITableView {
    private final func _performBatchUpdates(_ updates: @escaping () -> (), completion: ((Bool) -> ())? = nil) {
        if #available(
            iOS 11, iOSApplicationExtension 11,
            tvOS 11, tvOSApplicationExtension 11,
            watchOS 4, watchOSApplicationExtension 4,
            *) {
            performBatchUpdates(updates, completion: completion)
        } else {
            beginUpdates()
            updates()
            endUpdates()
            completion?(true)
        }
    }

    public func update<Section: UITableViewSectionObject>(from oldSections: [Section] = [], to newSections: [Section], animated: Bool = true) {
        let animation: RowAnimation = animated ? .automatic : .none
        
        guard !oldSections.isEmpty else {
            return _performBatchUpdates({
                self.insertSections(IndexSet(newSections.indices), with: animation)
            })
        }
        
        var sectionResults = oldSections
        var rowResults = [Optional<Array<Section.Row>>]()
        _performBatchUpdates({
            // Remove sections
            let toRemove = oldSections.enumerated().filter { !newSections.contains($1) }
            sectionResults.removeAll { section in toRemove.contains { $0.element == section } }
            self.deleteSections(IndexSet(toRemove.map { $0.offset }), with: animation)

            // Add sections
            var toAddSections = IndexSet()
            var toReloadSections = IndexSet()
            for (idx, section) in newSections.enumerated() {
                if let oldIdx = oldSections.firstIndex(of: section) {
                    if section.needsReload(from: oldSections[oldIdx]) {
                        toReloadSections.insert(idx)
                        rowResults.append(nil)
                    } else {
                        var currentRowResults = oldSections[oldIdx].rows
                        self.insertAndDelete(from: oldSections[oldIdx].rows, to: section.rows, results: &currentRowResults, in: idx, with: animation)
                        rowResults.append(currentRowResults)
                    }
                } else {
                    rowResults.append(nil)
                    sectionResults.insert(section, at: idx)
                    toAddSections.insert(idx)
                }
            }
            self.insertSections(toAddSections, with: animation)
            self.reloadSections(toReloadSections, with: animation)
        }) { _ in
            self._performBatchUpdates({
                // Move and update sections
                for (idx, section) in newSections.enumerated() {
                    if let oldIdx = oldSections.firstIndex(of: section),
                        let resultIdx = sectionResults.firstIndex(of: section) {
                        if idx != resultIdx {
                            self.moveSection(resultIdx, toSection: idx)
                        }
                        if let results = rowResults[resultIdx] {
                            self.move(from: oldSections[oldIdx].rows, to: section.rows, withPreviousResults: results, in: idx, with: animation)
                        }/* else {
                         // Reload Rows if section does not reload it.
                         } */
                    }
                }
            })
        }
    }
    
    public func update<Row: Equatable>(from oldRows: [Row] = [], to newRows: [Row], in section: Int, animated: Bool = true) {
        let animation: RowAnimation = animated ? .automatic : .none
        guard !oldRows.isEmpty else {
            return _performBatchUpdates({
                self.insertRows(at: newRows.indices.map { IndexPath(row: $0, section: section) }, with: animation)
            })
        }
        
        var results = Array<Row>(oldRows)
        _performBatchUpdates({
            self.insertAndDelete(from: oldRows, to: newRows, results: &results, in: section, with: animation)
        }) { _ in
            self._performBatchUpdates({
                self.move(from: oldRows, to: newRows, withPreviousResults: results, in: section, with: animation)
            })
        }
    }
    
    // MARK: - Helpers
    private final func insertAndDelete<Row: Equatable>(from oldRows: [Row] = [], to newRows: [Row], results: inout [Row], in section: Int, with animation: RowAnimation) {
        // Remove rows
        let toDelete = oldRows.enumerated().filter { !newRows.contains($1) }
        results.removeAll { row in toDelete.contains { $0.element == row } }
        let toRemoveIndexPaths = toDelete.map { IndexPath(row: $0.offset, section: section) }
        deleteRows(at: toRemoveIndexPaths, with: animation)
        
        // Add rows
        let toAdd = newRows.enumerated().filter { !oldRows.contains($1) }
        toAdd.forEach { results.insert($1, at: $0) }
        let toAddIndexPaths = toAdd.map { IndexPath(row: $0.offset, section: section) }
        insertRows(at: toAddIndexPaths, with: animation)
    }
    
    private final func move<Row: Equatable>(from oldRows: [Row], to newRows: [Row], withPreviousResults results: [Row], in section: Int, with animation: RowAnimation) {
        for (idx, row) in newRows.enumerated() where oldRows.contains(row) {
            guard let oldIdx = results.firstIndex(of: row), oldIdx != idx else { continue }
            let oldIndexPath = IndexPath(row: oldIdx, section: section)
            let newIndexPath = IndexPath(row: idx, section: section)
            moveRow(at: oldIndexPath, to: newIndexPath)
        }
    }
}
