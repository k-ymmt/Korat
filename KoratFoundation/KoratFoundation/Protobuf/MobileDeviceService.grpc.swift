//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: MobileDeviceService.proto
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
import Foundation
import GRPC
import NIO
import NIOHTTP1
import SwiftProtobuf


/// Usage: instantiate MobileDeviceServiceServiceClient, then call methods of this protocol to make API calls.
public protocol MobileDeviceServiceService {
  func getDeviceList(_ request: VoidData, callOptions: CallOptions?) -> UnaryCall<VoidData, DeviceListResponse>
  func subscribeDeviceEvent(_ request: VoidData, callOptions: CallOptions?, handler: @escaping (SubscribeDeviceEventResponse) -> Void) -> ServerStreamingCall<VoidData, SubscribeDeviceEventResponse>
  func unsubscribeDeviceEvent(_ request: VoidData, callOptions: CallOptions?) -> UnaryCall<VoidData, VoidData>
  func getDeviceName(_ request: DeviceNameRequest, callOptions: CallOptions?) -> UnaryCall<DeviceNameRequest, DeviceNameResponse>
  func publish(callOptions: CallOptions?) -> ClientStreamingCall<PublishRequest, PublishResponse>
  func subscribe(_ request: SubscribeRequest, callOptions: CallOptions?, handler: @escaping (SubscribeResponse) -> Void) -> ServerStreamingCall<SubscribeRequest, SubscribeResponse>
  func captureSyslog(_ request: CaptureSyslogRequest, callOptions: CallOptions?, handler: @escaping (CaptureSyslogResponse) -> Void) -> ServerStreamingCall<CaptureSyslogRequest, CaptureSyslogResponse>
}

public final class MobileDeviceServiceServiceClient: GRPCClient, MobileDeviceServiceService {
  public let connection: ClientConnection
  public var defaultCallOptions: CallOptions

