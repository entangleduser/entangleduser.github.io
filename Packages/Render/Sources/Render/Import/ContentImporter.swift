public protocol ContentImporter<Source, Output> {
 associatedtype Source
 associatedtype Output
 func `import`(_ source: Source) throws -> Output
}

