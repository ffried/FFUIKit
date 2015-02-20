//
//  UITableView+AnimatedArrayUpdate.swift
//  FFUIKit
//
//  Created by Florian Friedrich on 31.1.15.
//  Copyright (c) 2015 Florian Friedrich. All rights reserved.
//

import FFUIKit

public protocol UITableViewSectionObject: Equatable {
    typealias UITableViewRowObject: Equatable
    
    var rows: [UITableViewRowObject] { get }
    func needsReloadFrom(sectionObject: UITableViewSectionObject) -> Bool
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
        let toRemoveIndexes = oldSections.filter { !contains(newSections, $0) }.map { find(oldSections, $0)! }
        let toRemoveSections = toRemoveIndexes.reverse().reduce(NSMutableIndexSet()) {
            sectionResults.removeAtIndex($1)
            $0.addIndex($1)
            return $0
        }
        deleteSections(toRemoveSections, withRowAnimation: animation)
        
        // Add sections
        var toAddSections = NSMutableIndexSet()
        var toReloadSections = NSMutableIndexSet()
        for (idx, section) in enumerate(newSections) {
            if let oldIdx = find(oldSections, section) {
                if section.needsReloadFrom(oldSections[oldIdx]) {
                    toReloadSections.addIndex(idx)
                    rowResults.append(nil)
                } else {
                    var currentRowResults = oldSections[oldIdx].rows
                    insertAndDeleteFromRows(oldRows: oldSections[oldIdx].rows, toRows: section.rows, results: &currentRowResults, inSection: idx, withAnimation: animation)
                    rowResults.append(currentRowResults)
                }
            } else {
                sectionResults.insert(section, atIndex: idx)
                toAddSections.addIndex(idx)
            }
        }
        insertSections(NSIndexSet(indexSet: toAddSections), withRowAnimation: animation)
        reloadSections(NSIndexSet(indexSet: toReloadSections), withRowAnimation: animation)
        endUpdates()
        
        beginUpdates()
        // Move and update sections
        for (idx, section) in enumerate(newSections) {
            if let oldIdx = find(oldSections, section) {
                if let resultIdx = find(sectionResults, section) {
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
        if countElements(oldRows) <= 0 {
            let toAddIndexPaths: [NSIndexPath] = (0..<newRows.count).map { NSIndexPath(forRow: $0, inSection: section) }
            beginUpdates()
            insertRowsAtIndexPaths(toAddIndexPaths, withRowAnimation: animation)
            endUpdates()
            return
        }
        
        var results = [T](oldRows)
        
        beginUpdates()
        insertAndDeleteFromRows(oldRows: oldRows, toRows: newRows, results: &results, inSection: section, withAnimation: animation)
        endUpdates()
        
        beginUpdates()
        moveFromRows(oldRows, toRows: newRows, withPreviousResults: results, inSection: section, withAnimation: animation)
        endUpdates()
    }
    
    // MARK: - Helpers
    private func insertAndDeleteFromRows<T: Equatable>(oldRows: [T] = [], toRows newRows: [T], inout results: [T], inSection section: Int, withAnimation animation: UITableViewRowAnimation) {
        // Remove rows
        let toDeleteIndexes = oldRows.filter { !contains(newRows, $0) }.map { find(oldRows, $0)! }
        let toRemoveIndexPaths: [NSIndexPath] = toDeleteIndexes.reverse().map {
            results.removeAtIndex($0)
            return NSIndexPath(forRow: $0, inSection: section)
        }
        deleteRowsAtIndexPaths(toRemoveIndexPaths, withRowAnimation: animation)
        
        // Add rows
        let toAddIndexes = newRows.filter { !contains(oldRows, $0) }.map { find(newRows, $0)! }
        let toAddIndexPaths: [NSIndexPath] = toAddIndexes.map {
            results.insert(newRows[$0], atIndex: $0)
            return NSIndexPath(forRow: $0, inSection: section)
        }
        insertRowsAtIndexPaths(toAddIndexes, withRowAnimation: animation)
    }
    
    private func moveFromRows<T: Equatable>(oldRows: [T], toRows newRows: [T], withPreviousResults results: [T], inSection section: Int, withAnimation animation: UITableViewRowAnimation) {
        for (idx, row) in enumerate(newRows) {
            if contains(oldRows, row) {
                if let oldIdx = find(results, row) {
                    if oldIdx != idx {
                        let oldIndexPath = NSIndexPath(forRow: oldIdx, inSection: section)
                        let newIndexPath = NSIndexPath(forRow: idx, inSection: section)
                        moveRowAtIndexPath(oldIndexPath, toIndexPath: newIndexPath)
                    }
                }
            }
        }
    }
}
