// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: v1/file/file.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

/// sensory.api.file

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// A type of file supported by this API
public enum Sensory_Api_V1_File_FileCategory: SwiftProtobuf.Enum {
  public typealias RawValue = Int

  /// A model used with TSSV
  case tssvModel // = 0

  /// A model used with the fenrir library
  case fenrirModel // = 1

  /// A model used with the TNL library
  case tnlModel // = 2

  /// Unknown Model Type
  case unknown // = 100
  case UNRECOGNIZED(Int)

  public init() {
    self = .tssvModel
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .tssvModel
    case 1: self = .fenrirModel
    case 2: self = .tnlModel
    case 100: self = .unknown
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .tssvModel: return 0
    case .fenrirModel: return 1
    case .tnlModel: return 2
    case .unknown: return 100
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Sensory_Api_V1_File_FileCategory: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [Sensory_Api_V1_File_FileCategory] = [
    .tssvModel,
    .fenrirModel,
    .tnlModel,
    .unknown,
  ]
}

#endif  // swift(>=4.2)

/// A request to download file
public struct Sensory_Api_V1_File_FileRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The complete path of the file to be downloaded
  /// including the filename. (E.G my/file/path/file.txt)
  public var file: String = String()

  /// The category of file requested with version information.
  public var category: Sensory_Api_V1_File_VersionedFileCategory {
    get {return _category ?? Sensory_Api_V1_File_VersionedFileCategory()}
    set {_category = newValue}
  }
  /// Returns true if `category` has been explicitly set.
  public var hasCategory: Bool {return self._category != nil}
  /// Clears the value of `category`. Subsequent reads from it will return its default value.
  public mutating func clearCategory() {self._category = nil}

  /// The offset value based on the number of bytes previously downloaded.
  /// Useful if the download previously failed, and you'd like to start from where you left off.
  public var offset: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _category: Sensory_Api_V1_File_VersionedFileCategory? = nil
}

