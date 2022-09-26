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

    /// Creates a new group of enrollments that can be used for group authentication
    ///
    /// Enrollment groups are initially created without any associated enrollments `appendEnrollmentGroup()`
    /// may be used to add enrollments to an enrollment group
    /// - Parameters:
    ///   - userID: userID of the user that owns the enrollment group
    ///   - groupID: Unique group identifier for the enrollment group, if empty an id will be automatically generated
    ///   - groupName: Friendly display name to use for the enrollment group
    ///   - description: Description of the enrollment group
    ///   - modelName: The name of the model that all enrollments in this group will use
    /// - Returns: A future to be fulfilled with either the newly created enrollment group, or the network error that occurred
    public func createEnrollmentGroup(
        userID: String,
        groupID: String = UUID().uuidString,
        groupName: String,
        description: String,
        modelName: String
    ) -> EventLoopFuture<Sensory_Api_V1_Management_EnrollmentGroupResponse> {
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
}
