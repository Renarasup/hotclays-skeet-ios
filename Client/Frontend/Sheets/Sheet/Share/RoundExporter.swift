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
        "First Name",
        "Last Name",
        "Gauge",
        "High 1 (Single)",
        "Low 1 (Single)",
        "High 1 (Double)",
        "Low 1 (Double)",
        "High 2 (Single)",
        "Low 2 (Single)",
        "High 2 (Double)",
        "Low 2 (Double)",
        "High 3 (Single)",
        "Low 3 (Single)",
        "High 4 (Single)",
        "Low 4 (Single)",
        "High 5 (Single)",
        "Low 5 (Single)",
        "High 6 (Single)",
        "Low 6 (Single)",
        "Low 6 (Double)",
        "High 6 (Double)",
        "High 7 (Single)",
        "Low 7 (Single)",
        "Low 7 (Double)",
        "High 7 (Double)",
        "High 8 (Single)",
        "Low 8 (Single)",
        "Option",
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
        for indexOfAthlete in 0..<competingAthletes.count {
            var rowValues = [String]()
            let competingAthlete = competingAthletes[indexOfAthlete]
            // Add athlete info.
            rowValues.append(competingAthlete.firstName)
            rowValues.append(competingAthlete.lastName)
            rowValues.append("\(competingAthlete.gauge.rawValue)")
            // Add value for each shot.
            for i in 0..<Skeet.numberOfNonOptionShotsPerRound {
                let shot = competingAthlete.score.getShot(atIndex: i)
                rowValues.append("\(shot == .hit ? 1 : 0)")
            }
            rowValues.append("\(competingAthlete.score.option.shot == .hit ? 1 : 0)")
            rowValues.append("\(competingAthlete.score.numberOfHits)")
            rows.append(rowValues.joined(separator: ","))
        }
        
        return rows.joined(separator: "\n").data(using: .ascii)
    }

    static func emailBody(for round: Round) -> String {
        var lines = ["Your HotClays Skeet round is attached.", ""]

        if let sheet = round.sheet {
            lines.append("Event: \(sheet.event ?? "")")
            if let field = sheet.field {
                lines.append("Range: \(sheet.range ?? ""), Field \(field)")
            } else {
                lines.append("Range: \(sheet.range ?? "")")
            }
            if let date = sheet.date as Date? {
                lines.append("Date: \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))")
            }
        }

        let athleteNames = round.toCompetingAthletes().map({ $0.fullName })
        lines.append("Squad: \(athleteNames.joined(separator: ", "))")

        lines.append("")
        lines.append("Download HotClays Skeet from the App Store today!")

        return lines.joined(separator: "\n")
    }

}
