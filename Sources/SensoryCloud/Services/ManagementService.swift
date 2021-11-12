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

public class ManagementService {

    var service: Service

    public init() {
        self.service = Service.shared
    }

    init(service: Service) {
        self.service = service
    }

    /// Fetches a list of the current enrollments for the given userID
    ///
    /// - Parameter userID: userID to get enrollments for
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
    /// - Parameter enrollmentID: enrollmentID for the enrollment to delete
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

    public func enrollDevice(
        tenantID: String,
        name: String,
        deviceID: String,
        credential: String,
        clientID: String,
        clientSecret: String
    ) -> EventLoopFuture<Sensory_Api_V1_Management_DeviceResponse> {
        NSLog("Enrolling device: %@", name)

        do {
            let client: Sensory_Api_V1_Management_DeviceServiceClientProtocol = try service.getClient()
            // TODO: config
            let defaultTimeout = CallOptions(timeLimit: .timeout(.seconds(10)))

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
