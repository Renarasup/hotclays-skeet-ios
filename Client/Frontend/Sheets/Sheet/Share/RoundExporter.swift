//
//  RoundExporter.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/8/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

/// Methods for exporting a single round to CSV file.
class RoundExporter {
    
    /// Title for each column in an exported round's spreadsheet.
    static let columnTitles = [
        "First Station",
        "First Name",
        "Last Name",
        "Gauge",
        "Yardage",
        "Shot 1",
        "Shot 2",
        "Shot 3",
        "Shot 4",
        "Shot 5",
        "Shot 6",
        "Shot 7",
        "Shot 8",
        "Shot 9",
        "Shot 10",
        "Shot 11",
        "Shot 12",
        "Shot 13",
        "Shot 14",
        "Shot 15",
        "Shot 16",
        "Shot 17",
        "Shot 18",
        "Shot 19",
        "Shot 20",
        "Shot 21",
        "Shot 22",
        "Shot 23",
        "Shot 24",
        "Shot 25",
        "Total"
    ]
    
    /// Export a round to an ascii-encoded CSV string for emailing.
    ///
    /// - Parameter round: The `Round` to convert to a CSV string.
    /// - Returns: Data that can be sent as a CSV file via email, or `nil` on failure.
    static func csvData(from round: Round) -> Data? {
        // Start with CSV header.
        var rows = [columnTitles.joined(separator: ",")]
        
        // Add a row for each competitor.
        let competingAthletes = round.toCompetingAthletes()
        for indexOfAthlete in 0..<Station.allValues.count {
            var rowValues = ["\(indexOfAthlete + 1)"]
            if let competingAthlete = competingAthletes[indexOfAthlete] {
                // Add athlete info.
                rowValues.append(competingAthlete.firstName)
                rowValues.append(competingAthlete.lastName)
                rowValues.append("\(competingAthlete.gauge.rawValue)")
                rowValues.append("\(competingAthlete.yardage.rawValue)")
                // Add value for each shot.
                for i in 0..<Trap.numberOfShotsPerRound {
                    let shot = competingAthlete.score.getShot(atIndex: i)
                    rowValues.append("\(shot == .hit ? "1" : "0")")
                }
                rowValues.append("\(competingAthlete.score.numberOfHits)")
            } else {
                rowValues.append(contentsOf: (0..<columnTitles.count - 1).map({ _ in "" }))
            }
            rows.append(rowValues.joined(separator: ","))
        }
        
        return rows.joined(separator: "\n").data(using: .ascii)
    }

    static func emailBody(for round: Round) -> String {
        var lines = ["Your HotClays Skeet round is attached.", ""]

        if let sheet = round.sheet {
            lines.append("Event: \(sheet.event ?? "")")
            lines.append("Range: \(sheet.range ?? ""), Field \(sheet.field)")
            if let date = sheet.date as Date? {
                lines.append("Date: \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))")
            }
        }

        let athleteNames = round.toCompetingAthletes().flatMap({ $0?.fullName })
        lines.append("Squad: \(athleteNames.joined(separator: ", "))")

        lines.append("")
        lines.append("Download HotClays Skeet from the App Store today!")

        return lines.joined(separator: "\n")
    }

}
