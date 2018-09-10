import Foundation

/// Returns true if it appears the device is jailbroken
var isJailbroken: Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    return sandboxBreached || evidenceOfSymbolLinking || jailbreakFileExists
    #endif
}

private var jailbreakFileExists: Bool {
    let fileManager = FileManager.default
    return jailbreakFilePaths.contains { path in
        if fileManager.fileExists(atPath: path) {
            return true
        }
        if let file = fopen(path, "r") {
            fclose(file)
            return true
        }
        return false
    }
}

private let jailbreakFilePaths = [
    "/Applications/Cydia.app", "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash", "/usr/sbin/sshd", "/etc/apt", "/private/var/lib/apt/"
]

private var sandboxBreached: Bool {
    guard (try? " ".write(toFile: "/private/jailbreak.txt",
                          atomically: true,
                          encoding: .utf8)) == nil
        else {
            return true
    }
    return false
}

private var evidenceOfSymbolLinking: Bool {
    var s = stat()
    if lstat("/Applications", &s) == 0 {
        return (s.st_mode & S_IFLNK == S_IFLNK)
    }
    return false
}
