//
//  ReadingView.swift
//  WordsPerMinute
//
//  Created by CompSci01x on 6/11/21.
//

import SwiftUI
import AVFoundation
import Speech

struct TimerArc: Shape {
    
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 32.0
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.origin.x + rect.size.width / 2.0,
                             y: rect.origin.y + rect.size.height / 2.0)
        
        return Path { path in
            path.addArc(center: center,
                        radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        }
    }
}

struct ReadingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isEditViewPresented = false
    
    @State private var timerLengthInSec = 60.0
    @State private var timerRingColor = Color.blue
    @State private var timerRingCardColor = Color.green

    @State private var secondsElapsed = 0.00
    @State private var degreesToMove = 0.00
    @State private var isTimerRunning = false
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()


    private let speechRecognizer = SpeechRecognizer()
    
    @State private var transcript = ""
    @State private var isMicrophoneAccess = false;
    @State private var isSpeechRecording = false;
    
    @State private var transcriptCardColor = Color.blue
    @State private var isShowAlert = false
    
    
    func startTranscript() {
        isSpeechRecording = true
        transcript = ""
        speechRecognizer.record(to: $transcript)
    }
    
    func stopTranscript() {
        isSpeechRecording = false
        speechRecognizer.stopRecording()
    }
    
    func startTimer() {
        isTimerRunning = true
        secondsElapsed = 0.00
        degreesToMove = 0.00
        
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
        startTranscript()
    }
    
    func stopAndResetTimer() {
        isTimerRunning = false
        timer.upstream.connect().cancel()
        stopTranscript()
        
        isShowAlert = true
    }


    func isMicrophoneAccessGranted() {
        
        // Request permission to record.
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // The user granted access. Present recording interface.
            if granted {
                SFSpeechRecognizer.requestAuthorization { status in
                    if status == .authorized {
                        isMicrophoneAccess = true
                    } else {
                        isMicrophoneAccess = false
                        transcript = """
                                     Speech Recognition Access Denied.
                                     
                                     Go to Settings -> WordsPerMinute -> Speech Recognition
                                     """
                    }
                }
            } else {
                isMicrophoneAccess = false
                transcript = """
                             Mic Access Denied.
                             
                             Go to Settings -> WordsPerMinute -> Microphone
                             """
            }
        }
    }
    
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 50)
                .fill(timerRingCardColor)
            
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 50)
                        .fill(timerRingCardColor)
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .fill(timerRingCardColor)
                        
                            Circle()
                                .stroke(lineWidth: 10)
                                .fill(timerRingColor)
                                .padding()

                            VStack {
                                Button(action: {
                                    if !isTimerRunning && isMicrophoneAccess {
                                        startTimer()
                                    } else if isTimerRunning && isMicrophoneAccess {
                                        stopAndResetTimer()
                                    }
                                }) {
                                    Image(systemName: !isTimerRunning ? "play.fill" : "pause.fill")
                                        .font(.largeTitle)
                                        .padding()
                                        .foregroundColor(timerRingColor)
                                    }
                                
                                Text("\(String(format: "%.2f", secondsElapsed))")
                                    .font(.title)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .offset(x:3)
                            }
                        
                            TimerArc(startAngle: Angle(degrees: 0.0),
                                     endAngle: Angle(degrees: degreesToMove))
                                .stroke(lineWidth: 5)
                                .rotation(Angle(degrees: -90))
                                .fill(colorScheme == .dark ? Color.black : Color.white)
                            
                                .onReceive(timer, perform: { _ in
                                    if isTimerRunning {
                                        print("\(secondsElapsed)")
                                        secondsElapsed += 0.01
                                        degreesToMove += 360 / timerLengthInSec / 100
                                        
                                        if secondsElapsed >= timerLengthInSec {
                                            secondsElapsed = timerLengthInSec
                                            stopAndResetTimer()
                                        }
                                    }
                                })
                            }
                        }
                    }
                    .padding(10)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(transcriptCardColor)

                    ScrollView {
                        VStack(alignment: .leading) {
                            Divider()

                            HStack {
                                Text("Transcript")
                                    .font(.title)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)

                                Image(systemName: isSpeechRecording ? "mic.fill" : "mic.slash.fill")
                                    .font(.title)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            }

                            Text(transcript)
                                .frame(width: 290, height: 230, alignment: .topLeading)
                                .padding()
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                        }
                    }
                    .padding()
                }
                .padding(10)
                .onAppear() {
                    isMicrophoneAccessGranted()
                }
                
            }
        }
        .padding(10)
        .alert(isPresented: $isShowAlert, content: {
            var numOfWords = 0
            var uniqueWordCount: [String : Int] = [:]
            for word in transcript.split(separator: " ") {
                numOfWords += 1
                uniqueWordCount["\(word.lowercased())", default: 0] += 1
            }
            return Alert(title: Text("Words Per Minute"),
                         message: Text("\(numOfWords) Words in \(String(format: "%.2f", secondsElapsed)) sec!\n\(uniqueWordCount.count) Unique Words!"),
                         dismissButton: .default(Text("Got it!")))
        })
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button("Edit") {
            isEditViewPresented = true
        })
        .fullScreenCover(isPresented: $isEditViewPresented, content: {
            NavigationView {
                EditView(timerLengthInSec: $timerLengthInSec,
                         timerRingColor: $timerRingColor,
                         timerRingCardColor: $timerRingCardColor,
                         transcriptCardColor: $transcriptCardColor)
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarItems(leading: Button("Reset") {
                        isEditViewPresented = false
                        timerLengthInSec = 60.0
                        timerRingColor = Color.blue
                        timerRingCardColor = Color.green
                        transcriptCardColor = Color.blue
                    },trailing: Button("Done") {
                        isEditViewPresented = false
                    })
            }
        })
    }
        
}

struct ReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReadingView()
                .preferredColorScheme(.dark)
        }
    }
}
