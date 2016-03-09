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

import UIKit

public protocol UITableViewSectionObject: Equatable {
    typealias UITableViewRowObject: Equatable
    
    var rows: [UITableViewRowObject] { get }
    func needsReloadFrom<S: UITableViewSectionObject>(sectionObject: S) -> Bool
}

public extension UITableView {
    public func updateFromSections<T: UITableViewSectionObject>(oldSections: [T] = [], toSections newSections: [T], animated: Bool = true) {
        let animation: UITableViewRowAnimation = (animated) ? .Automatic : .None
        
        if oldSections.count <= 0 {
            let toAddSections: [Int] = (0..<newSections.count).map { $0 }
            let indexSet = toAddSections.reduce(NSMutableIndexSet()) { $0.addIndex($1); return $0 }
            beginUpdates()
            insertSections(NSIndexSet(indexSet: indexSet), withRowAnimation: animation)
            endUpdates()
            return
        }
        
        var sectionResults = [T](oldSections)
        var rowResults = [Optional<Array<T.UITableViewRowObject>>]()
        
        beginUpdates()
        
        // Remove sections
        let toRemoveIndexes = oldSections.filter { !newSections.contains($0) }.map { oldSections.indexOf($0)! }
        for idx in toRemoveIndexes.reverse() { sectionResults.removeAtIndex(idx) }
        let toRemoveSections = toRemoveIndexes.reduce(NSMutableIndexSet()) { $0.addIndex($1); return $0 }
        deleteSections(toRemoveSections, withRowAnimation: animation)
        
        // Add sections
        let toAddSections = NSMutableIndexSet()
        let toReloadSections = NSMutableIndexSet()
        for (idx, section) in newSections.enumerate() {
            if let oldIdx = oldSections.indexOf(section) {
                if section.needsReloadFrom(oldSections[oldIdx]) {
                    toReloadSections.addIndex(idx)
                    rowResults.append(nil)
                } else {
                    var currentRowResults = oldSections[oldIdx].rows
                    insertAndDeleteFromRows(oldSections[oldIdx].rows, toRows: section.rows, results: &currentRowResults, inSection: idx, withAnimation: animation)
                    rowResults.append(currentRowResults)
                }
            } else {
                rowResults.append(nil)
                sectionResults.insert(section, atIndex: idx)
                toAddSections.addIndex(idx)
            }
        }
        insertSections(NSIndexSet(indexSet: toAddSections), withRowAnimation: animation)
        reloadSections(NSIndexSet(indexSet: toReloadSections), withRowAnimation: animation)
        endUpdates()
        
        beginUpdates()
        // Move and update sections
        for (idx, section) in newSections.enumerate() {
            if let oldIdx = oldSections.indexOf(section) {
                if let resultIdx = sectionResults.indexOf(section) {
                    if idx != resultIdx {
                        moveSection(resultIdx, toSection: idx)
                    }
                    if let results = rowResults[resultIdx] {
                        moveFromRows(oldSections[oldIdx].rows, toRows: section.rows, withPreviousResults: results, inSection: idx, withAnimation: animation)
                    }
                }
            }
        }
        endUpdates()
    }
    
    public func updateFromRows<T: Equatable>(oldRows: [T] = [], toRows newRows: [T], inSection section: Int = 0, animated: Bool = true) {
        let animation: UITableViewRowAnimation = (animated) ? .Automatic : .None
        if oldRows.count <= 0 {
            let toAddIndexPaths: [NSIndexPath] = (0..<newRows.count).map { NSIndexPath(forRow: $0, inSection: section) }
            beginUpdates()
            insertRowsAtIndexPaths(toAddIndexPaths, withRowAnimation: animation)
            endUpdates()
            return
        }
        
        var results = [T](oldRows)
        
        beginUpdates()
        insertAndDeleteFromRows(oldRows, toRows: newRows, results: &results, inSection: section, withAnimation: animation)
        endUpdates()
        
        beginUpdates()
        moveFromRows(oldRows, toRows: newRows, withPreviousResults: results, inSection: section, withAnimation: animation)
        endUpdates()
    }
    
    // MARK: - Helpers
    private func insertAndDeleteFromRows<T: Equatable>(oldRows: [T] = [], toRows newRows: [T], inout results: [T], inSection section: Int, withAnimation animation: UITableViewRowAnimation) {
        // Remove rows
        let toDeleteIndexes = oldRows.filter { !newRows.contains($0) }.map { oldRows.indexOf($0)! }
        for idx in toDeleteIndexes.reverse() { results.removeAtIndex(idx) }
        let toRemoveIndexPaths: [NSIndexPath] = toDeleteIndexes.map { NSIndexPath(forRow: $0, inSection: section) }
        deleteRowsAtIndexPaths(toRemoveIndexPaths, withRowAnimation: animation)
        
        // Add rows
        let toAddIndexes = newRows.filter { !oldRows.contains($0) }.map { newRows.indexOf($0)! }
        for idx in toAddIndexes { results.insert(newRows[idx], atIndex: idx) }
        let toAddIndexPaths: [NSIndexPath] = toAddIndexes.map { NSIndexPath(forRow: $0, inSection: section) }
        insertRowsAtIndexPaths(toAddIndexPaths, withRowAnimation: animation)
    }
    
    private func moveFromRows<T: Equatable>(oldRows: [T], toRows newRows: [T], withPreviousResults results: [T], inSection section: Int, withAnimation animation: UITableViewRowAnimation) {
        for (idx, row) in newRows.enumerate() {
            if oldRows.contains(row) {
                if let oldIdx = results.indexOf(row) where oldIdx != idx {
                    let oldIndexPath = NSIndexPath(forRow: oldIdx, inSection: section)
                    let newIndexPath = NSIndexPath(forRow: idx, inSection: section)
                    moveRowAtIndexPath(oldIndexPath, toIndexPath: newIndexPath)
                }
            }
        }
    }
}
