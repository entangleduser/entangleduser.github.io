#!/usr/bin/env swift-shell
import Command // @git/acrlc/command
import Render // ../packages/render
import func Shell.process
// import Acrylic // @git/acrlc/acrylic
import Tests // @git/acrlc/acrylic
import Time // @git/acrlc/time
/// Generate and host bespoke content, using different rendering methods.
/// This is intended to test out different methods for rendering content for
/// the target `App`.
///
/// - Important: Be sure to render and review the output before uploading.
/// Content can be filed and rendered with or without a creation / modification
/// date or other information that can be infered if the filesystem lacks this
/// information.
///
/// - parameters:
///  - render: Renders content if set. Performs a dry run by default.
///  - serve: Serves content with address `http://localhost:8080`
@main
struct Generate: Module & AsyncCommand {
 enum SyntaxHighlighter: String, LosslessStringConvertible, CaseIterable {
  case markdown, javascript, swift, css, bash, html
  func generateWASM() throws {
   switch self {
   case .markdown: // https://github.com/ikatyang/tree-sitter-markdown
    // npm install tree-sitter-markdown tree-sitter
    try process(
     "npm",
     with: "install",
     "tree-sitter",
     "tree-sitter-markdown"
    )
   case .swift: // https://github.com/alex-pinkus/tree-sitter-swift
    // npm install web-tree-sitter tree-sitter-swift
    try process(
     "npm",
     with: "install",
     "--save-dev",
     "tree-sitter",
     "tree-sitter-swift@0.4.3"
    )
   default: // https://github.com/tree-sitter/tree-sitter/blob/master/lib/binding_web/README.md
    try process(
     "npm",
     with: "install",
     "--save-dev",
     "tree-sitter-cli",
     "tree-sitter-\(rawValue)"
    )
   }
   // use the tree-sitter command
   try process(
    "tree-sitter",
    with:
    "build-wasm",
    "node_modules/tree-sitter-\(rawValue)"
   )
  }
 }

 @Option
 var highlighters: [SyntaxHighlighter] = [.swift, .markdown]
 @Flag
 var render = false
 @Option
 var hostname: URL?
 @Flag
 var serve: Bool

