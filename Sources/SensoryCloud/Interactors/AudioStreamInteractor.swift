//
//  AudioStreamInteractor.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import AVFoundation

public enum AudioStreamError: Error {
    case failedToConfigure
    case failedToFindAudioComponent
    case failedToFindMicrophoneUnit
    case notConfigured
}

public protocol AudioStreamDelegate: AnyObject {
    /// This will be called periodically with new audio stream data when the interactor is recording
    func didProcessAudio(_ data: Data)
}

public class AudioStreamInteractor {
    var microphoneUnit: AudioComponentInstance?
    public weak var delegate: AudioStreamDelegate?
    var configured = false

    public static var shared = AudioStreamInteractor()
    private init() {}

    // Bus 1 is audio input
    private let bus1: AudioUnitElement = 1

    deinit {
        _ = microphoneUnit.map { AudioComponentInstanceDispose($0) }
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
    public func startRecording() throws {
        if !configured { throw AudioStreamError.notConfigured }
        guard let microphoneUnit = self.microphoneUnit else {
            throw AudioStreamError.failedToFindMicrophoneUnit
        }
        AudioOutputUnitStart(microphoneUnit)
    }

    /// Stops the audio recording
    public func stopRecording() {
        guard let microphoneUnit = self.microphoneUnit else { return }
        AudioOutputUnitStop(microphoneUnit)
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
        // TODO: config
        streamDescription.mSampleRate = 16000
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
        NSLog("Shared audio stream interactor is missing reference to microphone unit")
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
        } else {
            NSLog("No data received from audio stream callback")
        }
    }

    return noErr
}
