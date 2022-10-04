// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Waveform/

import AVFoundation
import SwiftUI
import Waveform

class WaveformDemoModel: ObservableObject {
    var samples: SampleBuffer

    init(file: AVAudioFile) {
        let stereo = file.toFloatChannelData()!
        samples = SampleBuffer(samples: stereo[0])
    }
}

func getFile() -> AVAudioFile {
    let url = Bundle.main.url(forResource: "beat", withExtension: "aiff")!
    return try! AVAudioFile(forReading: url)
}

func clamp(_ x: Double, _ inf: Double, _ sup: Double) -> Double {
    max(min(x, sup), inf)
}

struct MinimapView: View {
    @Binding var start: Double
    @Binding var length: Double

    @GestureState var initialStart: Double?
    @GestureState var initialLength: Double?

    let indicatorSize = 10.0

    var body: some View {
        GeometryReader { gp in
            RoundedRectangle(cornerRadius: indicatorSize)
                .frame(width: length * gp.size.width)
                .offset(x: start * gp.size.width)
                .opacity(0.5)
                .gesture(DragGesture()
                    .updating($initialStart) { _, state, _ in
                        if state == nil {
                            state = start
                        }
                    }
                    .onChanged { drag in
                        if let initialStart = initialStart {
                            start = clamp(initialStart + drag.translation.width / gp.size.width, 0, 1 - length)
                        }
                    }
                )

            RoundedRectangle(cornerRadius: indicatorSize)
                .foregroundColor(.white)
                .frame(width: indicatorSize).opacity(0.3)
                .offset(x: (start + length) * gp.size.width)
                .padding(indicatorSize)
                .gesture(DragGesture()
                    .updating($initialLength) { _, state, _ in
                        if state == nil {
                            state = length
                        }
                    }
                    .onChanged { drag in
                        if let initialLength = initialLength {
                            length = clamp(initialLength + drag.translation.width / gp.size.width, 0, 1 - start)
                        }
                    }
                )
        }
    }
}

struct ContentView: View {
    @StateObject var model = WaveformDemoModel(file: getFile())

    @State var start = 0.0
    @State var length = 1.0

    let formatter = NumberFormatter()
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Waveform(samples: model.samples).foregroundColor(.cyan)
                MinimapView(start: $start, length: $length)
            }
            .frame(height: 100)
            .padding()
            Waveform(samples: model.samples,
                     start: Int(start * Double(model.samples.count - 1)),
                     length: Int(length * Double(model.samples.count)))
            .foregroundColor(.blue)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
