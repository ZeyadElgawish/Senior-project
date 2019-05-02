//
//  TextBookCheckTableViewController.swift
//  
//
//  Created by Romelo Lopez on 4/29/19.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TextBookCheckTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    var postData = [String]()
    var sendSelectedData = String()
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    var schoolName: String = ""
    var bookName: String = ""
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (postData as NSArray).filtered(using: searchPredicate)
        
        filteredTableData = array as! [String]
        
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let userID : String = (Auth.auth().currentUser?.uid)!
        //print("Current user ID is" + userID)
        ref = Database.database().reference()
        self.ref!.child("users").child(userID).observeSingleEvent(of: .value, with: {(snapshot) in
            //print(snapshot.value!)
            
            let value = snapshot.value as? NSDictionary
            let school = value?["school"] as? String ?? ""
            self.schoolName = school
            //print ("school name inside is: \(self.schoolName)")
            
            //retrieve and listen for changes
            self.databaseHandle = self.ref?.child("Colleges/\(self.schoolName)/\(self.bookName)/Textbook").observe(.childAdded, with: { (snapshot) in
                print (snapshot.value!)
                
                let post = snapshot.value as! String
                self.postData.append(post)
                self.tableView.reloadData()
                
            })
            
        })
        //print ("school name outside is: \(self.schoolName)")
        //Set the firebase reference
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return postData.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkCellBook", for: indexPath)
        
        if (resultSearchController.isActive) {
            let row = indexPath.row
            if let theNumberTVC2 = cell as? TextBookCheckTableViewCell {
                theNumberTVC2.textBookCheckLabel.text = filteredTableData[row]
            }
            return cell
        } else {
            let row = indexPath.row
            if let theNumberTVC2 = cell as? TextBookCheckTableViewCell {
                theNumberTVC2.textBookCheckLabel.text = postData[row]
                
                if theNumberTVC2.textBookCheckLabel.text == "  " {
                    theNumberTVC2.textBookCheckLabel.text = "Textbook Not Available"
                }
            }
            
            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        // Get Cell Label text here and storing it to the variable
        let indexPathVal: IndexPath = tableView.indexPathForSelectedRow!
        print("\(indexPathVal)")
        let currentCell = tableView.cellForRow(at: indexPathVal) as! TextBookCheckTableViewCell
        print("\(currentCell)")
        print("\(currentCell.textBookCheckLabel.text!)")
        //Storing the data to a string from the selected cell
        sendSelectedData = currentCell.textBookCheckLabel.text!
        print(sendSelectedData)
        //Now here I am performing the segue action after cell selection to the other view controller by using the segue Identifier Name
        self.performSegue(withIdentifier: "deleteBook2", sender: self)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        //Here i am checking the Segue and Saving the data to an array on the next view Controller also sending it to the next view COntroller
        if segue.identifier == "deleteBook2"{
            //Creating an object of the second View controller
            let controller = segue.destination as! ViewDeleteBookViewController
            //Sending the data here
            controller.bookNameData = sendSelectedData
            
        }
        
        
    }
 
}
