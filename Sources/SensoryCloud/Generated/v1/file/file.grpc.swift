//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: v1/file/file.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// Handles all file-related functions
///
/// Usage: instantiate `Sensory_Api_V1_File_FileClient`, then call methods of this protocol to make API calls.
public protocol Sensory_Api_V1_File_FileClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Sensory_Api_V1_File_FileClientInterceptorFactoryProtocol? { get }

  func getInfo(
    _ request: Sensory_Api_V1_File_FileRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileInfo>

  func getCatalog(
    _ request: Sensory_Api_V1_File_FileCatalogRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_File_FileCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse>

  func getCompleteCatalog(
    _ request: Sensory_Api_V1_File_FileCompleteCatalogRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_File_FileCompleteCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse>

  func download(
    _ request: Sensory_Api_V1_File_FileRequest,
    callOptions: CallOptions?,
    handler: @escaping (Sensory_Api_V1_File_FileResponse) -> Void
  ) -> ServerStreamingCall<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileResponse>
}

extension Sensory_Api_V1_File_FileClientProtocol {
  public var serviceName: String {
    return "sensory.api.v1.file.File"
  }

  /// Allows a client to request information about a file in the cloud.
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetInfo.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getInfo(
    _ request: Sensory_Api_V1_File_FileRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileInfo> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.file.File/GetInfo",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetInfoInterceptors() ?? []
    )
  }

  /// Allows a client to request a list of all the files it is allowed to access
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetCatalog.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getCatalog(
    _ request: Sensory_Api_V1_File_FileCatalogRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_File_FileCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.file.File/GetCatalog",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetCatalogInterceptors() ?? []
    )
  }

  /// Allows a root client to request the full list of files
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetCompleteCatalog.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getCompleteCatalog(
    _ request: Sensory_Api_V1_File_FileCompleteCatalogRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_File_FileCompleteCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.file.File/GetCompleteCatalog",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetCompleteCatalogInterceptors() ?? []
    )
  }

  /// Allows a client to request a file from the cloud.
  /// Download streams a FileResponse until the entire file is downloaded
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to Download.
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  public func download(
    _ request: Sensory_Api_V1_File_FileRequest,
    callOptions: CallOptions? = nil,
    handler: @escaping (Sensory_Api_V1_File_FileResponse) -> Void
  ) -> ServerStreamingCall<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileResponse> {
    return self.makeServerStreamingCall(
      path: "/sensory.api.v1.file.File/Download",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDownloadInterceptors() ?? [],
      handler: handler
    )
  }
}

public protocol Sensory_Api_V1_File_FileClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'getInfo'.
  func makeGetInfoInterceptors() -> [ClientInterceptor<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileInfo>]

  /// - Returns: Interceptors to use when invoking 'getCatalog'.
  func makeGetCatalogInterceptors() -> [ClientInterceptor<Sensory_Api_V1_File_FileCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse>]

  /// - Returns: Interceptors to use when invoking 'getCompleteCatalog'.
  func makeGetCompleteCatalogInterceptors() -> [ClientInterceptor<Sensory_Api_V1_File_FileCompleteCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse>]

  /// - Returns: Interceptors to use when invoking 'download'.
  func makeDownloadInterceptors() -> [ClientInterceptor<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileResponse>]
}

public final class Sensory_Api_V1_File_FileClient: Sensory_Api_V1_File_FileClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_File_FileClientInterceptorFactoryProtocol?

  /// Creates a client for the sensory.api.v1.file.File service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_File_FileClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public final class Sensory_Api_V1_File_FileTestClient: Sensory_Api_V1_File_FileClientProtocol {
  private let fakeChannel: FakeChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_File_FileClientInterceptorFactoryProtocol?

  public var channel: GRPCChannel {
    return self.fakeChannel
  }

  public init(
    fakeChannel: FakeChannel = FakeChannel(),
    defaultCallOptions callOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_File_FileClientInterceptorFactoryProtocol? = nil
  ) {
    self.fakeChannel = fakeChannel
    self.defaultCallOptions = callOptions
    self.interceptors = interceptors
  }

  /// Make a unary response for the GetInfo RPC. This must be called
  /// before calling 'getInfo'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetInfoResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileInfo> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.file.File/GetInfo", requestHandler: requestHandler)
  }

  public func enqueueGetInfoResponse(
    _ response: Sensory_Api_V1_File_FileInfo,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetInfoResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetInfo'
  public var hasGetInfoResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.file.File/GetInfo")
  }

  /// Make a unary response for the GetCatalog RPC. This must be called
  /// before calling 'getCatalog'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetCatalogResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileCatalogRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_File_FileCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.file.File/GetCatalog", requestHandler: requestHandler)
  }

  public func enqueueGetCatalogResponse(
    _ response: Sensory_Api_V1_File_FileCatalogResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileCatalogRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetCatalogResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetCatalog'
  public var hasGetCatalogResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.file.File/GetCatalog")
  }

  /// Make a unary response for the GetCompleteCatalog RPC. This must be called
  /// before calling 'getCompleteCatalog'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetCompleteCatalogResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileCompleteCatalogRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_File_FileCompleteCatalogRequest, Sensory_Api_V1_File_FileCatalogResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.file.File/GetCompleteCatalog", requestHandler: requestHandler)
  }

  public func enqueueGetCompleteCatalogResponse(
    _ response: Sensory_Api_V1_File_FileCatalogResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileCompleteCatalogRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetCompleteCatalogResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetCompleteCatalog'
  public var hasGetCompleteCatalogResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.file.File/GetCompleteCatalog")
  }

  /// Make a streaming response for the Download RPC. This must be called
  /// before calling 'download'. See also 'FakeStreamingResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeDownloadResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileRequest>) -> () = { _ in }
  ) -> FakeStreamingResponse<Sensory_Api_V1_File_FileRequest, Sensory_Api_V1_File_FileResponse> {
    return self.fakeChannel.makeFakeStreamingResponse(path: "/sensory.api.v1.file.File/Download", requestHandler: requestHandler)
  }

  public func enqueueDownloadResponses(
    _ responses: [Sensory_Api_V1_File_FileResponse],
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_File_FileRequest>) -> () = { _ in }
  )  {
    let stream = self.makeDownloadResponseStream(requestHandler)
    // These are the only operation on the stream; try! is fine.
    responses.forEach { try! stream.sendMessage($0) }
    try! stream.sendEnd()
  }

  /// Returns true if there are response streams enqueued for 'Download'
  public var hasDownloadResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.file.File/Download")
  }
}

