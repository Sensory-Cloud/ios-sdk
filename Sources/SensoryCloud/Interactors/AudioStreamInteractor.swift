//
//  AudioStreamInteractor.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import AVFoundation

/// Delegate class for receiving processed audio data
public protocol AudioStreamDelegate: AnyObject {
    /// This will be called periodically with new audio stream data when the interactor is recording
    func didProcessAudio(_ data: Data)
}

/// Class for getting a stream of audio data from the device's microphone
public class AudioStreamInteractor {
    var microphoneUnit: AudioComponentInstance?
    var configured = false

    private init() {}

    /// Shared instance
    public static var shared = AudioStreamInteractor()

    /// Delegate to receive audio data
    public weak var delegate: AudioStreamDelegate?

    // Bus 1 is audio input
    private let bus1: AudioUnitElement = 1

    deinit {
        _ = microphoneUnit.map { AudioComponentInstanceDispose($0) }
    }

    /// Requests permission to record audio data from the user
    ///
    /// The app must contain a purpose string in the `Info.plist` file with the key `NSMicrophoneUsageDescription` for the system to allow microphone permissions
    /// This function will also configure the audio recording and thus *must* be called every time the app launches before attempting to record any audio data
    /// - Parameters:
    ///   - completion: Completion block to be called after permissions have been granted/denied by the system
    ///   - Bool: A boolean indicating if microphone permissions are allowed
    ///   - Error: An error if one occurred while setting up configurations for audio recording
    public func requestPermission(completion: ((Bool, Error?) -> Void)? = nil) {
        let session = AVAudioSession.sharedInstance()

        session.requestRecordPermission { [weak self] allowed in
            if allowed {
                do {
                    try self?.configure()
                    completion?(true, nil)
                } catch {
                    completion?(true, error)
                }
            } else {
                completion?(false, nil)
            }
        }
    }

    /// Starts audio recording
    ///
    /// Processed audio is passed back via the `AudioStreamDelegate`
    /// - Throws: `AudioStreamError.notConfigured` if configuration has not occurred yet. Call `requestPermissions` to configure the `AudioStreamInteractor` for recording
    public func startRecording() throws {
        if !configured { throw AudioStreamError.notConfigured }
        guard let microphoneUnit = self.microphoneUnit else {
            throw AudioStreamError.failedToFindMicrophoneUnit
        }
        AudioOutputUnitStart(microphoneUnit)
    }

    /// Stops audio recording
    public func stopRecording() {
        guard let microphoneUnit = self.microphoneUnit else { return }
        AudioOutputUnitStop(microphoneUnit)
    }

    /// Configures the interactor for audio recording
    ///
    /// This function should only be called once for the lifetime of the app
    private func configure() throws {
        try configureAudioSession()

        var audioComponentDescription = self.describeComponent()

        guard let remoteIOComponent = AudioComponentFindNext(nil, &audioComponentDescription) else {
            throw AudioStreamError.failedToFindAudioComponent
        }

        AudioComponentInstanceNew(remoteIOComponent, &microphoneUnit)

        try configureMicrophoneForInput()
        try setFormatForMicrophone()
        try setCallback()

        if let microphoneUnit = microphoneUnit {
            let status = AudioUnitInitialize(microphoneUnit)
            if status != noErr {
                throw AudioStreamError.failedToConfigure
            }
        }

        configured = true
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record)
        try session.setPreferredIOBufferDuration(10)
    }

    private func describeComponent() -> AudioComponentDescription {
        var description = AudioComponentDescription()
        description.componentType = kAudioUnitType_Output
        description.componentSubType = kAudioUnitSubType_RemoteIO
        description.componentManufacturer = kAudioUnitManufacturer_Apple
        description.componentFlags = 0
        description.componentFlagsMask = 0
        return description
    }

    private func configureMicrophoneForInput() throws {
        guard let microphoneUnit = self.microphoneUnit else {
            throw AudioStreamError.failedToFindMicrophoneUnit
        }

        var oneFlag: UInt32 = 1

        let status = AudioUnitSetProperty(
            microphoneUnit,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            bus1,
            &oneFlag,
            UInt32(MemoryLayout<UInt32>.size)
        )

        if status != noErr {
            throw AudioStreamError.failedToConfigure
        }

    }

    private func setFormatForMicrophone() throws {
        guard let microphoneUnit = self.microphoneUnit else {
            throw AudioStreamError.failedToFindMicrophoneUnit
        }

        var streamDescription = AudioStreamBasicDescription()
        streamDescription.mSampleRate = Config.audioSampleRate
        streamDescription.mFormatID = kAudioFormatLinearPCM
        streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
        streamDescription.mBytesPerPacket = 2
        streamDescription.mFramesPerPacket = 1
        streamDescription.mBytesPerFrame = 2
        streamDescription.mChannelsPerFrame = 1
        streamDescription.mBitsPerChannel = 16

        let status = AudioUnitSetProperty(
            microphoneUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Output,
            bus1,
            &streamDescription,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        )
        if status != noErr {
            throw AudioStreamError.failedToConfigure
        }
    }

    private func setCallback() throws {
        guard let microphoneUnit = self.microphoneUnit else {
            throw AudioStreamError.failedToFindMicrophoneUnit
        }

        var callbackStruct = AURenderCallbackStruct()
        callbackStruct.inputProc = recordingCallback
        callbackStruct.inputProcRefCon = nil
        let status = AudioUnitSetProperty(
            microphoneUnit,
            kAudioOutputUnitProperty_SetInputCallback,
            kAudioUnitScope_Global,
            bus1,
            &callbackStruct,
            UInt32(MemoryLayout<AURenderCallbackStruct>.size)
        )
        if status != noErr {
            throw AudioStreamError.failedToConfigure
        }
    }
}

/// Callback function meant to be called by `AVFoundation` This function is not intended to be called manually
func recordingCallback(
    ifRefCon: UnsafeMutableRawPointer,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus {

    var status = noErr

    let channelCount: UInt32 = 1

    var bufferList = AudioBufferList()
    bufferList.mNumberBuffers = channelCount

    withUnsafeMutablePointer(to: &bufferList.mBuffers) { pointer -> Void in
        let buffers = UnsafeMutableBufferPointer<AudioBuffer>( start: pointer, count: Int(bufferList.mNumberBuffers))

        buffers[0].mNumberChannels = 1
        buffers[0].mDataByteSize = inNumberFrames * 2
        buffers[0].mData = nil
    }

    guard let remoteIOUnit = AudioStreamInteractor.shared.microphoneUnit else {
        return AVFoundation.errSecCallbackFailed
    }
    status = AudioUnitRender(remoteIOUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList)
    if status != noErr {
        return status
    }

    withUnsafeMutablePointer(to: &bufferList.mBuffers) { pointer -> Void in
        let buffers = UnsafeMutableBufferPointer<AudioBuffer>( start: pointer, count: Int(bufferList.mNumberBuffers))

        if let bytes = buffers[0].mData {
            let data = Data(bytes: bytes, count: Int(buffers[0].mDataByteSize))
            DispatchQueue.main.async {
                AudioStreamInteractor.shared.delegate?.didProcessAudio(data)
            }
        }
    }

    return noErr
}
