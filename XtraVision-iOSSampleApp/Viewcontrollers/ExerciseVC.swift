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
    var counterValue = 5
    var countdownTimer : Timer?
    private var intensityMeterView : IntensityMeterView!
    private var xtraVisionMgr = XtraVisionAIManager.shared
    private let authToken = "_AUTH_TOKEN_" //Add auth token you received
    private var isPreJoin = true
    private var fullMessage = ""
    private var repsCounterView : RepetitionCounter!
    private var timerView : TimeUnderLoadView!
    var lastRep = 0
    var reps_threshold = 10
    
    //MARK: Outlets
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var vwResponse: UIView!
    @IBOutlet weak var lblResponse: UITextView!
    @IBOutlet weak var vwrepsCounter: UIView!
    @IBOutlet weak var imgFrame: UIImageView!
    @IBOutlet weak var lblPowerValue: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
    
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
        xtraVisionMgr.disconnectSession(false)
        btnSkip.isUserInteractionEnabled = false
        imgFrame.isHidden = true
        btnSkip.isHidden = true
        startCountDown()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.onPreJoinCompleted()
        }
    }
    
    @IBAction func btnClickOnCancel(_ sender: UIButton) {
        stopSession()
        self.dismiss(animated: true)
    }
    
    //MARK: Common functions
    func initialiseController() {
        UIApplication.shared.isIdleTimerDisabled = true
        vwResponse.isHidden = true
        vwrepsCounter.isHidden = true
        xtraVisionMgr.delegate = self
    }
    
    func connectSession() {
        let assessmentConfig = XtraVisionAssessmentConfig(5, grace_time_threshold: 5, sets_threshold : -1)
        let connectionData = XtraVisionConnectionData(authToken, assessmentName: assessment, assessmentConfig: assessmentConfig)
        
        let requestData = XtraVisionRequestData(isPreJoin)
        let skeletonConfig = XtraVisionSkeletonConfig(2.0, dotRadius: 4.0, lineColor: UIColor.red, dotColor: UIColor.blue)
        let libData = XtraVisionLibData(isSkeletonEnable, cameraView: cameraView, skeletonConfig: skeletonConfig)
        xtraVisionMgr.configureData(connectionData, requestData: requestData, libData: libData)
    }
    
    func stopSession() {
        xtraVisionMgr.disconnectSession(true)
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
    
    func onPreJoinCompleted() {
        btnSkip.isUserInteractionEnabled = false
        imgFrame.isHidden = true
        btnSkip.isHidden = true
        isPreJoin = false
        connectSession()
        
        if assessment == "HALF_SQUAT" || assessment == "BANDED_ALTERNATING_DIAGNOLS" || assessment == "PUSH_UPS" || assessment == "SIT_UPS_T2" {
            vwrepsCounter.isHidden = false
            vwResponse.isHidden = true
            setRepsCounter()
        } else if assessment == "SIT_WALL" {
            vwrepsCounter.isHidden = false
            vwResponse.isHidden = true
            setTimeUnderLoadView()
        } else if assessment == "SIT_AND_REACH_T2" || assessment == "CARDIO" {
            vwrepsCounter.isHidden = false
            vwResponse.isHidden = true
            setIntensityMeter()
        } else {
            vwResponse.isHidden = false
            vwrepsCounter.isHidden = true
        }
    }
    
    func startCountDown() {
        lblCounter.isHidden = false
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.changeTextForCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func changeTextForCountdown() {
        counterValue -= 1
        lblCounter.text = "\(counterValue)"
        if counterValue == 0 {
            countdownTimer?.invalidate()
            lblCounter.isHidden = true
        }
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
                    imgFrame.image = UIImage(named: "imgCameraBlue")
                    self.xtraVisionMgr.disconnectSession(false)
                    startCountDown()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                        self?.imgFrame.isHidden = true
                        self?.onPreJoinCompleted()
                    }
                }
            } else {
                switch assessment {
                case "HALF_SQUAT", "BANDED_ALTERNATING_DIAGNOLS", "PUSH_UPS", "SIT_UPS_T2" :
                    if let data = response["data"] as? [String : Any], let additional_response = data["additional_response"] as? [String : Any], let reps = additional_response["reps"] as? [String : Any], let total = reps["total"] as? Int {

                        var repetitions = 0
                        if (total > 0 && total != lastRep) {
                            if total >= 10 {
                                repetitions = 10
                            } else {
                                repetitions = total
                            }
                            AudioManager.sharedInstance.resetFileName()
                            AudioManager.sharedInstance.startMusic("sound_good_trigger", soundType: ".wav")
                            lastRep = repetitions
                            repsCounterView.setReps(repetitions)
                        }
                    }
                case "SIT_WALL":
                    if let data = response["data"] as? [String : Any], let additional_response = data["additional_response"] as? [String : Any], let seconds = additional_response["seconds"] as? Int {
                        if reps_threshold - seconds > 0 {
                            timerView.setTimeUnderLoad(reps_threshold - seconds)
                        }
                    }
                case "SIT_AND_REACH_T2":
                    if let data = response["data"] as? [String : Any], let additional_response = data["additional_response"] as? [String : Any], let reps = additional_response["reps"] as? [String : Any], let max_score = reps["max_score"] as? Int {
                        lblPowerValue.text = "Value: \(max_score)"
                        intensityMeterView.setIntensity(Float(max_score))
                    }
                case "CARDIO":
                    if let data = response["data"] as? [String : Any], let power_list = data["power_list"] as? [Int], power_list.count > 0 {
                        lblPowerValue.text = "Value: \(power_list[0])"
                        intensityMeterView.setIntensity(Float(power_list[0]))
                    }
                default:
                    break
                }
                let msg = message + "\n\n" + lblResponse.text
                lblResponse.text = msg
            }
        } else {
            switch assessment {
            case "HALF_SQUAT", "BANDED_ALTERNATING_DIAGNOLS", "PUSH_UPS", "SIT_UPS_T2", "SIT_WALL" :
                break
            case "SIT_AND_REACH_T2", "CARDIO":
                break
//                if !isPreJoin {
//                    lblPowerValue.text = "Value: \(0)"
//                    intensityMeterView.setIntensity(Float(0))
//                }
            default:
                break
            }
        }
    }
}
