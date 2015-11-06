import UIKit
import Alamofire

class Events_Activities_ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var TableData : JSON = []
    var date = ""
    var today = "";
    @IBOutlet var dateLabel: UILabel!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableAsArray = TableData["Activities"].arrayValue
        return tableAsArray.count

    }
     
    //@IBOutlet weak var MealTimeSegmentedControl: UISegmentedControl!
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var activityJO = TableData["Activities"][indexPath.row]
        let eventName = activityJO["eventName"].stringValue
        
        cell.textLabel?.text = eventName
        
        return cell;
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Activities"
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var activityJO = TableData["Activities"][indexPath.row]
        let eventName = activityJO["eventName"].stringValue
        let eventDesc = activityJO["eventDescription"].stringValue
        let startTime = activityJO["startTime"].stringValue
        let endTime = activityJO["endTime"].stringValue
        let location = activityJO["eventLocation"].stringValue
        
        let alert = UIAlertView();
        alert.title = eventName
        let labelt = eventDesc + "\n" + "Location: " + location + "\n\n" + "Start Time: " + startTime + "\n\n" + "End Time: " + endTime
        
        alert.message = labelt
        
        alert.addButtonWithTitle("Dismiss")
        alert.show()
        self.tableView.resignFirstResponder()
        
    }
    
    @IBAction func changeDate(sender: AnyObject) {
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel") {
            (date) -> Void in
            //self.textField.text = "\(date)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" //format style. Browse online to get a format that fits your needs.
            let dateString = dateFormatter.stringFromDate(date)
            self.date = dateString
            self.loadActivities()
            
        }

    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let date = NSDate() //get the time, in this case the time an object was created.
        //format date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(date)
        self.date = dateString
        loadActivities()
    }
    @IBAction func navbarclicked(sender: AnyObject) {
        AboutScreen.showAboutScreen(self)
    }
    func loadActivities() {
        dateLabel.text = self.date
        if (today != self.date) {
            today = self.date;
            SwiftSpinner.show("Loading Activities");
        }
        
        Alamofire.request(.GET,"http://saa.ma1geek.org/getActivities.php", parameters:["date":self.date]).responseJSON{response in
            SwiftSpinner.hide();
            if let data = response.2.value {
            let json = JSON(data)
            self.TableData = json
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                return
            })
            // see https://github.com/SwiftyJSON/SwiftyJSON
            }
            else {
                let alert = UIAlertView();
                alert.title = "Try again"
                alert.message = "Please check your network connection to load the latest activities."
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