 public var void: some Module {
  get throws {
   if !render {
    Perform {
     print(
      "// Note:".applying(style: .boldDim),
      "Performing a dry run…".applying(style: .dim)
     )
    }
   }
   let currentFolder = Folder.current
   let contentFolder = try Folder(path: "../Content")
   /// cache folder, used to store project files
   let _ = {
    try currentFolder.createSubfolderIfNeeded(at: "../.cache")
   }

   let timeZone = try TimeZone(identifier: "UTC").throwing()

   lazy var timer: TimerProtocol = .standard
   lazy var htmlTimer: TimerProtocol = .standard
   lazy var contentTimer: TimerProtocol = .standard
   lazy var renderTimer: TimerProtocol = .standard

   // attempt to assert that this script is being ran from the correct location
   // due to limitations with swift-sh (cannot reference this file)
   Assertion(
    (try? contentFolder.parent?.subfolder(named: "Scripts"))?
     .containsFile(named: "generateHTML.swift") ?? false
   )

   // MARK: - Tools
   // generate wasm for rendering content with tree-sitter
   // these will have to be rendered using more or less javascript
   /// https://github.com/apple/swift-for-wasm-examples/blob/main/Sources/swift-audio/DOMInterop.swift
   for syntax in highlighters.unique() {
    Perform {
     print(
      "// MARK:".applying(style: .boldDim),
      "Generating tree-sitter binary for \(syntax.rawValue)"
       .applying(style: .dim)
     )
     if
      !currentFolder
       .containsFile(named: "tree-sitter-\(syntax.rawValue).wasm") {
      try syntax.generateWASM()
     }

     let targetFolder =
      try currentFolder.parent!.subfolder(at: "Sources/Javascript/")
     // copy for compiling with the target
     let binary = try currentFolder
      .file(named: "tree-sitter-\(syntax.rawValue).wasm")
     do {
      try binary.copy(to: targetFolder)
     } catch let error as PathError {
      switch error.reason {
      case .copyFailed:
       try targetFolder.containsFile(named: binary.name).throwing(
        reason: "unable to copy '\(binary.name)' to '\(targetFolder)'"
       )
      default: throw error
      }
     }
    }
   }

   // MARK: - Content
   Perform {
    timer.fire()
    contentTimer.fire()
    print(
     "// MARK:".applying(style: .boldDim),
     "Generating Content".applying(style: .dim)
    )
   }

   Map(contentFolder.subfolders) { folder in
    let files = folder.files.filter {
     try! $0[.contentType] == .renderableContent
    }
    let isEmpty = files.isEmpty
    let folderName = folder.name
    let quotedFolderName = "\"\(folder.name)\""
    let directoryName = folderName.lowercased()

    // a filesystem renderer will generate all of the needed content here
    // TODO: Implement content renderer for each folder
    Perform {
     switch folderName {
     case "Posts": break
     default: fatalError("Unknown content folder: \(quotedFolderName)")
     }
     print(
      "// TODO:".applying(style: .boldDim),
      "Implement content renderer for \(folderName) in swift package interface."
       .applying(style: .dim)
     )
    }

    Perform {
     if !isEmpty {
      print(
       "// MARK:".applying(style: .boldDim),
       "Processing \(quotedFolderName, style: .bold)".applying(style: .dim) +
        ".".applying(style: .dim)
      )
      renderTimer.fire()
     }
     else {
      print(
       "// Note:".applying(style: .boldDim),
       "\(folder.name) is empty.".applying(style: .dim)
      )
     }
    }

    // MARK: - Render
    Map(files) { file in
     let fileName = file.name
     let quotedFileName = "\"\(fileName)\""
     let fileNameExcludingExtension = file.nameExcludingExtension
     // generate code and html content that will be listed under:
     // folderName/fileID.html
     Perform.Async {
      echo("Rendering", "\(quotedFileName, style: .bold)", color: .green)
      try withTimer { timer in
       // convert filename to creation date using the format:
       // YYYY-MM-DD-HH-mm-ss
       let (isNewContent, fileCreationDate): (Bool, Date) = try {
        let split = fileName.split(separator: "-")
        if split.count > 5 {
         let integers = split[0 ..< 6].compactMap { Int(String($0)) }
         if integers.count == 6 {
          var calendar = Calendar(identifier: .gregorian)
          calendar.timeZone = timeZone
          let components = DateComponents(
           year: integers[0], month: integers[1], day: integers[2],
           hour: integers[3], minute: integers[4], second: integers[5]
          )

          if let date = calendar.date(from: components) {
           return (false, date)
          }
         }
        }
        // use either file name for creation date or file
        let date = try file.creationDate
         .throwing(reason: "Creation date could not be inferred")
        return (true, date)
       }()

       let fileID = isNewContent
        ? (
         fileCreationDate.formatted(.iso8601).map {
          $0.isLetter || $0 == ":" ? .space : $0
         } + .space + fileNameExcludingExtension
        ).casing(.kebab)
        : fileNameExcludingExtension

       if let hostname {
        print(
         "content url:",
         hostname + "\(directoryName)/\(fileID)"
        )
       }

       // if content is rendered, add missing data to filename to prevent
       // adding creation dates to old content
       if isNewContent {
        print(
         "// Note:".applying(style: .boldDim),
         "New content detected.".applying(style: .dim),
         "Renaming to \("\("\"\(fileID)\"", style: .bold)")"
          .applying(style: .dim) +
          ".".applying(style: .dim)
        )

        if render {
         try file.rename(to: fileID)
        }
       }
       echo(
        "Rendered \(quotedFileName) in",
        "\(timer.elapsed, style: .bold)",
        color: .green
       )
      }
     }
    }
    Perform {
     if !isEmpty {
      echo(
       "Processed \(quotedFolderName) in",
       "\(renderTimer.elapsed, style: .bold)\n",
       color: .green
      )
     } else {
      print()
     }
    }
   }
   // MARK: HTML
   Perform {
    echo(
     "Processed content in",
     "\(contentTimer.elapsed, style: .bold)\n",
     color: .green
    )

    print(
     "// MARK:".applying(style: .boldDim),
     "Generating HTML".applying(style: .dim)
    )

    htmlTimer.fire()
   }

   Perform {
    echo(
     "Processed HTML in",
     "\(htmlTimer.elapsed, style: .bold)\n",
     color: .green
    )
   }

   Perform {
    echo(
     "Processing completed in",
     "\(timer.elapsed, style: .bold)\n",
     color: .green
    )
   }

   // MARK: - Host
   if serve {
    Perform { print("Running!") }
   }
  }
 }
}

// MARK: - Helper Extensions
import UniformTypeIdentifiers
extension UTType {
 static let renderableContent =
  UTType(filenameExtension: "text", conformingTo: .text)!
}

@_spi(ModuleReflection) import Acrylic
extension Generate {
 mutating func main() async throws {
  do { try await callWithContext() }
  catch {
   exit(error)
  }
 }
}
