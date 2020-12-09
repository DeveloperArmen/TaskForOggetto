//
//  JobsTableViewDataSource.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/8/20.
//

import Foundation
import UIKit

class  JobsTableViewDataSource <CELL : UITableViewCell, T>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private let headerHeight : CGFloat = 40.0
    private var cellIdentifier : String!
    private var items = [[String : [T]]]()
    var configureCell : (CELL, T) -> () = {_,_ in}
    var didSelectCell : (T) -> () = {_ in}
    var willShowPenultimateCell : () -> () = {}
    
    // MARK: Public
    init(cellIdentifier : String, configureCell : @escaping (CELL, T) ->()) {
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
    }
    
    func changeItems(items : [[String : [T]]]) {
        self.items = items
    }
    
    
    // MARK: - DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        max(items.count, 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            return 0
        }
        return items[section].values.first!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CELL
        
        let sectionInfo = items[indexPath.section]
        let data = sectionInfo.values.first![indexPath.row]
        self.configureCell(cell, data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if items.count == 0 {
            return nil
        }
        
        let sectionInfo = items[section]
        return sectionInfo.keys.first
    }
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if items.count == 0 {
            return 0
        }
        
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if items.count > 0, indexPath.section == self.items.count - 1 {
            let sectionInfo = items[indexPath.section]
            if indexPath.row == sectionInfo.values.first!.count - 1 {
                willShowPenultimateCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = items[indexPath.section]
        let data = sectionInfo.values.first![indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectCell(data)
    }
}



