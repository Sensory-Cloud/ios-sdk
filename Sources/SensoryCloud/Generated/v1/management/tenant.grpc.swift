//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: v1/management/tenant.proto
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


/// Service to manage Tenants in the database
///
/// Usage: instantiate `Sensory_Api_V1_Management_TenantServiceClient`, then call methods of this protocol to make API calls.
public protocol Sensory_Api_V1_Management_TenantServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Sensory_Api_V1_Management_TenantServiceClientInterceptorFactoryProtocol? { get }

  func initializeTenant(
    _ request: Sensory_Api_V1_Management_InitializeTenantRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_InitializeTenantRequest, Sensory_Api_V1_Management_InitializeTenantResponse>

  func getTenantList(
    _ request: Sensory_Api_V1_Management_TenantListRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_TenantListRequest, Sensory_Api_V1_Management_TenantListResponse>

  func getTenant(
    _ request: Sensory_Api_V1_Management_TenantGetRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_TenantGetRequest, Sensory_Api_V1_Management_TenantResponse>
}

extension Sensory_Api_V1_Management_TenantServiceClientProtocol {
  public var serviceName: String {
    return "sensory.api.v1.management.TenantService"
  }

  /// Initialize a tenant along with a new server and OAuth client
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to InitializeTenant.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func initializeTenant(
    _ request: Sensory_Api_V1_Management_InitializeTenantRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_InitializeTenantRequest, Sensory_Api_V1_Management_InitializeTenantResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.TenantService/InitializeTenant",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeInitializeTenantInterceptors() ?? []
    )
  }

  /// Obtains a summary of tenants
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetTenantList.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getTenantList(
    _ request: Sensory_Api_V1_Management_TenantListRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_TenantListRequest, Sensory_Api_V1_Management_TenantListResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.TenantService/GetTenantList",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetTenantListInterceptors() ?? []
    )
  }

  /// Obtains a single tenant
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetTenant.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getTenant(
    _ request: Sensory_Api_V1_Management_TenantGetRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_TenantGetRequest, Sensory_Api_V1_Management_TenantResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.TenantService/GetTenant",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetTenantInterceptors() ?? []
    )
  }
}

public protocol Sensory_Api_V1_Management_TenantServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'initializeTenant'.
  func makeInitializeTenantInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_InitializeTenantRequest, Sensory_Api_V1_Management_InitializeTenantResponse>]

  /// - Returns: Interceptors to use when invoking 'getTenantList'.
  func makeGetTenantListInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_TenantListRequest, Sensory_Api_V1_Management_TenantListResponse>]

  /// - Returns: Interceptors to use when invoking 'getTenant'.
  func makeGetTenantInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_TenantGetRequest, Sensory_Api_V1_Management_TenantResponse>]
}

public final class Sensory_Api_V1_Management_TenantServiceClient: Sensory_Api_V1_Management_TenantServiceClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_Management_TenantServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the sensory.api.v1.management.TenantService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_Management_TenantServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public final class Sensory_Api_V1_Management_TenantServiceTestClient: Sensory_Api_V1_Management_TenantServiceClientProtocol {
  private let fakeChannel: FakeChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_Management_TenantServiceClientInterceptorFactoryProtocol?

  public var channel: GRPCChannel {
    return self.fakeChannel
  }

  public init(
    fakeChannel: FakeChannel = FakeChannel(),
    defaultCallOptions callOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_Management_TenantServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.fakeChannel = fakeChannel
    self.defaultCallOptions = callOptions
    self.interceptors = interceptors
  }

  /// Make a unary response for the InitializeTenant RPC. This must be called
  /// before calling 'initializeTenant'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeInitializeTenantResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_InitializeTenantRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_InitializeTenantRequest, Sensory_Api_V1_Management_InitializeTenantResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.TenantService/InitializeTenant", requestHandler: requestHandler)
  }

  public func enqueueInitializeTenantResponse(
    _ response: Sensory_Api_V1_Management_InitializeTenantResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_InitializeTenantRequest>) -> () = { _ in }
  )  {
    let stream = self.makeInitializeTenantResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'InitializeTenant'
  public var hasInitializeTenantResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.TenantService/InitializeTenant")
  }

  /// Make a unary response for the GetTenantList RPC. This must be called
  /// before calling 'getTenantList'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetTenantListResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_TenantListRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_TenantListRequest, Sensory_Api_V1_Management_TenantListResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.TenantService/GetTenantList", requestHandler: requestHandler)
  }

  public func enqueueGetTenantListResponse(
    _ response: Sensory_Api_V1_Management_TenantListResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_TenantListRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetTenantListResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetTenantList'
  public var hasGetTenantListResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.TenantService/GetTenantList")
  }

  /// Make a unary response for the GetTenant RPC. This must be called
  /// before calling 'getTenant'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetTenantResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_TenantGetRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_TenantGetRequest, Sensory_Api_V1_Management_TenantResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.TenantService/GetTenant", requestHandler: requestHandler)
  }

  public func enqueueGetTenantResponse(
    _ response: Sensory_Api_V1_Management_TenantResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_TenantGetRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetTenantResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetTenant'
  public var hasGetTenantResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.TenantService/GetTenant")
  }
}
