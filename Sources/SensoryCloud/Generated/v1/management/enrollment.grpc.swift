//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: v1/management/enrollment.proto
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


/// Service to manage Enrollments in the database
///
/// Usage: instantiate `Sensory_Api_V1_Management_EnrollmentServiceClient`, then call methods of this protocol to make API calls.
public protocol Sensory_Api_V1_Management_EnrollmentServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Sensory_Api_V1_Management_EnrollmentServiceClientInterceptorFactoryProtocol? { get }

  func getEnrollments(
    _ request: Sensory_Api_V1_Management_GetEnrollmentsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentsResponse>

  func getEnrollmentGroups(
    _ request: Sensory_Api_V1_Management_GetEnrollmentsRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentGroupsResponse>

  func createEnrollmentGroup(
    _ request: Sensory_Api_V1_Management_CreateEnrollmentGroupRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_CreateEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse>

  func appendEnrollmentGroup(
    _ request: Sensory_Api_V1_Management_AppendEnrollmentGroupRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_AppendEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse>

  func deleteEnrollment(
    _ request: Sensory_Api_V1_Management_DeleteEnrollmentRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_DeleteEnrollmentRequest, Sensory_Api_V1_Management_EnrollmentResponse>

  func deleteEnrollmentGroup(
    _ request: Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse>
}

extension Sensory_Api_V1_Management_EnrollmentServiceClientProtocol {
  public var serviceName: String {
    return "sensory.api.v1.management.EnrollmentService"
  }

  /// Get enrollments from the database that match the specified criteria
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetEnrollments.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getEnrollments(
    _ request: Sensory_Api_V1_Management_GetEnrollmentsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentsResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.EnrollmentService/GetEnrollments",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetEnrollmentsInterceptors() ?? []
    )
  }

  /// Get all enrollment groups that match the specified criteria
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to GetEnrollmentGroups.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getEnrollmentGroups(
    _ request: Sensory_Api_V1_Management_GetEnrollmentsRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentGroupsResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.EnrollmentService/GetEnrollmentGroups",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetEnrollmentGroupsInterceptors() ?? []
    )
  }

  /// Creates a new enrollment group without any associated enrollments
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to CreateEnrollmentGroup.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func createEnrollmentGroup(
    _ request: Sensory_Api_V1_Management_CreateEnrollmentGroupRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_CreateEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.EnrollmentService/CreateEnrollmentGroup",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeCreateEnrollmentGroupInterceptors() ?? []
    )
  }

  /// Appends an enrollment to an enrollment group
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to AppendEnrollmentGroup.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func appendEnrollmentGroup(
    _ request: Sensory_Api_V1_Management_AppendEnrollmentGroupRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_AppendEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.EnrollmentService/AppendEnrollmentGroup",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAppendEnrollmentGroupInterceptors() ?? []
    )
  }

  /// Deletes an enrollment from the database
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to DeleteEnrollment.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func deleteEnrollment(
    _ request: Sensory_Api_V1_Management_DeleteEnrollmentRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_DeleteEnrollmentRequest, Sensory_Api_V1_Management_EnrollmentResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.EnrollmentService/DeleteEnrollment",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDeleteEnrollmentInterceptors() ?? []
    )
  }

  /// Deletes an enrollment group from the database
  /// Authorization metadata is required {"authorization": "Bearer <TOKEN>"}
  ///
  /// - Parameters:
  ///   - request: Request to send to DeleteEnrollmentGroup.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func deleteEnrollmentGroup(
    _ request: Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse> {
    return self.makeUnaryCall(
      path: "/sensory.api.v1.management.EnrollmentService/DeleteEnrollmentGroup",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeDeleteEnrollmentGroupInterceptors() ?? []
    )
  }
}

public protocol Sensory_Api_V1_Management_EnrollmentServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'getEnrollments'.
  func makeGetEnrollmentsInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentsResponse>]

  /// - Returns: Interceptors to use when invoking 'getEnrollmentGroups'.
  func makeGetEnrollmentGroupsInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentGroupsResponse>]

  /// - Returns: Interceptors to use when invoking 'createEnrollmentGroup'.
  func makeCreateEnrollmentGroupInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_CreateEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse>]

  /// - Returns: Interceptors to use when invoking 'appendEnrollmentGroup'.
  func makeAppendEnrollmentGroupInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_AppendEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse>]

  /// - Returns: Interceptors to use when invoking 'deleteEnrollment'.
  func makeDeleteEnrollmentInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_DeleteEnrollmentRequest, Sensory_Api_V1_Management_EnrollmentResponse>]

  /// - Returns: Interceptors to use when invoking 'deleteEnrollmentGroup'.
  func makeDeleteEnrollmentGroupInterceptors() -> [ClientInterceptor<Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse>]
}

public final class Sensory_Api_V1_Management_EnrollmentServiceClient: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_Management_EnrollmentServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the sensory.api.v1.management.EnrollmentService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_Management_EnrollmentServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

public final class Sensory_Api_V1_Management_EnrollmentServiceTestClient: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol {
  private let fakeChannel: FakeChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Sensory_Api_V1_Management_EnrollmentServiceClientInterceptorFactoryProtocol?

  public var channel: GRPCChannel {
    return self.fakeChannel
  }

