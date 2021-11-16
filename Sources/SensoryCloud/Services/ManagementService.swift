//
//  ManagementService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import GRPC
import NIO
import NIOHPACK

extension Sensory_Api_V1_Management_EnrollmentServiceClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Management_DeviceServiceClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

/// A collection of grpc service calls for managing existing enrollments and enrollment groups
public class ManagementService {

    var service: Service

    /// Initializes a new instance of `ManagementService`
    public init() {
        self.service = Service.shared
    }

    /// Internal initializer, used for unit testing
    init(service: Service) {
        self.service = service
    }

    /// Fetches a list of the current enrollments for the given userID
    ///
    /// - Parameter userID: userID to fetch enrollments for
    /// - Returns: A future to be fulfilled with either a list of enrollments, or the network error that occurred
    public func getEnrollments(for userID: String) -> EventLoopFuture<Sensory_Api_V1_Management_GetEnrollmentsResponse> {
        NSLog("Requesting current enrollments from server with userID: %@", userID)

        do {
            let client: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            var request = Sensory_Api_V1_Management_GetEnrollmentsRequest()
            request.userID = userID
            return client.getEnrollments(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    /// Fetches a list of the current enrollment groups owned by a given userID
    ///
    /// - Parameter userID: userID to fetch enrollment groups for
    /// - Returns: A future to be fulfilled with either a list of enrollment groups, or the network error that occurred
    public func getEnrollmentGroups(for userID: String) -> EventLoopFuture<Sensory_Api_V1_Management_GetEnrollmentGroupsResponse> {
        NSLog("Requesting current enrollment groups from server with userID: %@", userID)

        do {
            let client: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            var request = Sensory_Api_V1_Management_GetEnrollmentsRequest()
            request.userID = userID
            return client.getEnrollmentGroups(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    // TODO: make group ID internal?
    /// Creates a new group of enrollments that can be used for group authentication
    ///
    /// Enrollment groups are initially created without any associated enrollments `appendEnrollmentGroup()`
    /// may be used to add enrollments to an enrollment group
    /// - Parameters:
    ///   - userID: userID of the user that owns the enrollment group
    ///   - groupID: Unique group identifier for the enrollment group
    ///   - groupName: Friendly display name to use for the enrollment group
    ///   - description: Description of the enrollment group
    ///   - modelName: The name of the model that all enrollments in this group will use
    /// - Returns: A future to be fulfilled with either the newly created enrollment group, or the network error that occurred
    public func createEnrollmentGroup(
        userID: String,
        groupID: String,
        groupName: String,
        description: String,
        modelName: String
    ) -> EventLoopFuture<Sensory_Api_V1_Management_EnrollmentGroupResponse> {
        NSLog("Requesting enrollment group creation with name: %@", groupName)

        do {
            let client: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            var request = Sensory_Api_V1_Management_CreateEnrollmentGroupRequest()
            request.id = groupID
            request.name = groupName
            request.description_p = description
            request.modelName = modelName
            request.userID = userID.lowercased()
            return client.createEnrollmentGroup(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    /// Appends enrollments to an existing enrollment group
    /// - Parameters:
    ///   - groupId: GroupID of the enrollment group to append enrollments to
    ///   - enrollments: A list of enrollment ids to append to the enrollment group
    /// - Returns: A future to be fulfilled with either the updated enrollment group, or the network error that occurred
    public func appendEnrollmentGroup(
        groupId: String,
        enrollments: [String]
    ) -> EventLoopFuture<Sensory_Api_V1_Management_EnrollmentGroupResponse> {
        NSLog("Requesting to append enrollments to enrollment group: %@", groupId)

        do {
            let client: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            var request = Sensory_Api_V1_Management_AppendEnrollmentGroupRequest()
            request.groupID = groupId
            request.enrollmentIds = enrollments
            return client.appendEnrollmentGroup(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    /// Requests the deletion of an enrollment
    ///
    /// The server will prevent users from deleting their last enrollment
    /// - Parameter enrollmentID: enrollmentID for the enrollment to delete
    /// - Returns: A future to be fulfilled with either the deleted enrollment, or the network error that occurred
    public func deleteEnrollment(with enrollmentID: String) -> EventLoopFuture<Sensory_Api_V1_Management_EnrollmentResponse> {
        NSLog("Requesting to delete enrollment: %@", enrollmentID)

        do {
            let client: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            var request = Sensory_Api_V1_Management_DeleteEnrollmentRequest()
            request.id = enrollmentID
            return client.deleteEnrollment(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    /// Requests the deletion of multiple enrollments
    ///
    /// If an error occurs during the deletion process, already completed deletions will not be rolled back
    /// The server will prevent users from deleting their last enrollment
    /// - Parameter ids: List of enrollment ids to delete from the server
    /// - Returns: A future that will either contain a list of all server responses, or the first error to occur.
    public func deleteEnrollments(with ids: [String]) -> EventLoopFuture<[Sensory_Api_V1_Management_EnrollmentResponse]> {
        NSLog("Deleting %d enrollments", ids.count)

        var futures: [EventLoopFuture<Sensory_Api_V1_Management_EnrollmentResponse>] = []
        for id in ids {
            futures.append(deleteEnrollment(with: id))
        }

        return EventLoopFuture<Sensory_Api_V1_Management_EnrollmentResponse>.whenAllSucceed(futures, on: service.group.next())
    }

    /// Requests the deletion of enrollment groups
    ///
    /// - Parameter id: group ID to delete
    /// - Returns: A future to be fulfilled with either the deleted enrollment group, or the network error that occurred
    public func deleteEnrollmentGroup(with id: String) -> EventLoopFuture<Sensory_Api_V1_Management_EnrollmentGroupResponse> {
        NSLog("Requesting to delete enrollment group: %@", id)

        do {
            let client: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            var request = Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest()
            request.id = id
            return client.deleteEnrollmentGroup(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    // TODO: Move to OAuth Service
    /// Creates a new device enrollment
    ///
    /// The credential string authenticates that this device is allowed to enroll. Depending on the server configuration
    /// the credential string may be one of multiple values:
    ///  - An empty string if no authentication is configured on the server
    ///  - A shared secret (password)
    ///  - A signed JWT
    ///
    /// `TokenManager` may be used for securely generating a clientID and clientSecret for this call
    ///
    /// This call will fail with `NetworkError.notInitialized` if `Config.deviceID` or `Config.tenantID` has not been set
    ///
    /// - Parameters:
    ///   - tenantID: TenantID to enroll the device into
    ///   - name: Name of the enrolling device
    ///   - deviceID: Unique identifier of the enrolling device
    ///   - credential: Credential string to authenticate that this device is allowed to enroll
    ///   - clientID: ClientID to use for OAuth token generation
    ///   - clientSecret: Client Secret to use for OAuth token generation
    /// - Returns: A future to be fulfilled with either the enrolled device, or the network error that occurred
    public func enrollDevice(
        name: String,
        credential: String,
        clientID: String,
        clientSecret: String
    ) -> EventLoopFuture<Sensory_Api_V1_Management_DeviceResponse> {
        NSLog("Enrolling device: %@", name)

        do {
            guard let deviceID = Config.deviceID, let tenantID = Config.tenantID else {
                throw NetworkError.notInitialized
            }

            let client: Sensory_Api_V1_Management_DeviceServiceClientProtocol = try service.getClient()
            let defaultTimeout = CallOptions(timeLimit: .timeout(.seconds(Config.grpcTimeout)))

            var request = Sensory_Api_V1_Management_EnrollDeviceRequest()
            var clientRequest = Sensory_Api_V1_Management_CreateGenericClientRequest()
            clientRequest.clientID = clientID
            clientRequest.secret = clientSecret
            request.name = name
            request.deviceID = deviceID
            request.tenantID = tenantID
            request.client = clientRequest
            request.credential = credential
            return client.enrollDevice(request, callOptions: defaultTimeout).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }
}
