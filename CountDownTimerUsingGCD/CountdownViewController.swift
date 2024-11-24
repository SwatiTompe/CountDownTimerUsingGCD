//
//  ViewController.swift
//  CountDownTimerUsingGCD
//
//  Created by Admin on 24/11/24.
//

import UIKit

class CountdownViewController: UIViewController {

    // MARK: - Properties
        var countdownTime: Int = 10 // Initial countdown time in seconds
        var remainingTime: Int = 10 // Current time remaining
        var timer: DispatchSourceTimer? // Background timer
        var isRunning = false // Timer state
        var isTimerSuspended = false // To track suspension state

    
    // MARK: - UI Elements
       let timerLabel: UILabel = {
           let label = UILabel()
           label.text = "10"
           label.font = UIFont.boldSystemFont(ofSize: 48)
           label.textAlignment = .center
           return label
       }()
    
    let startPauseButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Start", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            return button
        }()
    
    let resetButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Reset", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            return button
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    func setupUI() {
            view.backgroundColor = .white
            view.addSubview(timerLabel)
            view.addSubview(startPauseButton)
            view.addSubview(resetButton)
            
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            startPauseButton.translatesAutoresizingMaskIntoConstraints = false
            resetButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
                
                startPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                startPauseButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
                
                resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                resetButton.topAnchor.constraint(equalTo: startPauseButton.bottomAnchor, constant: 10)
            ])
        }
    
    // MARK: - Button Actions
        func setupActions() {
            startPauseButton.addTarget(self, action: #selector(startPauseTapped), for: .touchUpInside)
            resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        }
    
    @objc func startPauseTapped() {
            if isRunning {
                pauseTimer()
                startPauseButton.setTitle("Start", for: .normal)
            } else {
                startTimer()
                startPauseButton.setTitle("Pause", for: .normal)
            }
        }
    
    @objc func resetTapped() {
            resetTimer()
            startPauseButton.setTitle("Start", for: .normal)
        }
    
    // MARK: - Timer Logic
        func startTimer() {
            
            // Avoid starting a new timer if one is already running
                guard !isRunning else { return }
            
            // Ensure any existing timer is resumed before cancellation
                if let existingTimer = timer {
                    if isTimerSuspended {
                        existingTimer.resume() // Resume the timer if suspended
                        isTimerSuspended = false
                    }
                    existingTimer.cancel() // Cancel the timer safely
                }
            
            // Create a new timer
            timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer?.schedule(deadline: .now(), repeating: 1.0)
            
            timer?.setEventHandler { [weak self] in
                guard let self = self else { return }
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                    DispatchQueue.main.async {
                        self.updateLabel()
                    }
                } else {
                    self.timer?.cancel()
                    self.timer = nil
                    self.isRunning = false
                    remainingTime = countdownTime //Reset to the original time
                    DispatchQueue.main.async {
                        self.updateLabel()
                        self.startPauseButton.setTitle("Start", for: .normal)
                    }
                }
            }
            
            timer?.resume()
            isRunning = true
        }
    
    func pauseTimer() {
            if isRunning {
                timer?.suspend() // Suspend the timer
                isTimerSuspended = true
                isRunning = false
            }
        }
        
        func resetTimer() {
        // Cancel the timer safely, ensuring it's not suspended
            if let existingTimer = timer {
                if isTimerSuspended {
                    existingTimer.resume() //resume before cancellation
                    isTimerSuspended = false
                }
                existingTimer.cancel()
            }
            timer = nil //clear the timer reference
            remainingTime = countdownTime //Reset to the original time
            isRunning = false
            
            DispatchQueue.main.async {
                self.updateLabel()
                self.startPauseButton.setTitle("Start", for: .normal)
            }
        }
    
    // MARK: - UI Updates
       func updateLabel() {
           timerLabel.text = "\(remainingTime)"
       }


}

