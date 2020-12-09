//
//  ViewController.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/7/20.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var jobsTableView: UITableView!
    private let jobsViewModel = JobsViewModel()
    private var delegateDataSource : JobsTableViewDataSource<JobTableViewCell,JobData>!
    private let spinner = UIActivityIndicatorView(style: .large)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstSetup()
    }
    
    private func firstSetup() {
        addSpinnerInView()
        setupDataSourceAndDelegate()
        configureViewModel()
        jobsViewModel.getJobs()
    }
    
    private func addSpinnerInView() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.view.addSubview(self.spinner)
            self.spinner.center = self.view.center
        }
    }
    
}

// MARK: - Error handeling

extension ViewController {
    private func handleErrors(byResponseType type: ServerResponseType, dataCount: Int) {
        var buttonName: String!
        var alertAction: (()->())?
        
        if dataCount > 0 {
            buttonName = "ОК"
        } else {
            buttonName = "Попробуй еще раз"
            alertAction = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.addSpinnerInView()
                strongSelf.jobsViewModel.getJobs()
            }
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: type.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction(title: buttonName, style: .default) { action in
                alertAction?()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - DataSource, Delegate setups
extension ViewController {
    private func setupDataSourceAndDelegate() {
        delegateDataSource = JobsTableViewDataSource(cellIdentifier: "JobTableViewCellID", configureCell: { (cell, jobData) in
            cell.nameLabel.text = jobData.title
            cell.companyName.text = jobData.company
            cell.HowToApplyLabel.text = jobData.howToApply
        })
        jobsTableView.dataSource = delegateDataSource
        jobsTableView.delegate = delegateDataSource
        delegateDataSource.willShowPenultimateCell = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.jobsViewModel.errorResponseType != .NotData {
                strongSelf.jobsViewModel.getJobs()
                strongSelf.spinner.startAnimating()
                strongSelf.spinner.frame = CGRect(x: 0, y: 0, width: strongSelf.jobsTableView.frame.width, height: 40)
                strongSelf.jobsTableView.tableFooterView = strongSelf.spinner
                strongSelf.jobsTableView.tableFooterView?.isHidden = false
            }
        }
        delegateDataSource.didSelectCell = { [weak self] data in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(JobDetailsViewController.createByJobModel(job: data), animated: true)
        }
    }
}

extension ViewController {
    private func configureViewModel() {
        jobsViewModel.modelsDidLoaded = { [weak self] jobsData, responseType, needReloadtable, indexPaths, indexSet in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.spinner.stopAnimating()
                strongSelf.jobsTableView.tableFooterView = nil
            }
            
            if let type = responseType {
                strongSelf.handleErrors(byResponseType: type, dataCount: jobsData.count)
            } else {
                if needReloadtable {
                    strongSelf.delegateDataSource.changeItems(items: jobsData)
                    DispatchQueue.main.async {
                        strongSelf.jobsTableView.reloadData()
                    }
                } else {
                    // Check if have rows && sections for inserting
                    if let indexPaths = indexPaths, indexPaths.count > 0, let indexSet = indexSet {
                        // Cut data from 0 to old sections count for inserting cells
                        let createdData = Array(jobsData[0..<indexSet[indexSet.startIndex]])
                        
                        strongSelf.delegateDataSource.changeItems(items: createdData)
                        // Insert rows
                        DispatchQueue.main.async {
                            strongSelf.jobsTableView.beginUpdates()
                            strongSelf.jobsTableView.insertRows(at: indexPaths, with: .none)
                            strongSelf.jobsTableView.endUpdates()
                            // Insert sections
                            DispatchQueue.global().async {
                                strongSelf.delegateDataSource.changeItems(items: jobsData)
                                DispatchQueue.main.async {
                                    strongSelf.jobsTableView.insertSections(indexSet, with: .none)
                                }
                            }
                        }
                        
                    } else {
                        strongSelf.delegateDataSource.changeItems(items: jobsData)
                        // Check have rows for inserting
                        if let indexPaths = indexPaths, indexPaths.count > 0  {
                            DispatchQueue.main.async {
                                strongSelf.jobsTableView.beginUpdates()
                                strongSelf.jobsTableView.insertRows(at: indexPaths, with: .none)
                                strongSelf.jobsTableView.endUpdates()
                            }
                        }
                        // Check have sections for inserting
                        if let indexSet = indexSet {
                            DispatchQueue.main.async {
                                strongSelf.jobsTableView.beginUpdates()
                                strongSelf.jobsTableView.insertSections(indexSet, with: .none)
                                strongSelf.jobsTableView.endUpdates()
                            }
                        }
                    }
                    
                }
            }
        }
    }
}
