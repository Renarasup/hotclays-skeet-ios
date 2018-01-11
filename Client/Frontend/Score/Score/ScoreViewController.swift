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
    var date: Date!
    var event: String!
    var range: String!
    var field: Int!
    var round: Int!
    var notes: String!
    
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
        let shotOld = self.competingAthletes[self.cursor.indexOfShooter].score.getShot(atIndex: self.cursor.indexOfShot)
        let cursorState = CursorState(cursor: self.cursor, shot: shotOld)
        self.undoStack.append(cursorState)
        
        // Record the new shot, update the score, and advance the cursor.
        let shotNew = gestureRecognizer.view == hitButtonView ? Shot.hit : .miss
        self.recordShot(shotNew, advanceCursor: true)
    }
    
    @objc func pressedUndoButton(_ gestureRecognizer: UIGestureRecognizer) {
        if let previousCursorState = self.undoStack.popLast() {
            self.moveCursor(toIndexOfShooter: previousCursorState.indexOfShooter, indexOfShot: previousCursorState.indexOfShot)
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
            self.tableViewCells.append(cell)
        }
        
        // Initialize the cursor to start at the first non-nil shooter.
        self.cursor = Cursor(indexOfShooter: 0, indexOfShot: 0)
        
        // Listen for taps on the station indicator control.
        self.stationIndicator.addTarget(self, action: #selector(stationIndicatorValueChanged(_:)), for: .valueChanged)
    }
    
    /// Record a shot at the current cursor position, updating the
    /// underlying `CompetingAthlete`'s score with the new shot value. Advance
    /// the cursor to the next shot if `advanceCursor` is true.
    ///
    /// - Parameter shot: `Shot` to record. If nil, shot will be reset to not attempted.
    /// - Parameter advanceCursor: If true, move the cursor to the next cell.
    private func recordShot(_ shot: Shot, advanceCursor: Bool) {
        // Record the shot.
        let selectedAthlete = self.competingAthletes[self.cursor.indexOfShooter]
        selectedAthlete.score.setShot(atIndex: self.cursor.indexOfShot, with: shot)
        
        // Update cell with latest score.
        let cell = self.tableViewCells[self.cursor.indexOfShooter]
        cell.update(with: self.competingAthletes[self.cursor.indexOfShooter].score)
        
        // Compute next position for cursor.
        var indexOfNextShooter = self.cursor.indexOfShooter
        var indexOfNextShot = self.cursor.indexOfShot
        if advanceCursor && !self.isLastShotOfRound() {
            // Advance the shooter, wrap around to next shot.
            indexOfNextShooter += 1
            if indexOfNextShooter == self.competingAthletes.count {
                indexOfNextShooter = 0
                indexOfNextShot += 1
            }
        }
        self.moveCursor(toIndexOfShooter: indexOfNextShooter, indexOfShot: indexOfNextShot)
    }
    
    internal func isLastShotOfRound() -> Bool {
        let isLastShooter = self.cursor.indexOfShooter == self.competingAthletes.count - 1
        let isLastShot = self.cursor.indexOfShot == Skeet.numberOfNonOptionShotsPerRound - 1
        return isLastShooter && isLastShot
    }
    
    @objc func stationIndicatorValueChanged(_ sender: UIPageControl) {
        // Scroll all collection views to the page control's current page.
        if let cell = self.tableViewCells.first,
            let collectionView = cell.collectionView {
            let indexPath = IndexPath(item: 0, section: sender.currentPage)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
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
            let sheet = Sheet.getOrInsert(date: self.date, event: self.event, range: self.range, field: self.field, notes: self.notes)
            Round.insert(with: self.competingAthletes, on: sheet, roundNumber: self.round)
            
            scoreDelegate.didSave(sheet)
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
    ///   - indexOfShooter: Index of shooter to be selected.
    ///   - indexOfShot: Index of shot to be selected.
    internal func moveCursor(toIndexOfShooter indexOfShooter: Int, indexOfShot: Int) {
        // Update cursor position, then reload cells at old and new cursor position.
        let indexPathOld = self.cursor.indexPathOfShot
        let collectionViewOld = self.tableViewCells[self.cursor.indexOfShooter].collectionView!
        self.cursor.move(toIndexOfShooter: indexOfShooter, indexOfShot: indexOfShot)
        let indexPathNew = self.cursor.indexPathOfShot
        let collectionViewNew = self.tableViewCells[self.cursor.indexOfShooter].collectionView!
        collectionViewOld.reloadItems(at: [indexPathOld])
        collectionViewNew.reloadItems(at: [indexPathNew])
        
        // Scroll vertically to make sure cursor is visible.
        let indexPathOfRowUnderCursor = IndexPath(row: 0, section: self.cursor.indexOfShooter)
        let rectOfRowUnderCursor = tableView.rectForRow(at: indexPathOfRowUnderCursor)
        self.tableView.scrollRectToVisible(rectOfRowUnderCursor, animated: true)
        
        // Scroll horizontally to make sure cursor is visible.
        let indexOfPostUnderCursor = self.cursor.indexOfShot / Skeet.numberOfShotsPerStation
        let indexPathOfFirstShotInPost = IndexPath(item: 0, section: indexOfPostUnderCursor)
        let collectionViewUnderCursor = self.tableViewCells[self.cursor.indexOfShooter].collectionView!
        collectionViewUnderCursor.scrollToItem(at: indexPathOfFirstShotInPost, at: .left, animated: true)
        self.updateStationLabels(with: indexOfPostUnderCursor)
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
    
    let indexOfShooter: Int
    let indexOfShot: Int
    let shot: Shot
    
    init(cursor: Cursor, shot: Shot) {
        self.indexOfShooter = cursor.indexOfShooter
        self.indexOfShot = cursor.indexOfShot
        self.shot = shot
    }
    
}

/// Keeps track of the next shot to be recorded. Visually the cell
/// under the cursor has a black outline.
internal class Cursor {
    
    private(set) var indexOfShooter: Int
    private(set) var indexOfShot: Int
    
    init(indexOfShooter: Int, indexOfShot: Int) {
        self.indexOfShooter = indexOfShooter
        self.indexOfShot = indexOfShot
    }
    
    /// Get the `IndexPath` at which the selected shot is stored in a
    /// `UICollectionView`. Each section stores shots for a single post.
    public var indexPathOfShot: IndexPath {
        get {
            let todo = "Make this work for skeet stations"
            let item = Int.mod(self.indexOfShot, 5)
            let section = self.indexOfShot / 5
            return IndexPath(item: item, section: section)
        }
    }
    
    func move(toIndexOfShooter indexOfShooter: Int, indexOfShot: Int) {
        self.indexOfShooter = indexOfShooter
        self.indexOfShot = indexOfShot
    }
    
}

