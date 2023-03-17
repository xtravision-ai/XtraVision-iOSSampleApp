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
    private let authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJkOTU1NTVkNS0wNmFhLTExZWQtOGJkYy0xMmZhYjRmZmFiZWQiLCJhcHBJZCI6IjY5YTdmMmU2LTA2YWEtMTFlZC04YmRjLTEyZmFiNGZmYWJlZCIsIm9yZ0lkIjoiNmQ5MWZlN2YtMDZhOS0xMWVkLThiZGMtMTJmYWI0ZmZhYmVkIiwiaWF0IjoxNjYwMTA3MjI0LCJleHAiOjE2OTE2NjQ4MjR9._i4MJbwPznHzxoStcRAcK7N7k_xGdUjvKwmHXv1zixM" //Add auth token you received
    private var isPreJoin = true
    private var fullMessage = ""
    private var repsCounterView : RepetitionCounter!
    private var intensityMeterView : IntensityMeterView!
    private var timerView : TimeUnderLoadView!
    var lastRep = 0
    var reps_threshold = 10
    
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
        xtraVisionMgr.disconnectSession()
        btnSkip.isHidden = true
        if assessment == "HALF_SQUAT" {
            vwrepsCounter.isHidden = false
            vwResponse.isHidden = true
            setRepsCounter()
        } else if assessment == "GLUTE_BRIDGE" {
            vwrepsCounter.isHidden = false
            vwResponse.isHidden = true
            setTimeUnderLoadView()
        } else if assessment == "CARDIO" {
            vwrepsCounter.isHidden = false
            vwResponse.isHidden = true
            setIntensityMeter()
        } else {
            vwResponse.isHidden = false
            vwrepsCounter.isHidden = true
        }
        isPreJoin = false
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
        if assessment == "HALF_SQUAT" || assessment == "GLUTE_BRIDGE" || assessment == "CARDIO" {
            vwrepsCounter.isHidden = true
        }
        xtraVisionMgr.delegate = self
    }
    
    func connectSession() {
        let assessmentConfig = XtraVisionAssessmentConfig(5, grace_time_threshold: 5)
        let connectionData = XtraVisionConnectionData(authToken, assessmentName: assessment, assessmentConfig: assessmentConfig)

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
    
    func setIntensityMeter() {
        lblResponse.isHidden = true
        intensityMeterView = IntensityMeterView(frame : CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 200))
        self.vwrepsCounter.addSubview(intensityMeterView)
    }
    
    func setTimeUnderLoadView() {
        lblResponse.isHidden = true
        timerView = TimeUnderLoadView(frame : CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 200))
        timerView.totleSeconds = reps_threshold
        timerView.progressTextColor = UIColor.black
//        timerView.gradientColors =
        self.vwrepsCounter.addSubview(timerView)
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
                    if assessment == "HALF_SQUAT" {
                        vwrepsCounter.isHidden = false
                        vwResponse.isHidden = true
                        setRepsCounter()
                    } else if assessment == "CARDIO" {
                        vwrepsCounter.isHidden = false
                        vwResponse.isHidden = true
                        setIntensityMeter()
                    } else if assessment == "GLUTE_BRIDGE" {
                        vwrepsCounter.isHidden = false
                        vwResponse.isHidden = true
                        setTimeUnderLoadView()
                    } else {
                        vwResponse.isHidden = false
                        vwrepsCounter.isHidden = true
                    }
                    btnSkip.isHidden = true
                    isPreJoin = false
                    xtraVisionMgr.disconnectSession()
                    connectSession()
                }
            } else {
//                timeLeftLabel.text = "\(response["time_left"] as? Int ?? 999)"
                if assessment == "HALF_SQUAT" {
                    if let data = response["data"] as? [String : Any], let additional_response = data["additional_response"] as? [String : Any], let reps = additional_response["reps"] as? [String : Any], let total = reps["total"] as? Int {
                        if lastRep != total {
                            AudioManager.sharedInstance.resetFileName()
                            AudioManager.sharedInstance.startMusic("sound_good_trigger", soundType: "wav")
                        }
                        repsCounterView.setReps(total)
                    }
                } else if assessment == "GLUTE_BRIDGE" {
                    if let data = response["data"] as? [String : Any], let additional_response = data["additional_response"] as? [String : Any], let seconds = additional_response["seconds"] as? Int {
                        timerView.setTimeUnderLoad(reps_threshold - seconds)
                    }
                } else if assessment == "CARDIO" {
                    if let data = response["data"] as? [String : Any], let power_list = data["power_list"] as? [Int], power_list.count > 0 {
                        intensityMeterView.setIntensity(Float(power_list[0]))
                    }
                }
                let msg = message + "\n\n" + lblResponse.text
                lblResponse.text = msg
            }
//
        }
    }
}
