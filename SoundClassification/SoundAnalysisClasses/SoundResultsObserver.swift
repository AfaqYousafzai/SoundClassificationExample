//
//  SoundResultsObserver.swift
//  SoundClassification
//
//  Created by Afaq Ahmad on 3/14/22.
//

import Foundation
import SoundAnalysis


class SoundResultsObserver: NSObject, SNResultsObserving {
    
    var delegate : ClassificationUpdate?
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        guard let result = result as? SNClassificationResult else  { return }
        
        guard let classification = result.classifications.first else { return }
        
        let timeInSeconds = result.timeRange.start.seconds
        
        let formattedTime = String(format: "%.2f", timeInSeconds)
        print("Analysis result for audio at time: \(formattedTime)")
        
        let confidence = classification.confidence * 100.0
        let percentString = String(format: "%.2f%%", confidence)
        
        print("\(classification.identifier): \(percentString) confidence.\n")
        self.delegate?.updatingLbl(value: "\(classification.identifier): \(percentString) confidence.\n")
        
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