  /// Creates a client for the MobileDeviceService service.
  ///
  /// - Parameters:
  ///   - connection: `ClientConnection` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(connection: ClientConnection, defaultCallOptions: CallOptions = CallOptions()) {
    self.connection = connection
    self.defaultCallOptions = defaultCallOptions
  }

  /// Asynchronous unary call to GetDeviceList.
  ///
  /// - Parameters:
  ///   - request: Request to send to GetDeviceList.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getDeviceList(_ request: VoidData, callOptions: CallOptions? = nil) -> UnaryCall<VoidData, DeviceListResponse> {
    return self.makeUnaryCall(path: "/MobileDeviceService/GetDeviceList",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Asynchronous server-streaming call to SubscribeDeviceEvent.
  ///
  /// - Parameters:
  ///   - request: Request to send to SubscribeDeviceEvent.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  public func subscribeDeviceEvent(_ request: VoidData, callOptions: CallOptions? = nil, handler: @escaping (SubscribeDeviceEventResponse) -> Void) -> ServerStreamingCall<VoidData, SubscribeDeviceEventResponse> {
    return self.makeServerStreamingCall(path: "/MobileDeviceService/SubscribeDeviceEvent",
                                        request: request,
                                        callOptions: callOptions ?? self.defaultCallOptions,
                                        handler: handler)
  }

  /// Asynchronous unary call to UnsubscribeDeviceEvent.
  ///
  /// - Parameters:
  ///   - request: Request to send to UnsubscribeDeviceEvent.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func unsubscribeDeviceEvent(_ request: VoidData, callOptions: CallOptions? = nil) -> UnaryCall<VoidData, VoidData> {
    return self.makeUnaryCall(path: "/MobileDeviceService/UnsubscribeDeviceEvent",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Asynchronous unary call to GetDeviceName.
  ///
  /// - Parameters:
  ///   - request: Request to send to GetDeviceName.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getDeviceName(_ request: DeviceNameRequest, callOptions: CallOptions? = nil) -> UnaryCall<DeviceNameRequest, DeviceNameResponse> {
    return self.makeUnaryCall(path: "/MobileDeviceService/GetDeviceName",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Asynchronous client-streaming call to Publish.
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata, status and response.
  public func publish(callOptions: CallOptions? = nil) -> ClientStreamingCall<PublishRequest, PublishResponse> {
    return self.makeClientStreamingCall(path: "/MobileDeviceService/Publish",
                                        callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Asynchronous server-streaming call to Subscribe.
  ///
  /// - Parameters:
  ///   - request: Request to send to Subscribe.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  public func subscribe(_ request: SubscribeRequest, callOptions: CallOptions? = nil, handler: @escaping (SubscribeResponse) -> Void) -> ServerStreamingCall<SubscribeRequest, SubscribeResponse> {
    return self.makeServerStreamingCall(path: "/MobileDeviceService/Subscribe",
                                        request: request,
                                        callOptions: callOptions ?? self.defaultCallOptions,
                                        handler: handler)
  }

  /// Asynchronous server-streaming call to CaptureSyslog.
  ///
  /// - Parameters:
  ///   - request: Request to send to CaptureSyslog.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  public func captureSyslog(_ request: CaptureSyslogRequest, callOptions: CallOptions? = nil, handler: @escaping (CaptureSyslogResponse) -> Void) -> ServerStreamingCall<CaptureSyslogRequest, CaptureSyslogResponse> {
    return self.makeServerStreamingCall(path: "/MobileDeviceService/CaptureSyslog",
                                        request: request,
                                        callOptions: callOptions ?? self.defaultCallOptions,
                                        handler: handler)
  }

}

/// To build a server, implement a class that conforms to this protocol.
public protocol MobileDeviceServiceProvider: CallHandlerProvider {
  func getDeviceList(request: VoidData, context: StatusOnlyCallContext) -> EventLoopFuture<DeviceListResponse>
  func subscribeDeviceEvent(request: VoidData, context: StreamingResponseCallContext<SubscribeDeviceEventResponse>) -> EventLoopFuture<GRPCStatus>
  func unsubscribeDeviceEvent(request: VoidData, context: StatusOnlyCallContext) -> EventLoopFuture<VoidData>
  func getDeviceName(request: DeviceNameRequest, context: StatusOnlyCallContext) -> EventLoopFuture<DeviceNameResponse>
  func publish(context: UnaryResponseCallContext<PublishResponse>) -> EventLoopFuture<(StreamEvent<PublishRequest>) -> Void>
  func subscribe(request: SubscribeRequest, context: StreamingResponseCallContext<SubscribeResponse>) -> EventLoopFuture<GRPCStatus>
  func captureSyslog(request: CaptureSyslogRequest, context: StreamingResponseCallContext<CaptureSyslogResponse>) -> EventLoopFuture<GRPCStatus>
}

extension MobileDeviceServiceProvider {
  public var serviceName: String { return "MobileDeviceService" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  public func handleMethod(_ methodName: String, callHandlerContext: CallHandlerContext) -> GRPCCallHandler? {
    switch methodName {
    case "GetDeviceList":
      return UnaryCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.getDeviceList(request: request, context: context)
        }
      }

    case "SubscribeDeviceEvent":
      return ServerStreamingCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.subscribeDeviceEvent(request: request, context: context)
        }
      }

    case "UnsubscribeDeviceEvent":
      return UnaryCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.unsubscribeDeviceEvent(request: request, context: context)
        }
      }

    case "GetDeviceName":
      return UnaryCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.getDeviceName(request: request, context: context)
        }
      }

    case "Publish":
      return ClientStreamingCallHandler(callHandlerContext: callHandlerContext) { context in
        return self.publish(context: context)
      }

    case "Subscribe":
      return ServerStreamingCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.subscribe(request: request, context: context)
        }
      }

    case "CaptureSyslog":
      return ServerStreamingCallHandler(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.captureSyslog(request: request, context: context)
        }
      }

    default: return nil
    }
  }
}

