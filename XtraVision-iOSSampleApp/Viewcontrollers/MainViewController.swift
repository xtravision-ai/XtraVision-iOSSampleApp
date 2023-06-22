//
//  MainViewController.swift
//  DemoApp
//
//  Created by XTRA on 14/10/22.
//

import UIKit

var isSkeletonEnable = true

struct Assessment {
    var title : String
    var code : String
}

class MainViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var btnSkeleton: UISwitch!
    @IBOutlet private weak var tblAssessmentList: UITableView!
    
//    SIT_UPS_T2
    //MARK: Private variables
    private var assessmentArray = [Assessment(title: "Squats", code: "SQUATS_T2"), Assessment(title: "Banded Diagonal", code: "BANDED_ALTERNATING_DIAGNOLS"), Assessment(title: "Plank", code: "PLANK"), Assessment(title: "Push Ups", code: "PUSH_UPS"), Assessment(title: "Glute Bridge", code: "GLUTE_BRIDGE"), Assessment(title: "Cardio", code: "CARDIO"), Assessment(title: "Shoulder Abduction", code: "RANGE_OF_MOTION")]
    
    //MARK: View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSkeletonOnOff(_ sender: UISwitch) {
//        sender.isOn = !sender.isOn
        if sender.isOn {
            isSkeletonEnable = true
        } else {
            isSkeletonEnable = false
        }
    }
    
}

extension MainViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assessmentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = assessmentArray[indexPath.row].title
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let controller = ExerciseViewController.instance
        let controller = ExerciseVC.instance
        controller.modalPresentationStyle = .fullScreen
        controller.assessment = assessmentArray[indexPath.row].code
        self.present(controller, animated: true, completion: nil)
    }
}
