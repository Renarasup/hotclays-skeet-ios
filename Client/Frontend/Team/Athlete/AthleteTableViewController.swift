//
//  AthleteTableViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/7/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class AthleteTableViewController: UITableViewController {

    @IBOutlet weak var athleteNameLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    var athlete: Athlete? { didSet { self.configureHeaderView() } }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView?.addBorder(toEdges: [.bottom], withColor: CommonConstants.tableViewCellSeparatorColor, thickness: 1.0 / UIScreen.main.scale)
        self.configureHeaderView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.selectableTableViewCellID) as! SelectableTableViewCell
        let description: String
        if indexPath.row == 0 {
            description = "Sheets"
        } else if indexPath.row == 1 {
            description = "Statistics"
        } else {
            description = "Set Defaults"
        }

        cell.configure(with: description)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let athlete = self.athlete else {
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
            return
        }

        if indexPath.row == 0 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: TeamConstants.showSheetsSegueID, sender: self)
            }
        } else if indexPath.row == 1 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: TeamConstants.showStatisticsSegueID, sender: self)
            }
        } else {
            // Set default gauge and yardage.
            if let navigationController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: ScoreConstants.editAthleteNavigationControllerID) as? UINavigationController,
                let editAthleteTableViewController = navigationController.viewControllers.first as? EditAthleteTableViewController {
                editAthleteTableViewController.athleteName = "\(athlete.firstName ?? "") \(athlete.lastName ?? "")"
                editAthleteTableViewController.indexOfAthlete = 0
                editAthleteTableViewController.selectedGauge = Gauge(rawValue: athlete.defaultGauge) ?? Gauge.defaultValue
                editAthleteTableViewController.selectedYardage = Yardage(rawValue: athlete.defaultYardage) ?? Yardage.defaultValue
                editAthleteTableViewController.delegate = self
                DispatchQueue.main.async {
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CommonConstants.selectableTableViewCellHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TeamConstants.showSheetsSegueID,
            let sheetsTableViewController = segue.destination as? AthleteSheetsTableViewController {
            sheetsTableViewController.athlete = self.athlete
        } else if segue.identifier == TeamConstants.showStatisticsSegueID,
            let statisticsTableViewController = segue.destination as? AthleteStatisticsTableViewController {
            statisticsTableViewController.athlete = self.athlete
        }
    }

    func configureHeaderView() {
        if let athlete = self.athlete {
            self.athleteNameLabel?.text = "\(athlete.firstName ?? "") \(athlete.lastName ?? "")"
            self.athleteNameLabel?.textColor = AppColors.orange
            self.teamNameLabel?.text = UserDefaults.standard.string(forKey: UserDefaultsKeys.teamName)
        } else {
            self.athleteNameLabel?.text = "No Athlete"
            self.athleteNameLabel?.textColor = AppColors.darkGray
            self.teamNameLabel?.text = "-"
        }
    }

}

extension AthleteTableViewController: EditAthleteDelegate {
    
    func didEditAthlete(at indexOfAthlete: Int, gauge: Gauge, yardage: Yardage) {
        guard let athlete = self.athlete else {
            return
        }
        athlete.managedObjectContext?.performAndWait {
            athlete.defaultGauge = gauge.rawValue
            athlete.defaultYardage = yardage.rawValue
            try? athlete.managedObjectContext?.save()
        }
    }
    
}
