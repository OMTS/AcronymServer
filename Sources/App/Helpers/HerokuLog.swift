//
//  HerokuLog.swift
//  App
//
//  Created by Iman Zarrabian on 27/06/2018.
//

//
// 參考 https://github.com/vapor/vapor/issues/796
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation

func HerokuLog(_ items: Any..., separator: String = " ", terminator: String = "\n")
{
    var stream = StderrOutputStream()

    print(items, separator: separator, terminator: terminator, to: &stream)
}

struct StderrOutputStream: TextOutputStream
{
    func write(_ string: String)
    {
        var filteredString = string.replacingOccurrences(of: "\"", with: "")

        let stringStartsAndEndsWithBrackets = string.characters.first == "[" && string.characters.last == "]"

        if !string.isEmpty && string != "\n" && stringStartsAndEndsWithBrackets
        {
            filteredString = filteredString.susbtring(offestFromStart: 1, offestFromEnd: 1)
        }

        fputs(filteredString, stderr)
    }
}

extension String
{
    func susbtring(offestFromStart: Int, offestFromEnd: Int) -> String
    {
        let start = index(self.startIndex, offsetBy: offestFromStart)
        let end   = index(self.endIndex, offsetBy: -offestFromEnd)
        let range = start ..< end

        return substring(with: range)
    }
}
