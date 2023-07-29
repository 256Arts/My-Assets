//
//  CloudController.swift
//  My Assets
//
//  Created by Jayden Irwin on 2022-03-28.
//  Copyright © 2022 Jayden Irwin. All rights reserved.
//

import Foundation

final class CloudController: ObservableObject {
    
    enum FetchError: Error {
        case noObjectForKey
    }
    
    static let shared = CloudController()
    
    var filename: String {
        UserDefaults.standard.bool(forKey: UserDefaults.Key.showDebugData) ? "Financial Data (Debug).json" : "Financial Data.json"
    }
    var fileURL: URL {
        let directoryURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directoryURL.appending(path: filename, directoryHint: .notDirectory)
    }
    
    let finishGatheringQuery = NSMetadataQuery()
    let updateQuery = NSMetadataQuery()

    @Published var financialData: FinancialData?
    @Published var decodeError: Error?
    
    init() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(queryDidFinishGathering),
            name: Notification.Name.NSMetadataQueryDidFinishGathering,
            object: finishGatheringQuery)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidUpdate),
            name: NSNotification.Name.NSMetadataQueryDidUpdate,
            object: updateQuery)
        
        finishGatheringQuery.notificationBatchingInterval = 1
        finishGatheringQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        finishGatheringQuery.predicate = NSPredicate(format: "%K LIKE '\(filename)'", NSMetadataItemFSNameKey)
        finishGatheringQuery.start()
        
        updateQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        updateQuery.valueListAttributes = [NSMetadataUbiquitousItemPercentDownloadedKey, NSMetadataUbiquitousItemDownloadingStatusKey]
        updateQuery.predicate = NSPredicate(format: "%K LIKE '\(filename)'", NSMetadataItemFSNameKey)
        updateQuery.start()
    }

    @objc func queryDidFinishGathering(_ notification: Notification) {
        finishGatheringQuery.disableUpdates()
        if finishGatheringQuery.results.isEmpty {
            print("No cloud files found. Creating new file.")
            financialData = FinancialData(fileVersion: FinancialData.newestFileVersion, nonStockAssets: [], stocks: [], debts: [], nonAssetIncome: [], nonDebtExpenses: [])
        } else {
            do {
                financialData = try fetchFinancialData()
            } catch {
                decodeError = error
                print("Failed to fetch data after query gather")
            }
        }
        finishGatheringQuery.enableUpdates()
    }
    
    @objc func queryDidUpdate(_ notification: Notification) {
        updateQuery.disableUpdates()
        if updateQuery.results.isEmpty {
            print("No cloud files found. Creating new file.")
            financialData = FinancialData(fileVersion: FinancialData.newestFileVersion, nonStockAssets: [], stocks: [], debts: [], nonAssetIncome: [], nonDebtExpenses: [])
        } else {
            do {
                financialData = try fetchFinancialData()
            } catch {
                decodeError = error
                print("Failed to fetch data after query gather")
            }
        }
        updateQuery.enableUpdates()
    }
    
    func fetchFinancialData() throws -> FinancialData? {
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
            do {
                let attributes = try fileURL.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
                if let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus {
                    switch status {
                    case .current, .downloaded:
                        let savedData = try Data(contentsOf: fileURL)
                        return try loadFinancialData(data: savedData)
                    default:
                        // Download again
                        return try fetchFinancialData()
                    }
                }
            } catch {
                print(error)
            }

            let savedData = try Data(contentsOf: fileURL)
            return try loadFinancialData(data: savedData)
        } catch {
            print(error)
            
            guard let savedData = NSUbiquitousKeyValueStore.default.object(forKey: UserDefaults.Key.financialData) as? Data else {
                throw FetchError.noObjectForKey
            }
            // Remove old data
            NSUbiquitousKeyValueStore.default.removeObject(forKey: UserDefaults.Key.financialData)
            return try loadFinancialData(data: savedData)
        }
    }

    func loadFinancialData(data: Data) throws -> FinancialData {
        // Upgrade data here if needed
        return try JSONDecoder().decode(FinancialData.self, from: data)
    }
    
}
