
import Foundation
import AVFoundation

enum Sound: String {
    case hit, jump, levelUp, meteorFalling, reward

    var fileName: String {
        return rawValue + "Sound.wav"
    }
}
