//
//  ViewController.swift
//  SoundClassification
//
//  Created by Afaq Ahmad on 3/12/22.
//

import UIKit
import AVFAudio
import SoundAnalysis

protocol ClassificationUpdate {
    func updatingLbl(value: String)
}

class ViewController: UIViewController, ClassificationUpdate {
    
    @IBOutlet weak var confidenceLbl: UILabel!
    
    private let audioEngine: AVAudioEngine = AVAudioEngine()
    private let inputBus: AVAudioNodeBus = AVAudioNodeBus(0)
    private var inputFormat: AVAudioFormat!
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private let resultsObserver = SoundResultsObserver()
    private let analysisQueue = DispatchQueue(label: "com.example.AnalysisQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        
        do {
            try audioEngine.start()
            
            audioEngine.inputNode.installTap(onBus: inputBus,
                                             bufferSize: 8192,
                                             format: inputFormat, block: analyzeAudio(buffer:at:))
            
            streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
            
            let request = try SNClassifySoundRequest(classifierIdentifier: SNClassifierIdentifier.version1)
            
            resultsObserver.delegate = self
            try streamAnalyzer.add(request,
                                   withObserver: resultsObserver)
            
            
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            self.streamAnalyzer.analyze(buffer,
                                        atAudioFramePosition: time.sampleTime)
        }
    }
    
    func updatingLbl(value: String) {
        DispatchQueue.main.async {
            self.confidenceLbl.text = value
        }
    }
    
}