  public init(
    fakeChannel: FakeChannel = FakeChannel(),
    defaultCallOptions callOptions: CallOptions = CallOptions(),
    interceptors: Sensory_Api_V1_Management_EnrollmentServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.fakeChannel = fakeChannel
    self.defaultCallOptions = callOptions
    self.interceptors = interceptors
  }

  /// Make a unary response for the GetEnrollments RPC. This must be called
  /// before calling 'getEnrollments'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetEnrollmentsResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_GetEnrollmentsRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentsResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.EnrollmentService/GetEnrollments", requestHandler: requestHandler)
  }

  public func enqueueGetEnrollmentsResponse(
    _ response: Sensory_Api_V1_Management_GetEnrollmentsResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_GetEnrollmentsRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetEnrollmentsResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetEnrollments'
  public var hasGetEnrollmentsResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.EnrollmentService/GetEnrollments")
  }

  /// Make a unary response for the GetEnrollmentGroups RPC. This must be called
  /// before calling 'getEnrollmentGroups'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeGetEnrollmentGroupsResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_GetEnrollmentsRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_GetEnrollmentsRequest, Sensory_Api_V1_Management_GetEnrollmentGroupsResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.EnrollmentService/GetEnrollmentGroups", requestHandler: requestHandler)
  }

  public func enqueueGetEnrollmentGroupsResponse(
    _ response: Sensory_Api_V1_Management_GetEnrollmentGroupsResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_GetEnrollmentsRequest>) -> () = { _ in }
  )  {
    let stream = self.makeGetEnrollmentGroupsResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'GetEnrollmentGroups'
  public var hasGetEnrollmentGroupsResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.EnrollmentService/GetEnrollmentGroups")
  }

  /// Make a unary response for the CreateEnrollmentGroup RPC. This must be called
  /// before calling 'createEnrollmentGroup'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeCreateEnrollmentGroupResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_CreateEnrollmentGroupRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_CreateEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.EnrollmentService/CreateEnrollmentGroup", requestHandler: requestHandler)
  }

  public func enqueueCreateEnrollmentGroupResponse(
    _ response: Sensory_Api_V1_Management_EnrollmentGroupResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_CreateEnrollmentGroupRequest>) -> () = { _ in }
  )  {
    let stream = self.makeCreateEnrollmentGroupResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'CreateEnrollmentGroup'
  public var hasCreateEnrollmentGroupResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.EnrollmentService/CreateEnrollmentGroup")
  }

  /// Make a unary response for the AppendEnrollmentGroup RPC. This must be called
  /// before calling 'appendEnrollmentGroup'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeAppendEnrollmentGroupResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_AppendEnrollmentGroupRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_AppendEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.EnrollmentService/AppendEnrollmentGroup", requestHandler: requestHandler)
  }

  public func enqueueAppendEnrollmentGroupResponse(
    _ response: Sensory_Api_V1_Management_EnrollmentGroupResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_AppendEnrollmentGroupRequest>) -> () = { _ in }
  )  {
    let stream = self.makeAppendEnrollmentGroupResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'AppendEnrollmentGroup'
  public var hasAppendEnrollmentGroupResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.EnrollmentService/AppendEnrollmentGroup")
  }

  /// Make a unary response for the DeleteEnrollment RPC. This must be called
  /// before calling 'deleteEnrollment'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeDeleteEnrollmentResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_DeleteEnrollmentRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_DeleteEnrollmentRequest, Sensory_Api_V1_Management_EnrollmentResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.EnrollmentService/DeleteEnrollment", requestHandler: requestHandler)
  }

  public func enqueueDeleteEnrollmentResponse(
    _ response: Sensory_Api_V1_Management_EnrollmentResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_DeleteEnrollmentRequest>) -> () = { _ in }
  )  {
    let stream = self.makeDeleteEnrollmentResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'DeleteEnrollment'
  public var hasDeleteEnrollmentResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.EnrollmentService/DeleteEnrollment")
  }

  /// Make a unary response for the DeleteEnrollmentGroup RPC. This must be called
  /// before calling 'deleteEnrollmentGroup'. See also 'FakeUnaryResponse'.
  ///
  /// - Parameter requestHandler: a handler for request parts sent by the RPC.
  public func makeDeleteEnrollmentGroupResponseStream(
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest>) -> () = { _ in }
  ) -> FakeUnaryResponse<Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest, Sensory_Api_V1_Management_EnrollmentGroupResponse> {
    return self.fakeChannel.makeFakeUnaryResponse(path: "/sensory.api.v1.management.EnrollmentService/DeleteEnrollmentGroup", requestHandler: requestHandler)
  }

  public func enqueueDeleteEnrollmentGroupResponse(
    _ response: Sensory_Api_V1_Management_EnrollmentGroupResponse,
    _ requestHandler: @escaping (FakeRequestPart<Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest>) -> () = { _ in }
  )  {
    let stream = self.makeDeleteEnrollmentGroupResponseStream(requestHandler)
    // This is the only operation on the stream; try! is fine.
    try! stream.sendMessage(response)
  }

  /// Returns true if there are response streams enqueued for 'DeleteEnrollmentGroup'
  public var hasDeleteEnrollmentGroupResponsesRemaining: Bool {
    return self.fakeChannel.hasFakeResponseEnqueued(forPath: "/sensory.api.v1.management.EnrollmentService/DeleteEnrollmentGroup")
  }
}
