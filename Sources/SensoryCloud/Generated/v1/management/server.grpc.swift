//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: v1/management/server.proto
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


/// Serivce to manage Servers
///
/// Usage: instantiate `Sensory_Api_V1_Management_ServerServiceClient`, then call methods of this protocol to make API calls.
public protocol Sensory_Api_V1_Management_ServerServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Sensory_Api_V1_Management_ServerServiceClientInterceptorFactoryProtocol? { get }

  func getConfig(
    _ request: Sensory_Api_V1_Management_ServerConfigRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_ServerConfigRequest, Sensory_Api_V1_Management_ServerConfig>

  func putHeartbeat(
    _ request: Sensory_Api_V1_Management_ServerHeartbeatRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_ServerHeartbeatRequest, Sensory_Api_V1_Management_HeartbeatResponse>

  func getServerList(
    _ request: Sensory_Api_V1_Management_ServerListRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_ServerListRequest, Sensory_Api_V1_Management_ServerListResponse>
}

extension Sensory_Api_V1_Management_ServerServiceClientProtocol {
  public var serviceName: String {
    return "sensory.api.v1.management.ServerService"
  }

  /// Obtains server configuration informtion
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetConfig.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getConfig(
    _ request: Sensory_Api_V1_Management_ServerConfigRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_ServerConfigRequest, Sensory_Api_V1_Management_ServerConfig> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.ServerService/GetConfig",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetConfigInterceptors() ?? []
    )
  }

  /// Allows a server to publish general health information about itself
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to PutHeartbeat.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func putHeartbeat(
    _ request: Sensory_Api_V1_Management_ServerHeartbeatRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_ServerHeartbeatRequest, Sensory_Api_V1_Management_HeartbeatResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.ServerService/PutHeartbeat",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makePutHeartbeatInterceptors() ?? []
    )
  }

  /// Obtains a list of servers and their health status
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetServerList.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getServerList(
    _ request: Sensory_Api_V1_Management_ServerListRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_ServerListRequest, Sensory_Api_V1_Management_ServerListResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.ServerService/GetServerList",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetServerListInterceptors() ?? []
    )
  }
}

public protocol Sensory_Api_V1_Management_ServerServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'getConfig'.
  func makeGetConfigInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_ServerConfigRequest, Sensory_Api_V1_Management_ServerConfig>]

  /// - Returns: Interceptors to use when invoking 'putHeartbeat'.
  func makePutHeartbeatInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_ServerHeartbeatRequest, Sensory_Api_V1_Management_HeartbeatResponse>]

  /// - Returns: Interceptors to use when invoking 'getServerList'.
  func makeGetServerListInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_ServerListRequest, Sensory_Api_V1_Management_ServerListResponse>]
}

public final class Sensory_Api_V1_Management_ServerServiceClient: Sensory_Api_V1_Management_ServerServiceClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_Management_ServerServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the sensory.api.v1.management.ServerService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_Management_ServerServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public final class Sensory_Api_V1_Management_ServerServiceTestClient: Sensory_Api_V1_Management_ServerServiceClientProtocol {
  private let fakeChannel: FakeChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_Management_ServerServiceClientInterceptorFactoryProtocol?

  public var channel: GRPCChannel {
    return self.fakeChannel
  }

  public init(
    fakeChannel: FakeChannel = FakeChannel(),
    defaultCallOptions callOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_Management_ServerServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.fakeChannel = fakeChannel
    self.defaultCallOptions = callOptions
    self.interceptors = interceptors
  }

  /// Make a unary response for the GetConfig RPC. This must be called
  /// before calling 'getConfig'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetConfigResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_ServerConfigRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_ServerConfigRequest, Sensory_Api_V1_Management_ServerConfig> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.ServerService/GetConfig", requestHandler: requestHandler)
  }

  public func enqueueGetConfigResponse(
    _ response: Sensory_Api_V1_Management_ServerConfig,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_ServerConfigRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetConfigResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetConfig'
  public var hasGetConfigResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.ServerService/GetConfig")
  }

  /// Make a unary response for the PutHeartbeat RPC. This must be called
  /// before calling 'putHeartbeat'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makePutHeartbeatResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_ServerHeartbeatRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_ServerHeartbeatRequest, Sensory_Api_V1_Management_HeartbeatResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.ServerService/PutHeartbeat", requestHandler: requestHandler)
  }

  public func enqueuePutHeartbeatResponse(
    _ response: Sensory_Api_V1_Management_HeartbeatResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_ServerHeartbeatRequest>) -> () = { _ in }
  )  {
    let stream = self.makePutHeartbeatResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'PutHeartbeat'
  public var hasPutHeartbeatResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.ServerService/PutHeartbeat")
  }

  /// Make a unary response for the GetServerList RPC. This must be called
  /// before calling 'getServerList'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetServerListResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_ServerListRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_ServerListRequest, Sensory_Api_V1_Management_ServerListResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.ServerService/GetServerList", requestHandler: requestHandler)
  }

  public func enqueueGetServerListResponse(
    _ response: Sensory_Api_V1_Management_ServerListResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_ServerListRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetServerListResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetServerList'
  public var hasGetServerListResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.ServerService/GetServerList")
  }
}
