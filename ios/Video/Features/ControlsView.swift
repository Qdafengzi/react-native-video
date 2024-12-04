import UIKit
import AVFoundation

protocol ControlsViewDelegate: AnyObject {
    func seekToTime(_ percentage: CGFloat, withRate rate: CGFloat)
    func pausePlayback()
    func resumePlayback()
}

class ControlsView: UIView {
    weak var delegate: ControlsViewDelegate?
    private var initialTouchPoint: CGPoint = CGPoint.zero
    private var lastSeekTime: Double = 0.0
       
    private var startTime: Date?
    var totalDuration: Double?
    private var currentPlayTime: Double?
    var _player: AVPlayer?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            delegate?.pausePlayback()
            initialTouchPoint = gesture.location(in: self)
            currentPlayTime = Double(CMTimeGetSeconds(_player!.currentTime()))
        case .changed:
            let currentTouchPoint = gesture.location(in: self)
            let screenWidth = UIScreen.main.bounds.width
            let distance = initialTouchPoint.x - currentTouchPoint.x
            
            if let totalDuration = totalDuration, let currentPlayTime = currentPlayTime {
                let percentage = distance / screenWidth * 2.0
                
                var seekTime = currentPlayTime + Double(percentage) * totalDuration
                if seekTime < 0 {
                    seekTime =  totalDuration + seekTime
                    delegate?.pausePlayback()
                } else if seekTime > totalDuration {
                    seekTime = seekTime - totalDuration
                    delegate?.pausePlayback()
                }

                
                delegate?.seekToTime(CGFloat(seekTime), withRate: 1.0)
            }
        case .ended, .cancelled:
            
            delegate?.resumePlayback()
            
        default:
            break
        }
        
    }
}
