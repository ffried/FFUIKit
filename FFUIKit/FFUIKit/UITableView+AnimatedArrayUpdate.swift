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
    #if swift(>=2.2)
        associatedtype UITableViewRowObject: Equatable
    #else
        typealias UITableViewRowObject: Equatable
    #endif
    
    var rows: [UITableViewRowObject] { get }
    #if swift(>=3)
    func needsReload<S: UITableViewSectionObject>(from sectionObject: S) -> Bool
    #else
    func needsReloadFrom<S: UITableViewSectionObject>(sectionObject: S) -> Bool
    #endif
}

public extension UITableView {
    #if swift(>=3)
    public func update<T: UITableViewSectionObject>(from oldSections: [T] = [], to newSections: [T], animated: Bool = true) {
        let animation: UITableViewRowAnimation = (animated) ? .automatic : .none
        
        guard oldSections.count > 0 else {
            beginUpdates()
            insertSections(IndexSet((0..<newSections.count)), with: animation)
            endUpdates()
            return
        }
        
        var sectionResults = Array<T>(oldSections)
        var rowResults = [Optional<Array<T.UITableViewRowObject>>]()
        
        beginUpdates()
        
        // Remove sections
        let toRemoveIndexes = oldSections.enumerated().filter { !newSections.contains($1) }.map { $0.offset }
        toRemoveIndexes.reversed().forEach { sectionResults.remove(at: $0) }
        let toRemoveSections = toRemoveIndexes.reduce(IndexSet()) { $0.union(IndexSet(integer: $1)) }
        deleteSections(toRemoveSections, with: animation)
        
        // Add sections
        var toAddSections = IndexSet()
        var toReloadSections = IndexSet()
        for (idx, section) in newSections.enumerated() {
            if let oldIdx = oldSections.index(of: section) {
                if section.needsReload(from: oldSections[oldIdx]) {
                    toReloadSections.insert(idx)
                    rowResults.append(nil)
                } else {
                    var currentRowResults = oldSections[oldIdx].rows
                    insertAndDelete(from: oldSections[oldIdx].rows, to: section.rows, results: &currentRowResults, in: idx, with: animation)
                    rowResults.append(currentRowResults)
                }
            } else {
                rowResults.append(nil)
                sectionResults.insert(section, at: idx)
                toAddSections.insert(idx)
            }
        }
        insertSections(toAddSections, with: animation)
        reloadSections(toReloadSections, with: animation)
        
        endUpdates()
        
        beginUpdates()
        // Move and update sections
        for (idx, section) in newSections.enumerated() {
            if let oldIdx = oldSections.index(of: section) {
                if let resultIdx = sectionResults.index(of: section) {
                    if idx != resultIdx {
                        moveSection(resultIdx, toSection: idx)
                    }
                    if let results = rowResults[resultIdx] {
                        move(from: oldSections[oldIdx].rows, to: section.rows, withPreviousResults: results, in: idx, with: animation)
                    }
                }
            }
        }
        endUpdates()
    }
    #else
    public func updateFromSections<T: UITableViewSectionObject>(oldSections: [T] = [], toSections newSections: [T], animated: Bool = true) {
        let animation: UITableViewRowAnimation = (animated) ? .Automatic : .None
    
        if oldSections.count <= 0 {
            let toAddSections: [Int] = (0..<newSections.count).map { $0 }
            let indexSet = NSIndexSet(indexSet: toAddSections.reduce(NSMutableIndexSet()) { $0.addIndex($1); return $0 })
            
            beginUpdates()
            insertSections(indexSet, withRowAnimation: animation)
            endUpdates()
            return
        }
        
        var sectionResults = Array<T>(oldSections)
        var rowResults = [Optional<Array<T.UITableViewRowObject>>]()
        
        beginUpdates()
        
        // Remove sections
        let toRemoveIndexes = oldSections.enumerate().filter { !newSections.contains($1) }.map { $0.0 }
        toRemoveIndexes.reverse().forEach { sectionResults.removeAtIndex($0) }
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
    #endif
    
    #if swift(>=3)
    public func update<T: Equatable>(from oldRows: [T] = [], to newRows: [T], in section: Int, animated: Bool = true) {
        let animation: UITableViewRowAnimation = (animated) ? .automatic : .none
        if oldRows.count <= 0 {
            let toAddIndexPaths = (0..<newRows.count).map { IndexPath(row: $0, section: section) }
            beginUpdates()
            insertRows(at: toAddIndexPaths, with: animation)
            endUpdates()
            return
        }
        
        var results = Array<T>(oldRows)
        
        beginUpdates()
        insertAndDelete(from: oldRows, to: newRows, results: &results, in: section, with: animation)
        endUpdates()
        
        beginUpdates()
        move(from: oldRows, to: newRows, withPreviousResults: results, in: section, with: animation)
        endUpdates()
    }
    #else
    public func updateFromRows<T: Equatable>(oldRows: [T] = [], toRows newRows: [T], inSection section: Int = 0, animated: Bool = true) {
        let animation: UITableViewRowAnimation = (animated) ? .Automatic : .None
        if oldRows.count <= 0 {
            let toAddIndexPaths: [NSIndexPath] = (0..<newRows.count).map { NSIndexPath(forRow: $0, inSection: section) }
            beginUpdates()
            insertRowsAtIndexPaths(toAddIndexPaths, withRowAnimation: animation)
            endUpdates()
            return
        }
        
        var results = Array<T>(oldRows)
        
        beginUpdates()
        insertAndDeleteFromRows(oldRows, toRows: newRows, results: &results, inSection: section, withAnimation: animation)
        endUpdates()
        
        beginUpdates()
        moveFromRows(oldRows, toRows: newRows, withPreviousResults: results, inSection: section, withAnimation: animation)
        endUpdates()
    }
    #endif
    
    // MARK: - Helpers
    #if swift(>=3)
    private func insertAndDelete<T: Equatable>(from oldRows: [T] = [], to newRows: [T], results: inout [T], in section: Int, with animation: UITableViewRowAnimation) {
        // Remove rows
        let toDeleteIndexes = oldRows.enumerated().filter { !newRows.contains($1) }.map { $0.offset }
        toDeleteIndexes.reversed().forEach { results.remove(at: $0) }
        let toRemoveIndexPaths = toDeleteIndexes.map { IndexPath(row: $0, section: section) }
        deleteRows(at: toRemoveIndexPaths, with: animation)
        
        // Add rows
        let toAdd = newRows.enumerated().filter { !oldRows.contains($1) }
        toAdd.forEach { results.insert($1, at: $0) }
        let toAddIndexPaths = toAdd.map { IndexPath(row: $0.offset, section: section) }
        insertRows(at: toAddIndexPaths, with: animation)
    }
    
    private func move<T: Equatable>(from oldRows: [T], to newRows: [T], withPreviousResults results: [T], in section: Int, with animation: UITableViewRowAnimation) {
        for (idx, row) in newRows.enumerated() {
            if oldRows.contains(row) {
                if let oldIdx = results.index(of: row), oldIdx != idx {
                    let oldIndexPath = IndexPath(row: oldIdx, section: section)
                    let newIndexPath = IndexPath(row: idx, section: section)
                    moveRow(at: oldIndexPath, to: newIndexPath)
                }
            }
        }
    }
    #else
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
    #endif
}
