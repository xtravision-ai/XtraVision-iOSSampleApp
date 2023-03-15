//
//  ExerciseVC.swift
//  DemoApp
//
//  Created by XTRA on 25/10/22.
//
//
//  ExerciseVC.swift
//  DemoApp
//
//  Created by XTRA on 25/10/22.
//

import UIKit
import XtraVisionAI
import AVKit

class ExerciseVC : UIViewController, ReusableProtocol {
    
    //MARK:- static variable declaration
    static var instance: ExerciseVC {
        return findViewControllerIn(storyBoard: .main, identifier: ExerciseVC.reusableIdentifier) as! ExerciseVC
    }
    
    //MARK:- Variable declaration
    var assessment : String = ""
    private var xtraVisionMgr = XtraVisionAIManager.shared
    private var isPreJoin = true
    private var fullMessage = ""
    private var repsCounterView : RepetitionCounter!
    var lastRep = 0
    
    //MARK: Outlets
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var vwResponse: UIView!
    @IBOutlet weak var lblResponse: UITextView!
    @IBOutlet weak var vwrepsCounter: UIView!
    
    //MARK: View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialiseController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      stopSession()
    }
    
    //MARK: UIButton action methods
    @IBAction func btnClickOnSkip(_ sender: UIButton) {
        btnSkip.isHidden = true
//        if assessment == "HALF_SQUAT" {
//            vwrepsCounter.isHidden = false
//            vwResponse.isHidden = true
//            setRepsCounter()
//        } else {
            vwResponse.isHidden = false
            vwrepsCounter.isHidden = true
//        }
        isPreJoin = false
        xtraVisionMgr.disconnectSession()
        connectSession()
    }
    
    @IBAction func btnClickOnCancel(_ sender: UIButton) {
        stopSession()
        self.dismiss(animated: true)
    }
    
    //MARK: Common functions
    func initialiseController() {
        UIApplication.shared.isIdleTimerDisabled = true
        vwResponse.isHidden = true
//        if assessment == "HALF_SQUAT" {
//            vwrepsCounter.isHidden = true
//        }
        xtraVisionMgr.delegate = self
    }
    
    func connectSession() {
        let assessmentConfig = XtraVisionAssessmentConfig(5, grace_time_threshold: 5)
        let connectionData = XtraVisionConnectionData("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmNjNiOTE3Mi1mN2U0LTQyODItODgxNS1kNWNjYWUzYjE5Y2YiLCJhcHBJZCI6IjhkZWExNGJiLTRlYjMtMTFlZC04MjNiLTEyZmFiNGZmYWJlZCIsIm9yZ0lkIjoiODk5Y2I5NjAtNGViMy0xMWVkLTgyM2ItMTJmYWI0ZmZhYmVkIiwiaWF0IjoxNjc0ODAzNTAzLCJleHAiOjE2NzczOTU1MDN9.zSXmZkMiq3u5UMrOUaNR0T3BSsWEvxfR6Pm6GCGsDXo", assessmentName: assessment, assessmentConfig: assessmentConfig)

        let requestData = XtraVisionRequestData(isPreJoin)
        let skeletonConfig = XtraVisionSkeletonConfig(2.0, dotRadius: 4.0, lineColor: UIColor.red, dotColor: UIColor.blue)
        let libData = XtraVisionLibData(isSkeletonEnable, cameraView: cameraView, skeletonConfig: skeletonConfig)
        xtraVisionMgr.configureData(connectionData, requestData: requestData, libData: libData)
    }
    
    func stopSession() {
        xtraVisionMgr.disconnectSession()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func setRepsCounter() {
        lblResponse.isHidden = true
        repsCounterView = RepetitionCounter(frame : CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 200))
        repsCounterView.defaultRepsColor = UIColor.lightGray
        repsCounterView.filledRepsColor = UIColor.red
        self.vwrepsCounter.addSubview(repsCounterView)
    }
}

//MARK: XtraVisionAI Delegate method
extension ExerciseVC : XtraVisionAIDelegate {
    func onConnectSuccess() {
        print("Connection done successfully")
    }
    
    func onConnectFailed(_ string: String) {
        print("Connection failed: ", string)
    }
    
    func onConnectClose() {
        print("Connection closed")
    }
    
    func onMessageReceived(_ message: String) {
        print("message: \(message)")
        if let response = message.toJSON() as? [String : Any] {
            if isPreJoin {
                if let isPassed = response["isPassed"] as? Bool, isPassed == true {
//                    if assessment == "HALF_SQUAT" {
//                        vwrepsCounter.isHidden = false
//                        vwResponse.isHidden = true
//                        setRepsCounter()
//                    } else {
                        vwResponse.isHidden = false
                        vwrepsCounter.isHidden = true
//                    }
                    btnSkip.isHidden = true
                    isPreJoin = false
                    xtraVisionMgr.disconnectSession()
                    connectSession()
                }
            } else {
//                timeLeftLabel.text = "\(response["time_left"] as? Int ?? 999)"
//                if assessment == "HALF_SQUAT" {
//                    if let data = response["data"] as? [String : Any], let additional_response = data["additional_response"] as? [String : Any], let reps = additional_response["reps"] as? [String : Any], let total = reps["total"] as? Int {
//                        if lastRep != total {
//                            AudioManager.sharedInstance.resetFileName()
//                            AudioManager.sharedInstance.startMusic("sound_good_trigger", soundType: "wav")
//                        }
//                        repsCounterView.setReps(total)
//                    }
//                }
                let msg = message + "\n\n" + lblResponse.text
                lblResponse.text = msg
            }
//
        }
    }
}
