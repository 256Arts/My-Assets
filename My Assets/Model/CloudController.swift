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
    
    let metadataQuery = NSMetadataQuery()

    @Published var financialData: FinancialData?
    
    init() {
        metadataQuery.notificationBatchingInterval = 1
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        metadataQuery.predicate = NSPredicate(format: "%K LIKE 'Financial Data.json'", NSMetadataItemFSNameKey)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(metadataQueryDidFinishGathering),
            name: Notification.Name.NSMetadataQueryDidFinishGathering,
            object: metadataQuery)
        metadataQuery.start()
    }

    @objc func metadataQueryDidFinishGathering(_ notification: Notification) {
        metadataQuery.disableUpdates()
        if metadataQuery.results.isEmpty {
            print("No cloud files found. Creating new file.")
            financialData = FinancialData(fileVersion: FinancialData.newestFileVersion, nonStockAssets: [], stocks: [], debts: [], nonAssetIncome: [], nonDebtExpenses: [])
        } else {
            do {
                financialData = try fetchFinancialData()
            } catch {
                print("Failed to fetch data after query gather")
            }
        }
        metadataQuery.enableUpdates()
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
