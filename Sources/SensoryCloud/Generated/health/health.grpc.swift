//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: health/health.proto
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


/// Service for Health function
///
/// Usage: instantiate `Sensory_Api_Health_HealthServiceClient`, then call methods of this protocol to make API calls.
public protocol Sensory_Api_Health_HealthServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Sensory_Api_Health_HealthServiceClientInterceptorFactoryProtocol? { get }

  func getHealth(
    _ request: Sensory_Api_Health_HealthRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_Health_HealthRequest, Sensory_Api_Common_ServerHealthResponse>
}

extension Sensory_Api_Health_HealthServiceClientProtocol {
  public var serviceName: String {
    return "sensory.api.health.HealthService"
  }

  /// Obtain an Health and Server status information
  ///
  /// - Parameters:
  ///   - request: Request to send to GetHealth.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getHealth(
    _ request: Sensory_Api_Health_HealthRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_Health_HealthRequest, Sensory_Api_Common_ServerHealthResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.health.HealthService/GetHealth",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetHealthInterceptors() ?? []
    )
  }
}

public protocol Sensory_Api_Health_HealthServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'getHealth'.
  func makeGetHealthInterceptors() -> [ClientInterceptor<Sensory_Api_Health_HealthRequest, Sensory_Api_Common_ServerHealthResponse>]
}

public final class Sensory_Api_Health_HealthServiceClient: Sensory_Api_Health_HealthServiceClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_Health_HealthServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the sensory.api.health.HealthService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_Health_HealthServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public final class Sensory_Api_Health_HealthServiceTestClient: Sensory_Api_Health_HealthServiceClientProtocol {
  private let fakeChannel: FakeChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_Health_HealthServiceClientInterceptorFactoryProtocol?

  public var channel: GRPCChannel {
    return self.fakeChannel
  }

  public init(
    fakeChannel: FakeChannel = FakeChannel(),
    defaultCallOptions callOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_Health_HealthServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.fakeChannel = fakeChannel
    self.defaultCallOptions = callOptions
    self.interceptors = interceptors
  }

  /// Make a unary response for the GetHealth RPC. This must be called
  /// before calling 'getHealth'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetHealthResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_Health_HealthRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_Health_HealthRequest, Sensory_Api_Common_ServerHealthResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.health.HealthService/GetHealth", requestHandler: requestHandler)
  }

  public func enqueueGetHealthResponse(
    _ response: Sensory_Api_Common_ServerHealthResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_Health_HealthRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetHealthResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetHealth'
  public var hasGetHealthResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.health.HealthService/GetHealth")
  }
}
