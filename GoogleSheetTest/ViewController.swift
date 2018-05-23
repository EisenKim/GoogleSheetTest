//
//  ViewController.swift
//  GoogleSheetTest
//
//  Created by Myeong chul Kim on 2017. 9. 17..
//  Copyright © 2017년 Myeong chul Kim. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    
    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    var arrValues = [[Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        signInButton.frame.origin = CGPoint(x: 100.0, y: 100.0)
//        output.frame.origin = CGPoint(x: 0.0, y: 0.0)
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            listMajors()
            setDatas()
            writeValues()
        }
    }
    
    func setDatas() {
        self.arrValues = [["TRUE", "FALSE", "TRUE", "FALSE","FALSE"], ["TRUE", "FALSE", "TRUE", "FALSE","FALSE"], ["TRUE", "FALSE", "TRUE", "FALSE","FALSE"], ["TRUE", "FALSE", "TRUE", "FALSE","FALSE"], ["TRUE", "FALSE", "TRUE", "FALSE","FALSE"],["TRUE", "FALSE", "TRUE", "FALSE","FALSE"],["TRUE", "FALSE", "TRUE", "FALSE","FALSE"]]
    }
    
    // Display (in the UITextView) the names and majors of students in a sample
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1WHzRVc7wIhoN7NbjVDnY7atEeYg7OiY1amfPTZnM5O8/edit
    func listMajors() {
        output.text = "Getting sheet data..."
        let spreadsheetId = "1XjbwU9lH_8I5O3HSrdvhFWCnVdXjBQFfCqx1SQ_ORxQ"
        let range = "A1:F"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var majorsString = ""
        let rows = result.values!
        
        if rows.isEmpty {
            output.text = "No data found."
            return
        }
        
        majorsString += "Name, Major:\n"
        for row in rows {
            let name = row[0]
            var value = ""
            if row.count > 1 {
                value = row[1] as! String
            } else {
                value = ""
            }
            
            majorsString += "\(name), \(value)\n"
        }
        
        output.text = majorsString
    }
    
    @objc func dummy(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        print("OK")
    }
    
    @objc func writeValues() {
        let spreadsheetId = "1XjbwU9lH_8I5O3HSrdvhFWCnVdXjBQFfCqx1SQ_ORxQ"
        let range = "B2:F8"
        let valueRange = GTLRSheets_ValueRange.init()
        valueRange.values = self.arrValues
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
        query.valueInputOption = "USER_ENTERED"
        service.executeQuery(query, delegate: self, didFinish: #selector(self.dummy(ticket:finishedWithObject:error:)))
            
//            .query(withSpreadsheetId: spreadsheetId, range:range)
//        service.executeQuery(query,
//                             delegate: self,
//                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
    }
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

