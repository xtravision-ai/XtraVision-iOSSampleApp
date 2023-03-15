//
//  MainViewController.swift
//  DemoApp
//
//  Created by XTRA on 14/10/22.
//

import UIKit

var isSkeletonEnable = true

class MainViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var btnSkeleton: UISwitch!
    @IBOutlet private weak var tblAssessmentList: UITableView!
    
    //MARK: Private variables
    private var assessmentArray = ["GLUTE_BRIDGE", "QUADS_STRETCH", "OVERHEAD_STRETCH", "SINGLE_LEG_KNEE_HUGS", "DOUBLE_LEG_KNEE_HUGS", "THORACIC_ROTATION", "PECTORAL_STRETCH", "BOW_AND_ARROW", "ROTATION_STRETCH", "HIP_FLEXOR_QUAD_STRETCH", "BANDED_ALTERNATING_DIAGNOLS", "SHOULDER_SCAPTION", "HALF_SQUAT", "KNEE_ROCKING", "NECK_FLEXORS", "BANDED_BOW_AND_ARROW", "BANDED_EXTERNAL_ROTATION", "BANDED_T", "BANDED_W", "BANDED_PASS_THROUGH", "SHOULDER_BLADE_SQUEEZE", "CARDIO"]
    
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
        content.text = assessmentArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let controller = ExerciseViewController.instance
        let controller = ExerciseVC.instance
        controller.modalPresentationStyle = .fullScreen
        controller.assessment = assessmentArray[indexPath.row]
        self.present(controller, animated: true, completion: nil)
    }
}
