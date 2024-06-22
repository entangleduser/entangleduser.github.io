#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
@_exported import SwiftUI
#elseif os(WASI)
@_exported import TokamakDOM
@_exported import TokamakCore
#else
#error("Platform not supported.")
#endif
