//
//  AthleteStatisticsTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class AthleteStatisticsTableViewController: UITableViewController {

    @IBOutlet weak var athleteNameLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!

    var athlete: Athlete!
    var stationAverages: [Double]?
    var overallAverage: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure header view.
        self.tableView.tableHeaderView?.addBorder(toEdges: [.bottom],
                                                  withColor: CommonConstants.tableViewCellSeparatorColor,
                                                  thickness: 1.0 / UIScreen.main.scale)
        self.athleteNameLabel.text = "\(self.athlete.firstName ?? "") \(self.athlete.lastName ?? "")"
        self.teamNameLabel.text = UserDefaults.standard.string(forKey: UserDefaultsKeys.teamName)
        
        // Compute averages for this athlete.
        self.computeAverages()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Sections: Overall, and station-by-station averages.
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : Station.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamConstants.statisticsTableViewCellID) as! StatisticsTableViewCell
        
        if indexPath.section == 0 {
            cell.configure(withTitle: "Overall", average: self.overallAverage ?? 0.0)
        } else {
            let station = Station(rawValue: Int16(indexPath.row + 1)) ?? Station.defaultValue
            let stationAverage = self.stationAverages?[indexPath.row] ?? 0.0
            cell.configure(withTitle: String(describing: station), average: stationAverage)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TeamConstants.statisticsTableViewCellHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    private func computeAverages() {
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        let sortByRoundNumber = NSSortDescriptor(key: "roundNumber", ascending: true)
        var totalNumberOfShots = 0
        var totalNumberOfHits = 0
        var shotsPerStation = [Int](repeating: 0, count: Station.allValues.count)
        var hitsPerStation = [Int](repeating: 0, count: Station.allValues.count)
        if let sheets = athlete.sheets?.sortedArray(using: [sortByDate]) as? [Sheet] {
            for sheet in sheets {
                if let rounds = sheet.rounds?.sortedArray(using: [sortByRoundNumber]) as? [Round] {
                    for round in rounds {
                        let competingAthletes = round.toCompetingAthletes().flatMap({ $0 })
                        if let indexOfAthlete = competingAthletes.index(where: { $0.firstName == self.athlete.firstName && $0.lastName == self.athlete.lastName }) {
                            let score = competingAthletes[indexOfAthlete].score
                            // Get total hits contributed by this score.
                            totalNumberOfHits += score.numberOfHits
                            totalNumberOfShots += Skeet.numberOfNonOptionShotsPerRound
                            // Get hits contributed by this score on each station.
                            for indexOfStation in 0..<Station.allValues.count {
                                // TODO: Statistics for skeet stations. Include option.
                                hitsPerStation[indexOfStation] += 0
                                let station = Station(rawValue: Int16(indexOfStation + 1))!
                                shotsPerStation[indexOfStation] += station.numberOfShots
                            }
                        }
                    }
                }
            }
        }
        // Compute averages from hits and total shots taken.
        if totalNumberOfShots > 0 {
            self.overallAverage = Double(totalNumberOfHits) / Double(totalNumberOfShots)
            self.stationAverages = [Double]()
            for indexOfStation in 0..<Station.allValues.count {
                self.stationAverages?.append(Double(hitsPerStation[indexOfStation]) / Double(shotsPerStation[indexOfStation]))
            }
        }
    }

}
