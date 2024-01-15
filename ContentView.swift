//
//  ContentView.swift
//  sentimentanalysis
//
//  Created by harry hammonds on 2023-08-29.
//  MIT LICENCE

import SwiftUI
import CoreML

struct ContentView: View {
    
    @ObservedObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var iconType = "mic"
    @State private var placeholderTranscript = "Press mic to start..."
    @State private var sentiment = ""
    
    let model = try? sentimentanalysis(configuration: MLModelConfiguration())

    
    var body: some View {
        VStack {
            VStack {
                Text("\(sentiment)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(sentimentColor)
                Spacer()
                Text(speechRecognizer.transcript ?? placeholderTranscript)
                    .multilineTextAlignment(.leading)
                    .frame(width: 300)
                Spacer()
                VStack {
                    if iconType == "stop" {
//                        Image(systemName: "clear")
//                            .foregroundColor(Color.gray)
//                            .imageScale(.medium)
//                            .foregroundStyle(.tint)
                        
                        Button("Clear") {
                            placeholderTranscript = ""
                        }
                            .foregroundColor(Color.gray)
                    }
                    
                }
                

            }
            .frame(height: 500)
            Spacer()
            ZStack {
                
                Image(systemName: "circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.red)
                    .padding(.all)
                    .foregroundStyle(.tint)
                
                Image(systemName: iconType)
                    .foregroundColor(Color.red)
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }
            .onTapGesture(perform: {
                
                if iconType == "mic" {
                    start()
                    iconType = "stop"
                } else {
                    stop()
                    iconType = "mic"
                }
                
            })
            
            Spacer()
                .frame(height: 60)
        }
        .padding()
        .onChange(of: speechRecognizer.transcript) { newValue in
            if let newTranscript = newValue, let newSentiment = analyzeSentiment(transcriptText: newTranscript) {
                        sentiment = newSentiment
                    }
                }
        
        var sentimentColor: Color {
            switch sentiment {
                case "assertive": return .green
                case "aggressive": return .red
                case "passiveaggressive": return .orange
                case "passive": return .teal
                default: return .gray
            }
        }

    }
    
    
    private func start() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
        placeholderTranscript = "Start talking..."
    }
    
    private func stop() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        placeholderTranscript = "Press mic to start..."
    }
    
    func analyzeSentiment(transcriptText: String) -> String? {
        guard let model = model else {
            return "Model not loaded"
        }
        
        let modelInput = sentimentanalysisInput(text: transcriptText)

        do {
            let modelOutput = try model.prediction(input: modelInput)
            return modelOutput.label
        } catch {
            return "Prediction failed: \(error)"
        }
    }


}

#Preview {
    ContentView()
}
