//
//  CEWorkspaceActor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 19/06/2023.
//

import Foundation
import AppKit

protocol ResourceData: AnyObject, Identifiable {
    var name: String { get set }
    var url: URL { get }

    var parentFolder: Folder? { get set }

    func resolveItem(components: [String]) -> any ResourceData
}

extension ResourceData {
    var id: URL { url }

    var children2: [any ResourceData]? {
        guard let self = self as? Folder else { return nil }
        return self.children
    }
}

class File: ResourceData {
    let url: URL
    var name: String

    weak var parentFolder: Folder?

    var document: CodeFileDocument?

    init(url: URL, name: String) {
        self.url = url
        self.name = name
    }

    func resolveItem(components: [String]) -> any ResourceData {
        if !components.isEmpty {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
        }
        return self
    }
}

class SymLink: ResourceData {
    let url: URL
    var name: String

    weak var parentFolder: Folder?

    init(url: URL, name: String) {
        self.url = url
        self.name = name
    }

    func resolveItem(components: [String]) -> any ResourceData {
        if !components.isEmpty {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
        }
        return self
    }
}

class Folder: ResourceData {
    var children: [any ResourceData] = []
    let url: URL
    var name: String

    weak var parentFolder: Folder?

    init(url: URL, name: String) {
        self.url = url
        self.name = name
    }

    func resolveItem(components: [String]) -> any ResourceData {
        if components.isEmpty {
            return self
        }

        let child = children
            .first { $0.name == components.first }

        guard let child else {
            NSLog("Warning: Failed to resolve path. Continuing silently...")
            return self
        }

        return child.resolveItem(components: Array(components.dropFirst()))
    }

    func removeChild(_ child: any ResourceData) {
        children.removeAll { $0 === child }
    }

    func addChild(_ child: any ResourceData) {
        children.append(child)
    }
}

enum Resource: Equatable {
//    static func == (lhs: Resource, rhs: Resource) -> Bool {
//        lhs.data === rhs.data
//    }

//    case file(File)
//    case folder(Folder)
//    case symlink(SymLink)

    enum Ignored: Hashable {
        case file(name: String)
        case folder(name: String)
        case url(URL)
    }

//    var data: ResourceData {
//        switch self {
//        case .file(let file):
//            return file
//        case .folder(let folder):
//            return folder
//        case .symlink(let symLink):
//            return symLink
//        }
//    }
}

//actor CEWorkspaceFileActor: ObservableObject {
//    enum FileManagerError: Error {
//        case rootFileEnumeration
//    }
//
//    @MainActor @Published var fileTree: Resource?
//
//    var ignoredResources: Set<Resource.Ignored>
//
//    init(root: URL, ignoring: Set<Resource.Ignored> = []) {
//        self.ignoredResources = ignoring
//        Task {
//            do {
//                try await buildFileTree(root: root)
//            } catch {
//                await showError(error)
//            }
//        }
//    }
//
//    @MainActor
//    func showError(_ error: any Error) {
//        let alert = NSAlert()
//        alert.informativeText = error.localizedDescription
//        alert.messageText = "Error"
//        alert.runModal()
//    }
//
//    func buildFileTree(root: URL) async throws {
//        let tree: Resource = try buildingFileTree(root: root, ignoring: ignoredResources)
//        await MainActor.run {
//            fileTree = tree
//        }
//    }
//
//    nonisolated func buildingFileTree(root: URL, ignoring: Set<Resource.Ignored>) throws -> Resource {
//        let fileProperties: Set<URLResourceKey> = [.isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey, .nameKey]
//        let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: Array(fileProperties))
//
//        guard let enumerator else { throw FileManagerError.rootFileEnumeration }
//
//        let rootFolder = Folder(url: root, name: root.lastPathComponent)
//
//        var folderStack = [rootFolder]
//        var currentLevel = 1
//
//        for case let url as URL in enumerator {
//            let properties = try url.resourceValues(forKeys: fileProperties)
//
//            let name = properties.name!
//            let isFile = properties.isRegularFile!
//            let isFolder = properties.isDirectory!
//            let isSymLink = properties.isSymbolicLink!
//
//            let level = enumerator.level
//
//            if level > currentLevel {
//                _ = folderStack.dropLast(level - currentLevel)
//                currentLevel = level
//            }
//
//            guard !ignoring.contains(.file(name: name)) && !ignoring.contains(.url(url)) else {
//                enumerator.skipDescendants()
//                continue
//            }
//
//            let resource: Resource
//            let currentFolder = folderStack.last!
//
//            if isFile {
//                resource = .file(File(url: url, name: name))
//            } else if isFolder {
//                let newFolder = Folder(url: url, name: name)
//                resource = .folder(newFolder)
//                folderStack.append(newFolder)
//                currentLevel += 1
//            } else if isSymLink {
//                resource = .symlink(SymLink(url: url, name: name))
//            } else {
//                continue
//            }
//
//            resource.data.parentFolder = currentFolder
//            currentFolder.children.append(resource)
//        }
//
//        return .folder(rootFolder)
//    }
//}