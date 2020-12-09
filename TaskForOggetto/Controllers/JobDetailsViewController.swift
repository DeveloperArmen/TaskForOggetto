//
//  JobDetailsViewController.swift
//  TaskForOggetto
//
//  Created by Armen Alikhanyan on 12/9/20.
//

import UIKit

class JobDetailsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var howToApplyLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    private var jobData : JobData?
    
    class func createByJobModel(job: JobData) -> JobDetailsViewController {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "JobDetailsViewController") as JobDetailsViewController
        vc.jobData = job
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = jobData?.title
        companyLabel.text = jobData?.company
        howToApplyLabel.text = jobData?.howToApply
        informationLabel.text = jobData?.description
    }
    
    
}
