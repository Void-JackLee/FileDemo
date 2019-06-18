//
//  File.swift
//  FileDemo by 李弘辰
//
//  Created by 李弘辰 on 2019/6/17.
//  Copyright © 2019 李弘辰. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//

import Foundation

class File
{
    private let manager = FileManager.default
    private(set) var path : String
    private(set) var url : URL
    
    /**
     Initical the *File* instance with path.
     
     - Parameters:
        - path: A file's absolute path.
     */
    init(path : String) {
        self.path = File.formatPath(path)
        self.url = URL(fileURLWithPath: self.path)
    }
    
    /**
     Initical the *File* instance with url.
     
     - Parameters:
        - url: A file's absolute url.
     */
    convenience init(url : URL) {
        self.init(path : url.path)
    }
    
    /**
     Judge a file or directory if it exsits.
     
     - Returns: Returns *true* if a file at the specified path exists, or *false* if the file does not exist or its existence could not be determined.
     */
    func isExsits() -> Bool
    {
        return manager.fileExists(atPath: path)
    }
    
    /**
     Judge a file if it is a directory.
     
     - Returns: Returns *true* if a file at the specified path exists and it is a directory, or *false* if the file does not exist or its existence could not be determined or it is not a directory.
     */
    func isDirectory() -> Bool {
        var directoryExists = ObjCBool.init(false)
        let fileExists = manager.fileExists(atPath: path, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
    
    /**
     Append extra path to origin file path.
     
     - Parameters:
        - childName: File or directory name under its parent directory.
     
     - Returns: Appended path with *File* instance.
     */
    func append(childName : String) -> File {
        return File(path: "\(path)/\(childName)")
    }
    
    /**
     Get parent directory path of a file or directory.
     
     - Returns: Parent directory path.
     */
    func getParentPath() -> String {
        var separatedStr = File.separate(path)
        for i in (0 ..< separatedStr.count).reversed()
        {
            if separatedStr[i] == "/"
            {
                if i != 0
                {
                    separatedStr.remove(at: i)
                }
                break
            }
            separatedStr.remove(at: i)
        }
        return String(separatedStr)
    }
    
    /**
     Get parent directory path with a *File* instance of a file or directory.
     
     - Returns: Parent directory *File* instance.
     */
    func getParentFile() -> File{
        return File(path: getParentPath())
    }
    
    /**
     Get parent directory name of a file or directory.
     
     - Returns: Parent directory name.
     */
    func getParentName() -> String {
        var separatedStr = File.separate(path)
        var isRemoved : Int8 = 0
        for i in (0 ..< separatedStr.count).reversed()
        {
            if separatedStr[i] == "/"
            {
                if isRemoved == 0
                {
                    if i != 0
                    {
                        separatedStr.remove(at: i)
                    }
                    isRemoved = 1
                }else if isRemoved == 1
                {
                    isRemoved = 2
                }
            }
            if isRemoved == 0 || isRemoved == 2
            {
                separatedStr.remove(at: i)
            }
        }
        return String(separatedStr)
    }
    
    /**
     Get name of current file or directory.
     
     - Returns: Name of current file or directory.
     */
    func getName() -> String
    {
        if path == "/"
        {
            return "/"
        }
        var names = [Character]()
        for c in path.reversed()
        {
            if c == "/"
            {
                break
            }
            names.insert(c, at: 0)
        }
        return String(names)
    }
    
    /**
     Append extra path to origin file path.
     
     - Parameters:
        - withIntermediateDirectories: If true, this method creates any nonexistent parent directories as part of creating the directory in path. If false, this method fails if any of the intermediate parent directories does not exist. This method also fails if any of the intermediate path elements corresponds to a file and not a directory.
        - attributes: The file attributes for the new directory and any newly created intermediate directories. You can set the owner and group numbers, file permissions, and modification date. If you specify nil for this parameter or omit a particular value, one or more default values are used as described in the discussion. For a list of keys you can include in this dictionary, see Supporting Types. Some of the keys, such as hfsCreatorCode and hfsTypeCode, do not apply to directories.
     
     - Returns: Returns *true* if the directory was created, *true* if createIntermediates is set and the directory already exists, or *false* if an error occurred.
     */
    func createDirectory(withIntermediateDirectories : Bool, attributes: [FileAttributeKey : Any]?) throws -> Bool
    {
        if isExsits()
        {
            return false
        }
        try manager.createDirectory(atPath: path, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
        if isExsits()
        {
            return true
        }
        return false
    }
    
    /**
     Write NSDictionary to the plist file.
     
     - Parameters:
        - with : Instance of NSDictionary.
     */
    func write(with : NSDictionary) throws
    {
        try with.write(to: url)
    }
    
    /**
     List the contents of a directory or a file's parent directory's contents.
     
     - Returns: Contents of a *File(Directory)* instance.
     */
    func list() throws -> [String]
    {
        if isDirectory()
        {
            return try manager.contentsOfDirectory(atPath: path)
        }else
        {
            let parentDir = getParentFile()
            if parentDir.isDirectory()
            {
                return try manager.contentsOfDirectory(atPath: parentDir.getParentPath())
            } else
            {
                throw NSError(domain: "Parent directory no found!", code: NSNotFound, userInfo: nil)
            }
        }
    }
    
    /**
     Format any Unix path to a proper way flexibly.
     
     - Parameters:
        - str : Any Unix path.
     
     - Returns: Formated path.
     */
    static func formatPath(_ str : String) -> String
    {
        var p = str
        // Get home directory
        if str.starts(with: "~")
        {
            p = NSHomeDirectory() + String(str.suffix(str.count - 1))
        }
        if p.starts(with: "/")
        {
            p = String(p.suffix(p.count - 1))
        }
        // Remove repetition
        var separatedStr = File.separate(p)
        var isStart = true
        var isSeparater = false
        for i in (0 ..< separatedStr.count).reversed()
        {
            if separatedStr[i] == "/"
            {
                if isStart
                {
                    separatedStr.remove(at: i)
                } else {
                    if !isSeparater
                    {
                        isSeparater = true
                    } else {
                        separatedStr.remove(at: i)
                    }
                }
            } else
            {
                isStart = false
                isSeparater = false
            }
        }
        p = String(separatedStr)
        if !p.starts(with: "/")
        {
            p = "/" + p
        }
        //var separatedPath = p.split(separator: "/")
        //separatedPath.insert("/", at: 0)
        //print(separatedPath)
     
        
        return p
    }
    
    private static func separate(_ str : String) -> [Character]
    {
        var separatedStr = [Character]()
        for c in str
        {
            separatedStr.append(c)
        }
        return separatedStr
    }
}