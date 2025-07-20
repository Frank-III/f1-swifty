//
//  DictionaryMerge.swift
//  F1-Dash
//
//  Port of TypeScript merge function for handling partial F1 data updates
//

import Foundation

/// Utility for merging F1 data dictionaries similar to TypeScript implementation
struct DictionaryMerge {
    
    /// Recursively merge two values, with update taking precedence
    /// Matches the behavior of the TypeScript merge function
    static func merge(_ base: Any?, with update: Any) -> Any {
        // If base is dictionary and update is dictionary, merge recursively
        if let baseDict = base as? [String: Any],
           let updateDict = update as? [String: Any] {
            var result = baseDict
            
            for (key, value) in updateDict {
                result[key] = merge(baseDict[key], with: value)
            }
            
            return result
        }
        
        // If base is array and update is array, concatenate
        if let baseArray = base as? [Any],
           let updateArray = update as? [Any] {
            return baseArray + updateArray
        }
        
        // If base is array and update is dictionary (indexed updates)
        if let baseArray = base as? [Any],
           let updateDict = update as? [String: Any] {
            var result = baseArray
            
            for (key, value) in updateDict {
                if let index = Int(key), index < result.count {
                    result[index] = merge(result[index], with: value)
                }
            }
            
            return result
        }
        
        // Otherwise, replace with update
        return update
    }
    
    /// Merge F1 state update into existing state dictionary
    static func mergeState(_ state: inout [String: Any], with update: [String: Any]) {
        for (key, value) in update {
            state[key] = merge(state[key], with: value)
        }
    }
}