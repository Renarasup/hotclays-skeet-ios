//
//  SheetExporter.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/8/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import Foundation

/// Methods for exporting a score sheet to CSV.
class SheetExporter {

    /// Get the column titles for a specified number of rounds.
    private static func columnTitles(for numberOfRounds: Int) -> [String] {
        var columnTitles = [
            "First Station",
            "First Name",
            "Last Name",
            "Gauge",
            "Yardage"
        ]
        columnTitles.append(contentsOf: (1...numberOfRounds).map({ "Round \($0)" }))
        columnTitles.append("Total")
        return columnTitles
    }

    /// Export a sheet to an ascii-encoded CSV string for emailing.
    ///
    /// - Parameter sheet: The `Sheet` to convert to a CSV string.
    /// - Returns: Data that can be sent as a CSV file via email, or `nil` on failure.
    static func csvData(from sheet: Sheet) -> Data? {
        let sortByRoundNumber = NSSortDescriptor(key: "roundNumber", ascending: true)
        guard let rounds = sheet.rounds?.sortedArray(using: [sortByRoundNumber]) as? [Round],
            rounds.count > 0 else {
            return nil
        }

        // Start with CSV header.
        let columns = columnTitles(for: rounds.count)
        var rows = [columns.joined(separator: ",")]
        
        // Add a row for each competitor.
        let firstSquad = rounds.first!.toCompetingAthletes()
        for indexOfAthlete in 0..<Station.allValues.count {
            var rowValues = ["\(indexOfAthlete + 1)"]
            let competingAthlete = firstSquad[indexOfAthlete]
            // Add athlete info.
            rowValues.append(competingAthlete.firstName)
            rowValues.append(competingAthlete.lastName)
            rowValues.append("\(competingAthlete.gauge.rawValue)")
            // Add score for each round.
            var totalNumberOfHits = 0
            for round in rounds {
                if let numberOfHits = round.numberOfHitsForAthlete(withFirstName: competingAthlete.firstName, lastName: competingAthlete.lastName) {
                    totalNumberOfHits += numberOfHits
                    rowValues.append("\(numberOfHits)")
                } else {
                    rowValues.append("")
                }
            }
            rowValues.append("\(totalNumberOfHits)")

            rows.append(rowValues.joined(separator: ","))
        }
        
        return rows.joined(separator: "\n").data(using: .ascii)
    }

    static func emailBody(for sheet: Sheet) -> String {
        let numberOfRounds = sheet.rounds?.count ?? 0
        let sIfPlural = numberOfRounds != 1 ? "s" : ""
        var lines = ["Your HotClays Skeet score sheet with \(numberOfRounds) round\(sIfPlural) is attached.", ""]
        
        lines.append("Event: \(sheet.event ?? "")")
        if let field = sheet.field {
            lines.append("Range: \(sheet.range ?? ""), Field \(field)")
        } else {
            lines.append("Range: \(sheet.range ?? "")")
        }
        if let date = sheet.date as Date? {
            lines.append("Date: \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))")
        }
        let sortByRoundNumber = NSSortDescriptor(key: "roundNumber", ascending: true)
        if let rounds = sheet.rounds?.sortedArray(using: [sortByRoundNumber]) as? [Round],
            let firstSquad = rounds.first?.toCompetingAthletes() {
            let athleteNames = firstSquad.map({ $0.fullName })
            lines.append("Squad: \(athleteNames.joined(separator: ", "))")
        }
        lines.append("Notes: \(sheet.notes ?? "None")")

        lines.append("")
        lines.append("Download HotClays Skeet from the App Store today!")

        return lines.joined(separator: "\n")
    }

}
