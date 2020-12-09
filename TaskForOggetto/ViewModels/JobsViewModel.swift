//
//  JobsViewModel.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/8/20.
//

import Foundation

class JobsViewModel: NSObject {
    // MARK: - Properties
    private let apiService = APIService()
    var jobsData = [[String : [JobData]]]()
    var pageIndex = 1
    var errorResponseType : ServerResponseType?
    var isRequestMode = false
    
    var modelsDidLoaded : (([[String : [JobData]]],
                            ServerResponseType?,
                            Bool,
                            [IndexPath]?,
                            IndexSet?) -> ())?

    func getJobs() {
        if isRequestMode {
            return
        }
        
        isRequestMode = true
        self.apiService.getJobs(forPgae: pageIndex) { [weak self] responseType in
            guard let strongSelf = self else { return }
            strongSelf.errorResponseType = responseType
            strongSelf.modelsDidLoaded?(strongSelf.jobsData, responseType, false, nil, nil)
            strongSelf.isRequestMode = false
        } success: { [weak self] jobsData in
            guard let strongSelf = self else { return }
            strongSelf.pageIndex+=1
            strongSelf.filtreItems(items: jobsData)
            strongSelf.errorResponseType = nil
            strongSelf.isRequestMode = false
        }
    }
    
    private func filtreItems(items: [JobData]) {
        let filtredItems = items.sorted(by: {$0.realDate > $1.realDate})
        if jobsData.count == 0 {
            filtreByReloadingTableData(items: filtredItems)
        } else {
            filtreByInsertingTableData(items: filtredItems)
        }
    }
    
    // when using reload data
    private func filtreByReloadingTableData(items: [JobData]) {
        // first item index for new section
        var firstItemIndex = 0
        for index in 1...items.count - 1 {
            // When createdAt is difference -> index is first index of new section, and index-1 is last item previous section
            if items[index].createdAt != items[index - 1].createdAt {
                let sectiondata = [items[index - 1].createdAt : Array(items[firstItemIndex..<index])]
                jobsData.append(sectiondata)
                firstItemIndex = index
            }
        }
        // Add last section data
        let sectiondata = [items[firstItemIndex].createdAt : Array(items[firstItemIndex..<items.count])]
        jobsData.append(sectiondata)
        
        self.modelsDidLoaded?(jobsData, nil, true, nil, nil)
    }
    
    private func filtreByInsertingTableData(items: [JobData]) {
        
        let oldSectionsCount = jobsData.count
        var insertingCellsIndexPaths = [IndexPath]()
        var insertingSectionsIndexes: IndexSet?
        insertingSectionsIndexes = IndexSet()
        
        for item in items {
            var isExistSection = false
            for index in 0...jobsData.count - 1 {
                // If has section by item date then add item that section
                if item.createdAt == jobsData[index].keys.first {
                    // add item in section data
                    jobsData[index][item.createdAt]!.append(item)
                    
                    // Check if this section is old
                    if oldSectionsCount > index {
                        // Add indexPath for new inserting cell
                        let row = jobsData[index][item.createdAt]!.count - 1
                        let indexPath = IndexPath(row: row, section:index)
                        insertingCellsIndexPaths.append(indexPath)
                    }
                    isExistSection = true

                    break
                }
            }
            
            // When not section by item date then add section
            if !isExistSection {
                jobsData.append([item.createdAt : [item]])
                insertingSectionsIndexes!.insert(jobsData.count - 1)
            }
        }
        
        if insertingSectionsIndexes!.startIndex == insertingSectionsIndexes!.endIndex {
            insertingSectionsIndexes = nil
        }
        
        self.modelsDidLoaded?(jobsData, nil, false, insertingCellsIndexPaths, insertingSectionsIndexes)
    }
}
