//
//  VideoProcessor.swift
//  SpacialCompute
//
//  Created by cccc on 2024/3/17.
//

import VideoToolbox
import ARKit

class VideoProcessor {
    
    /// The compression session to encode image buffers before sending.
    private var compressionSession: VTCompressionSession!
    
    /// The decompression session to decode image buffer after receiving.
    private var decompressionSession: VTDecompressionSession!
    
    /// The current format description that the decompressionSession uses.
    private var currentFormatDescription: CMFormatDescription?
    
    /// Compresses an image buffer and sends it using the caller's handler.
    private func compressAndSend(imageBuffer: CVImageBuffer, presentationTimeStamp: CMTime, arFrame: ARFrame, sendHandler: @escaping (Data) -> Void) {
        
        // Create the compression session
        
        if compressionSession == nil {
            
            // Compute the desired image dimensions.
            let frameWidth = Float(CVPixelBufferGetWidth(imageBuffer))
            let frameHeight = Float(CVPixelBufferGetHeight(imageBuffer))
            
            var videoWidth = Int32(frameWidth)
            var videoHeight = Int32(frameHeight)
            
            // Make sure that the videoWidth and videoHeight are even values.
            if !videoWidth.isMultiple(of: 2) { videoWidth += 1 }
            
            if !videoHeight.isMultiple(of: 2) { videoHeight += 1 }
            
            let status = VTCompressionSessionCreate(allocator: nil,
                                                    width: videoWidth,
                                                    height: videoHeight,
                                                    codecType: kCMVideoCodecType_HEVC,
                                                    encoderSpecification: nil,
                                                    imageBufferAttributes: nil,
                                                    compressedDataAllocator: nil,
                                                    outputCallback: nil,
                                                    refcon: nil,
                                                    compressionSessionOut: &compressionSession)
            
            if status != noErr {
                print("Failed to create compression session.")
                return
            }
            VTSessionSetProperty(compressionSession,
                                 key: kVTCompressionPropertyKey_RealTime,
                                 value: kCFBooleanTrue)
            
        }
        
        // COmpress the image data.
        VTCompressionSessionEncodeFrame(compressionSession,
                                        imageBuffer: imageBuffer,
                                        presentationTimeStamp: presentationTimeStamp,
                                        duration: .invalid,
                                        frameProperties: nil,
                                        infoFlagsOut: nil) { status, _, sampleBuffer in
            
            // Return early if compression fails.
            guard status == noErr, let sampleBuffer = sampleBuffer else {
                print("Compression Failed for frame \(presentationTimeStamp)")
                return
            }
            
            // Serialize the compressed sample buffer for sending.
            let videoFrameData = VideoFrameData(sampleBuffer: sampleBuffer, arFrame: arFrame)
            
            // Encode into JSON.
            do {
                let data = try JSONEncoder().encode(videoFrameData)
                // Invoke the caller's handler to send the data.
                sendHandler(data)
            } catch {
                fatalError("Failed to encode videoFrameData as JSON with error: " + error.localizedDescription)
            }
            
        }
        
    }
    
    /// An overload of compressAndSend to accept CMSampleBuffers.
    ///- Tag: CompressAndSend
    func compressAndSend(_ sampleBuffer: CMSampleBuffer, arFrame: ARFrame, sendHandler: @escaping (Data) -> Void) {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            compressAndSend(imageBuffer: imageBuffer,
                            presentationTimeStamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer),
                            arFrame: arFrame,
                            sendHandler: sendHandler)
        }
    }
    
    /// Decompresses a received image buffer and renders it using the caller's handler.
    ///- Tag: DecompressSampleBuffer
    func decompress(_ sampleBuffer: CMSampleBuffer, decompressionHandler: @escaping (CVImageBuffer, CMTime) -> Void) {
        
        // Reconstruct a sample buffer from the received data.
        guard let formatDescription = sampleBuffer.formatDescription else { return }
        
        // Create the decompression session, if necessary.
        if decompressionSession == nil {
            createDecompressionSession(with: formatDescription)
        }
        
        if currentFormatDescription != formatDescription && !VTDecompressionSessionCanAcceptFormatDescription(decompressionSession, formatDescription: formatDescription) {
            createDecompressionSession(with: formatDescription)
        }
        
        // Decompress the image data.
        VTDecompressionSessionDecodeFrame(decompressionSession,
                                          sampleBuffer: sampleBuffer,
                                          flags: [],
                                          infoFlagsOut: nil) { (status,infoFlags,imageBuffer,taggedBuffers,presentationTimeStamp,presentationDuration) in
                
            if let imageBuffer = imageBuffer {
                decompressionHandler(imageBuffer, presentationTimeStamp)
            }
            
        }
        
    }
    
    
    private func createDecompressionSession(with formatDescription: CMFormatDescription) {
        let status = VTDecompressionSessionCreate(allocator: nil,
                                                  formatDescription: formatDescription,
                                                  decoderSpecification: nil,
                                                  imageBufferAttributes: nil,
                                                  outputCallback: nil,
                                                  decompressionSessionOut: &decompressionSession)
        
        // Return early if unable to create the decompression session.
        if status != noErr {
            print("Failed to create decompression session.")
            return
        }
        
        VTSessionSetProperty(decompressionSession, key: kVTDecompressionPropertyKey_RealTime, value: kCFBooleanTrue)
        currentFormatDescription = formatDescription
    }
    
}
