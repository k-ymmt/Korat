//
//  PluginManager.swift
//  Korat
//
//  Created by Kazuki Yamamoto on 2020/02/24.
//  Copyright © 2020 kymmt. All rights reserved.
//

import Foundation
import KoratPlugin

class PluginManager {
    func loadPlugins() -> [Plugin.Type] {
        var plugins: [Plugin.Type] = []
        if let builtinPluginURL = Bundle.main.builtInPlugInsURL,
            let builtinPlugins = loadPlugins(from: builtinPluginURL) {
            plugins += builtinPlugins
            print("load plugins from built-in: \(builtinPluginURL.absoluteString)")
        }
        let userPluginURLs = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: [.localDomainMask, .networkDomainMask, .userDomainMask]
        )
        for url in userPluginURLs.map({ $0.appendingPathComponent("Korat/PlugIns") }) {
            guard FileManager.default.fileExists(atPath: url.absoluteString),
                let userPlugins = loadPlugins(from: url) else {
                continue
            }

            plugins += userPlugins
        }

        return plugins
    }
    
    private func loadPlugins(from path: URL) -> [Plugin.Type]? {
        guard let items = FileManager.default.enumerator(
            at: path,
            includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else {
            return nil
        }
        
        var plugins: [Plugin.Type] = []
        while let item = items.nextObject() as? URL {
            guard item.pathExtension == "plugin",
                let bundle = Bundle(url: item) else {
                    continue
            }
            
            guard bundle.load() else {
                print("[WARN] cannot load bundle: \(item.absoluteString)")
                continue
            }
            guard let plugin = bundle.principalClass as? Plugin.Type else {
                print("[WARN] plugin principal class is not inherited type Plugin: \(item.absoluteString)")
                continue
            }
            
            plugins.append(plugin)
        }
        
        return plugins
    }
}