/// The top-level message returned from the client for the `Download` method.
/// Multiple `FileResponse` messages are sent in a stream. The first message
/// will contain an `info` message and will not contain `FileChunk`.
/// All subsequent messages must contain `FileChunk` and
/// must not contain an `info` message.
public struct Sensory_Api_V1_File_FileResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The streaming response, which is either info or chunk.
  public var streamingResponse: Sensory_Api_V1_File_FileResponse.OneOf_StreamingResponse? = nil

  /// Provides information about the requested file.
  public var info: Sensory_Api_V1_File_FileInfo {
    get {
      if case .info(let v)? = streamingResponse {return v}
      return Sensory_Api_V1_File_FileInfo()
    }
    set {streamingResponse = .info(newValue)}
  }

  /// A chunk of the downloaded file
  public var chunk: Sensory_Api_V1_File_FileChunk {
    get {
      if case .chunk(let v)? = streamingResponse {return v}
      return Sensory_Api_V1_File_FileChunk()
    }
    set {streamingResponse = .chunk(newValue)}
  }

  /// File download complete flag
  public var complete: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  /// The streaming response, which is either info or chunk.
  public enum OneOf_StreamingResponse: Equatable {
    /// Provides information about the requested file.
    case info(Sensory_Api_V1_File_FileInfo)
    /// A chunk of the downloaded file
    case chunk(Sensory_Api_V1_File_FileChunk)

  #if !swift(>=4.1)
    public static func ==(lhs: Sensory_Api_V1_File_FileResponse.OneOf_StreamingResponse, rhs: Sensory_Api_V1_File_FileResponse.OneOf_StreamingResponse) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.info, .info): return {
        guard case .info(let l) = lhs, case .info(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.chunk, .chunk): return {
        guard case .chunk(let l) = lhs, case .chunk(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

/// A request to obtain a catalog of all files
public struct Sensory_Api_V1_File_FileCatalogRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// A map of file category versions
  public var categories: [Sensory_Api_V1_File_VersionedFileCategory] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// a request to obtain the complete file catalog (Internal only)
public struct Sensory_Api_V1_File_FileCompleteCatalogRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// A reponse with the file catalog
public struct Sensory_Api_V1_File_FileCatalogResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The catalog of files
  public var catalog: [Sensory_Api_V1_File_FileCatalog] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// A chunk of a downloaded file
public struct Sensory_Api_V1_File_FileChunk {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The bytes to be sent to the
  public var bytes: Data = Data()

  /// The offset value based on the number of bytes currently written
  public var offset: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// Information about the file
public struct Sensory_Api_V1_File_FileInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The name of the base file.
  public var file: String = String()

  /// The complete path of the file to be downloaded
  /// including the filename. (E.G my/file/path/file.txt)
  public var absolutePath: String = String()

  /// The full size of the file
  public var size: Int64 = 0

  /// A standard MIME type describing the format of the file
  public var contentType: String = String()

  /// The md5 file hash
  public var hash: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// A message containing a list of FileInfos
public struct Sensory_Api_V1_File_FileCatalog {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The list of files
  public var files: [Sensory_Api_V1_File_FileInfo] = []

  /// The category of files in this catalog
  public var category: Sensory_Api_V1_File_VersionedFileCategory {
    get {return _category ?? Sensory_Api_V1_File_VersionedFileCategory()}
    set {_category = newValue}
  }
  /// Returns true if `category` has been explicitly set.
  public var hasCategory: Bool {return self._category != nil}
  /// Clears the value of `category`. Subsequent reads from it will return its default value.
  public mutating func clearCategory() {self._category = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _category: Sensory_Api_V1_File_VersionedFileCategory? = nil
}

/// A versioned file category
public struct Sensory_Api_V1_File_VersionedFileCategory {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The category of file
  public var category: Sensory_Api_V1_File_FileCategory = .tssvModel

  /// The version of the category (e.g. For TSSV v3.16.3 models, the version would be 3.16)
  public var version: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "sensory.api.v1.file"

extension Sensory_Api_V1_File_FileCategory: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "TSSV_MODEL"),
    1: .same(proto: "FENRIR_MODEL"),
    2: .same(proto: "TNL_MODEL"),
    100: .same(proto: "UNKNOWN"),
  ]
}

extension Sensory_Api_V1_File_FileRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "file"),
    2: .same(proto: "category"),
    3: .same(proto: "offset"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.file) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._category) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.offset) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.file.isEmpty {
      try visitor.visitSingularStringField(value: self.file, fieldNumber: 1)
    }
    if let v = self._category {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    if self.offset != 0 {
      try visitor.visitSingularInt64Field(value: self.offset, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileRequest, rhs: Sensory_Api_V1_File_FileRequest) -> Bool {
    if lhs.file != rhs.file {return false}
    if lhs._category != rhs._category {return false}
    if lhs.offset != rhs.offset {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_FileResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "info"),
    2: .same(proto: "chunk"),
    3: .same(proto: "complete"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try {
        var v: Sensory_Api_V1_File_FileInfo?
        var hadOneofValue = false
        if let current = self.streamingResponse {
          hadOneofValue = true
          if case .info(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.streamingResponse = .info(v)
        }
      }()
      case 2: try {
        var v: Sensory_Api_V1_File_FileChunk?
        var hadOneofValue = false
        if let current = self.streamingResponse {
          hadOneofValue = true
          if case .chunk(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.streamingResponse = .chunk(v)
        }
      }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self.complete) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every case branch when no optimizations are
    // enabled. https://github.com/apple/swift-protobuf/issues/1034
    switch self.streamingResponse {
    case .info?: try {
      guard case .info(let v)? = self.streamingResponse else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }()
    case .chunk?: try {
      guard case .chunk(let v)? = self.streamingResponse else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case nil: break
    }
    if self.complete != false {
      try visitor.visitSingularBoolField(value: self.complete, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileResponse, rhs: Sensory_Api_V1_File_FileResponse) -> Bool {
    if lhs.streamingResponse != rhs.streamingResponse {return false}
    if lhs.complete != rhs.complete {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_FileCatalogRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileCatalogRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "categories"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.categories) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.categories.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.categories, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileCatalogRequest, rhs: Sensory_Api_V1_File_FileCatalogRequest) -> Bool {
    if lhs.categories != rhs.categories {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_FileCompleteCatalogRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileCompleteCatalogRequest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileCompleteCatalogRequest, rhs: Sensory_Api_V1_File_FileCompleteCatalogRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_FileCatalogResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileCatalogResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "catalog"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.catalog) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.catalog.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.catalog, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileCatalogResponse, rhs: Sensory_Api_V1_File_FileCatalogResponse) -> Bool {
    if lhs.catalog != rhs.catalog {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_FileChunk: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileChunk"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "bytes"),
    2: .same(proto: "offset"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.bytes) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.offset) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.bytes.isEmpty {
      try visitor.visitSingularBytesField(value: self.bytes, fieldNumber: 1)
    }
    if self.offset != 0 {
      try visitor.visitSingularInt64Field(value: self.offset, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileChunk, rhs: Sensory_Api_V1_File_FileChunk) -> Bool {
    if lhs.bytes != rhs.bytes {return false}
    if lhs.offset != rhs.offset {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_FileInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "file"),
    2: .same(proto: "absolutePath"),
    3: .same(proto: "size"),
    4: .same(proto: "contentType"),
    5: .same(proto: "hash"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.file) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.absolutePath) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.size) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.contentType) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.hash) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.file.isEmpty {
      try visitor.visitSingularStringField(value: self.file, fieldNumber: 1)
    }
    if !self.absolutePath.isEmpty {
      try visitor.visitSingularStringField(value: self.absolutePath, fieldNumber: 2)
    }
    if self.size != 0 {
      try visitor.visitSingularInt64Field(value: self.size, fieldNumber: 3)
    }
    if !self.contentType.isEmpty {
      try visitor.visitSingularStringField(value: self.contentType, fieldNumber: 4)
    }
    if !self.hash.isEmpty {
      try visitor.visitSingularStringField(value: self.hash, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileInfo, rhs: Sensory_Api_V1_File_FileInfo) -> Bool {
    if lhs.file != rhs.file {return false}
    if lhs.absolutePath != rhs.absolutePath {return false}
    if lhs.size != rhs.size {return false}
    if lhs.contentType != rhs.contentType {return false}
    if lhs.hash != rhs.hash {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_FileCatalog: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileCatalog"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "files"),
    2: .same(proto: "category"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.files) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._category) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.files.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.files, fieldNumber: 1)
    }
    if let v = self._category {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_FileCatalog, rhs: Sensory_Api_V1_File_FileCatalog) -> Bool {
    if lhs.files != rhs.files {return false}
    if lhs._category != rhs._category {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Sensory_Api_V1_File_VersionedFileCategory: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".VersionedFileCategory"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "category"),
    2: .same(proto: "version"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.category) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.version) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.category != .tssvModel {
      try visitor.visitSingularEnumField(value: self.category, fieldNumber: 1)
    }
    if !self.version.isEmpty {
      try visitor.visitSingularStringField(value: self.version, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Sensory_Api_V1_File_VersionedFileCategory, rhs: Sensory_Api_V1_File_VersionedFileCategory) -> Bool {
    if lhs.category != rhs.category {return false}
    if lhs.version != rhs.version {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}