//
//  ScoreViewController.swift
//  HotClays Skeet
//
//  Created by Christopher Chute on 1/4/18.
//  Copyright © 2018 Christopher Chute. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var undoButtonView: UIView!
    @IBOutlet weak var undoImageView: UIImageView!
    @IBOutlet weak var missButtonView: UIView!
    @IBOutlet weak var hitButtonView: UIView!
    @IBOutlet weak var stationIndicator: UIPageControl!
    
    var scoreDelegate: ScoreDelegate?
    var editRoundDelegate: EditRoundDelegate?
    private var isEditingRound: Bool {
        return self.editRoundDelegate != nil
    }
    
    var competingAthletes: [CompetingAthlete]!
    var sheetID: String?
    var date: Date!
    var event: String!
    var range: String!
    var field: String?
    var notes: String?
    var round: Int!
    
    /// Cursor indicating shooter and shot that will be recorded next.
    internal var cursor: Cursor!
    /// Labels displaying each shooter's station, stored in section headers.
    internal var stationLabels = [UILabel]()
    /// Preloaded `UITableViewCell`s that display each shooter's score.
    internal var tableViewCells = [ScoreTableViewCell]()
    /// Stack of `CursorState`s for supporting the undo button.
    internal var undoStack = [CursorState]()
    
    @IBAction func pressedQuitButton(_ sender: UIBarButtonItem) {
        // Present an alert popup to ask for confirmation before ending the round.
        let alert = UIAlertController(title: "Quit Round?",
                                      message: "Are you sure you want to quit this round? All progress will be lost.",
                                      preferredStyle: .alert)
        alert.view.tintColor = AppColors.orange
        let endRoundAction = UIAlertAction(title: "Quit", style: .destructive, handler: { _ in
            DispatchQueue.main.async {
                self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(AppColors.black, forKey: "titleTextColor")
        alert.addAction(endRoundAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func pressedSaveButton(_ sender: UIBarButtonItem) {
        self.handleTapOnSave()
    }
    
    @objc func pressedHitOrMissButton(_ gestureRecognizer: UIGestureRecognizer) {
        // Store a snapshot of cursor state over the selected cell.
        let shotOld = self.competingAthletes[self.cursor.indexOfAthlete].score.getShot(atIndex: self.cursor.indexOfShot)
        let cursorState = CursorState(cursor: self.cursor, shot: shotOld)
        self.undoStack.append(cursorState)
        
        // Record the new shot, update the score, and advance the cursor.
        let shotNew = gestureRecognizer.view == hitButtonView ? Shot.hit : .miss
        self.recordShot(shotNew, advanceCursor: true)
    }
    
    @objc func pressedUndoButton(_ gestureRecognizer: UIGestureRecognizer) {
        if let previousCursorState = self.undoStack.popLast() {
            self.moveCursor(toIndexOfAthlete: previousCursorState.indexOfAthlete, indexOfShot: previousCursorState.indexOfShot)
            self.recordShot(previousCursorState.shot, advanceCursor: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen for taps on the scoring buttons.
        let tapUndo = UITapGestureRecognizer(target: self, action: #selector(pressedUndoButton(_:)))
        self.undoButtonView.addGestureRecognizer(tapUndo)
        self.undoImageView.tintColor = UIColor.white
        let tapHitButton = UITapGestureRecognizer(target: self, action: #selector(pressedHitOrMissButton(_:)))
        self.hitButtonView.addGestureRecognizer(tapHitButton)
        let tapMissButton = UITapGestureRecognizer(target: self, action: #selector(pressedHitOrMissButton(_:)))
        self.missButtonView.addGestureRecognizer(tapMissButton)
        
        // Style the scoring buttons.
        let buttonViews = [self.hitButtonView, self.missButtonView, self.undoButtonView]
        for buttonView in buttonViews {
            buttonView?.layer.cornerRadius = CommonConstants.buttonCornerRadius
            buttonView?.clipsToBounds = true
        }
        
        // Preload the station labels displayed in each section header.
        for _ in self.competingAthletes {
            let stationLabel = UILabel()
            stationLabel.textAlignment = .right
            stationLabel.text = Station.one.description.uppercased()
            stationLabel.font = ScoreConstants.groupedTableSectionHeaderFont
            stationLabel.textColor = AppColors.darkGray
            self.stationLabels.append(stationLabel)
        }
        
        // Preload the table view cells.
        for _ in 0..<self.competingAthletes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommonConstants.scoreTableViewCellID) as! ScoreTableViewCell
            cell.delegate = self
            self.tableViewCells.append(cell)
        }
        
        // Initialize the cursor to start at the first non-nil shooter.
        self.cursor = Cursor(indexOfAthlete: 0, indexOfShot: 0)
        
        // Listen for taps on the station indicator control.
        self.stationIndicator.addTarget(self, action: #selector(stationIndicatorValueChanged(_:)), for: .valueChanged)
    }
    
    /// Record a shot at the current cursor position, updating the
    /// underlying `CompetingAthlete`'s score with the new shot value. Advance
    /// the cursor to the next shot if `advanceCursor` is true.
    ///
    /// - Parameter shot: `Shot` to record.
    /// - Parameter advanceCursor: If true, move the cursor to the next cell.
    private func recordShot(_ shot: Shot, advanceCursor: Bool) {
        // Record the shot.
        let selectedAthlete = self.competingAthletes[self.cursor.indexOfAthlete]
        if self.cursor.indexOfShot < Skeet.numberOfNonOptionShotsPerRound {
            selectedAthlete.score.setShot(atIndex: self.cursor.indexOfShot, with: shot)
        } else {
            selectedAthlete.score.setOption(shot)
        }
        
        // Update cell with latest score.
        let cell = self.tableViewCells[self.cursor.indexOfAthlete]
        cell.update(with: self.competingAthletes[self.cursor.indexOfAthlete].score)
        
        // Compute next position for cursor.
        var indexOfNextShooter = self.cursor.indexOfAthlete
        var indexOfNextShot = self.cursor.indexOfShot
        if advanceCursor && !self.isLastShotOfRound() {
            if self.competingAthletes[self.cursor.indexOfAthlete].nextShotIsOption {
                // Athlete's next shot is option
                indexOfNextShot = Skeet.numberOfNonOptionShotsPerRound
            } else if Station.isLastShotOnStation(indexOfNextShot) {
                // Athlete is done with station
                indexOfNextShooter = (indexOfNextShooter + 1) % self.competingAthletes.count
                indexOfNextShot = self.competingAthletes[indexOfNextShooter].indexOfNextShot
            } else if indexOfNextShot == Skeet.numberOfNonOptionShotsPerRound {
                // Athlete just took option
                let indexAfterOption = self.competingAthletes[indexOfNextShooter].indexOfNextShot
                if indexAfterOption == Skeet.numberOfNonOptionShotsPerRound
                    || Station.indexOfShotWithinStation(for: indexAfterOption) == 0 {
                    // Finished round or would start a new station, so move to next athlete
                    indexOfNextShooter = (indexOfNextShooter + 1) % self.competingAthletes.count
                    indexOfNextShot = self.competingAthletes[indexOfNextShooter].indexOfNextShot
                } else {
                    indexOfNextShot = indexAfterOption
                }
            } else {
                // Athlete needs to take next shot on station
                indexOfNextShot = self.competingAthletes[indexOfNextShooter].indexOfNextShot
            }
            
        }
        self.moveCursor(toIndexOfAthlete: indexOfNextShooter, indexOfShot: indexOfNextShot)
    }
    
    /// Reload the option cell for a particular athlete.
    ///
    /// - Parameter indexOfAthlete: Index of athlete whose option cell should be reloaded.
    private func reloadOptionCell(for indexOfAthlete: Int) {
        let cell = self.tableViewCells[indexOfAthlete]
        let score = self.competingAthletes[indexOfAthlete].score
        let isTakingOption = self.cursor.indexOfAthlete == indexOfAthlete && self.cursor.indexOfShot == Skeet.numberOfNonOptionShotsPerRound
        cell.configure(with: score, at: indexOfAthlete, isTakingOption: isTakingOption)
    }
    
    internal func isLastShotOfRound() -> Bool {
        if self.cursor.indexOfAthlete == self.competingAthletes.count - 1 {
            // Last athlete, check if it's also their last shot
            let hasTakenOption = self.competingAthletes[self.cursor.indexOfAthlete].hasTakenOption
            let hasTakenAllNonOptionShots = self.competingAthletes[self.cursor.indexOfAthlete].hasTakenAllNonOptionShots
            let isLastShot = ((self.cursor.indexOfShot == Skeet.numberOfNonOptionShotsPerRound - 1 && hasTakenOption)
                                || (self.cursor.indexOfShot == Skeet.numberOfNonOptionShotsPerRound && hasTakenAllNonOptionShots))
            return isLastShot
        } else {
            return false
        }
    }
    
    @objc func stationIndicatorValueChanged(_ sender: UIPageControl) {
        // Scroll all collection views to the page control's current page.
        if let collectionView = self.tableViewCells.first?.collectionView {
            let indexPath = IndexPath(item: 0, section: sender.currentPage)
            collectionView.scrollToStation(at: indexPath, animated: true)
            self.updateStationLabels(with: sender.currentPage)
        }
    }

    /// Handle tap on one of the 'Save' buttons. Save automatically if scores are complete.
    /// Otherwise, present an alert to confirm that the user wants to save the round.
    internal func handleTapOnSave() {
        // If any incomplete scores, present an alert.
        if self.competingAthletes.contains(where: { $0 != nil && $0!.score.numberOfAttempts < Skeet.numberOfNonOptionShotsPerRound }) {
            let alert = UIAlertController(title: "Incomplete Round",
                                          message: "This round is incomplete. Are you sure you want to save it?",
                                          preferredStyle: .alert)
            alert.view.tintColor = AppColors.orange
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in self.saveRound() })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(AppColors.black, forKey: "titleTextColor")
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.saveRound()
        }
    }
    
    /// Save round to Core Data. If the `editRoundDelegate` field is set, the view controller is
    /// being used to edit a round, so just pass the updated scores back to the delegate.
    internal func saveRound() {
        if let editRoundDelegate = self.editRoundDelegate {
            // Pass updated `CompetingAthlete` array back to delegate, which will update the round.
            editRoundDelegate.didEditRound(withNew: self.competingAthletes)
        } else if let scoreDelegate = self.scoreDelegate {
            // Get the existing sheet or add a new one.
            var sheet: Sheet? = nil
            if let sheetID = self.sheetID {
                sheet = Sheet.get(sheetID)
            }
            if sheet == nil {
                sheet = Sheet.insert(date: self.date, event: self.event, range: self.range, field: self.field, notes: self.notes)
            }
            
            // Add this round to the sheet.
            Round.insert(with: self.competingAthletes, on: sheet!, roundNumber: self.round)
            scoreDelegate.didSave(sheet!)
        }
        
        // Dismiss the view controller.
        DispatchQueue.main.async {
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Present an alert asking the user to confirm final scores for the round.
    internal func presentRoundApprovalAlert() {
        // Build up message to display for each shooter. Gives name and score on last station.
        var messages = [String]()
        for competingAthlete in self.competingAthletes.flatMap({ $0 }) {
            let numberOfHits = competingAthlete.score.numberOfHits
            messages.append("\(competingAthlete.fullName): \(numberOfHits)")
        }

        // Build up post confirmation alert with 'Modify' and 'Save' actions.
        let roundApprovalAlert = UIAlertController(title: "Final Scores",
                                                   message: messages.joined(separator: "\n"),
                                                   preferredStyle: .alert)
        roundApprovalAlert.view.tintColor = AppColors.orange
        let modifyAction = UIAlertAction(title: "Modify", style: .cancel, handler: nil)
        modifyAction.setValue(AppColors.black, forKey: "titleTextColor")
        let submitAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.handleTapOnSave()
        })
        roundApprovalAlert.addAction(modifyAction)
        roundApprovalAlert.addAction(submitAction)
        
        DispatchQueue.main.async {
            self.present(roundApprovalAlert, animated: true, completion: nil)
        }
    }
    
    /// Move the cursor to change which cell is currently selected.
    /// Reload the originally selected cell and the newly selected cell.
    /// Perform any necessary scrolling to ensure the cursor is visible.
    ///
    /// - Parameters:
    ///   - indexOfAthlete: Index of shooter to be selected.
    ///   - indexOfShot: Index of shot to be selected. If option, indexOfShot == Skeet.numberOfNonOptionShotsPerRound.
    internal func moveCursor(toIndexOfAthlete indexOfAthlete: Int, indexOfShot: Int) {
        // Update cursor position, then reload cells at old and new cursor position.
        let indexOfAthleteOld = self.cursor.indexOfAthlete
        let indexPathOld = self.cursor.indexPathOfShot
        let collectionViewOld = self.tableViewCells[self.cursor.indexOfAthlete].collectionView!
        self.cursor.move(toIndexOfAthlete: indexOfAthlete, indexOfShot: indexOfShot)
        let indexOfAthleteNew = self.cursor.indexOfAthlete
        let indexPathNew = self.cursor.indexPathOfShot
        let collectionViewNew = self.tableViewCells[self.cursor.indexOfAthlete].collectionView!
        
        // Reload cell under old cursor position
        if indexPathOld.section < Station.allValues.count {
            collectionViewOld.reloadItems(at: [indexPathOld])
        } else {
            self.reloadOptionCell(for: indexOfAthleteOld)
        }
        // Reload cell under new cursor position
        if indexPathNew.section < Station.allValues.count {
            collectionViewNew.reloadItems(at: [indexPathNew])
        } else {
            self.reloadOptionCell(for: indexOfAthleteNew)
        }
        
        // Scroll vertically to make sure cursor is visible.
        let indexPathOfRowUnderCursor = IndexPath(row: 0, section: self.cursor.indexOfAthlete)
        let rectOfRowUnderCursor = tableView.rectForRow(at: indexPathOfRowUnderCursor)
        self.tableView.scrollRectToVisible(rectOfRowUnderCursor, animated: true)
        
        // Scroll horizontally to make sure cursor is visible (skip this if next shot is option).
        if self.cursor.indexOfShot < Skeet.numberOfNonOptionShotsPerRound {
            let indexPathOfShot = self.cursor.indexPathOfShot
            let collectionViewUnderCursor = self.tableViewCells[self.cursor.indexOfAthlete].collectionView!
            collectionViewUnderCursor.scrollToStation(at: indexPathOfShot, animated: true)
            self.updateStationLabels(with: indexPathOfShot.section)
        }
    }
    
    /// Update all station labels and the post indicator when scrolling horizontally.
    ///
    /// - Parameter numberOfStationsCompleted: Number of posts completed, used to set the post labels.
    internal func updateStationLabels(with numberOfStationsCompleted: Int) {
        for indexOfAthlete in 0..<self.competingAthletes.count {
            let currentStation = Station.one.next(advancingBy: numberOfStationsCompleted)
            self.stationLabels[indexOfAthlete].text = currentStation.description.uppercased()
        }
        self.stationIndicator.currentPage = numberOfStationsCompleted
    }
    
}

/// Stores the cursor position and state of a cell under the cursor.
/// `CursorState`s are stored on the undo stack for supporting the undo operation.
internal struct CursorState {
    
    let indexOfAthlete: Int
    let indexOfShot: Int
    let shot: Shot
    
    init(cursor: Cursor, shot: Shot) {
        self.indexOfAthlete = cursor.indexOfAthlete
        self.indexOfShot = cursor.indexOfShot
        self.shot = shot
    }
    
}

/// Keeps track of the next shot to be recorded. Visually the cell
/// under the cursor has a black outline.
internal class Cursor {
    
    private(set) var indexOfAthlete: Int
    private(set) var indexOfShot: Int   // If option, indexOfShot == Skeet.numberOfNonOptionShotsPerRound
    
    /// Get the `IndexPath` at which the selected shot is stored in a
    /// `UICollectionView`. Each section stores shots for a single post.
    public var indexPathOfShot: IndexPath {
        get {
            if self.indexOfShot < Skeet.numberOfNonOptionShotsPerRound {
                // Non-option shot
                let section = Station.indexOfStation(for: self.indexOfShot)
                let item = Station.indexOfShotWithinStation(for: self.indexOfShot)
                return IndexPath(item: item, section: section)
            } else {
                return IndexPath(item: 0, section: Station.allValues.count)  // Section 8 => Option
            }
        }
    }
    
    init(indexOfAthlete: Int, indexOfShot: Int) {
        self.indexOfAthlete = indexOfAthlete
        self.indexOfShot = indexOfShot
    }
    
    func move(toIndexOfAthlete indexOfAthlete: Int, indexOfShot: Int) {
        self.indexOfAthlete = indexOfAthlete
        self.indexOfShot = indexOfShot
    }
    
}

extension ScoreViewController: ScoreTableViewCellDelegate {
    
    func didTapOptionCell(forIndexOfAthlete indexOfAthlete: Int) {
        self.moveCursor(toIndexOfAthlete: indexOfAthlete, indexOfShot: Skeet.numberOfNonOptionShotsPerRound)
    }
    
}

