import UIKit
import Alamofire

class Food_Meals_ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    var TableData : JSON = []
    var selectedTime = ""
    var date = ""
    var today = ""
    @IBOutlet var dateLabel: UILabel!
    
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let tableAsDictionary = TableData[selectedTime].dictionaryValue
        return tableAsDictionary.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var tableAsDictionary = TableData[selectedTime].dictionaryValue
        let key : String = Array(tableAsDictionary.keys)[section]
        let testc = tableAsDictionary[key]!.count
        return testc
    }
    @IBAction func mealTimeChanged(sender: UISegmentedControl) {
        self.selectedTime = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!
        self.tableView.reloadData()
    }

    @IBOutlet weak var MealTimeSegmentedControl: UISegmentedControl!
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(selectedTime==""){
            selectedTime="Lunch"
        }
        let cell = UITableViewCell()
        let tableAsDictionary = TableData[selectedTime].dictionaryValue
        let key : String = Array(tableAsDictionary.keys)[indexPath.section]
        
        let labelt = TableData[selectedTime][key][indexPath.row]["mealName"].stringValue
        
        cell.textLabel?.text = labelt
        
        return cell;
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(selectedTime==""){
            selectedTime="Lunch"
        }
        let tableAsDictionary = TableData[selectedTime].dictionaryValue
        let key : String = Array(tableAsDictionary.keys)[section]
        return key
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertView();
        alert.title = "Meal Name"
        if(selectedTime==""){
            selectedTime="Lunch"
        }
        let tableAsDictionary = TableData[selectedTime].dictionaryValue
        let key : String = Array(tableAsDictionary.keys)[indexPath.section]
        
        let labelt = TableData[selectedTime][key][indexPath.row]["mealName"].stringValue
        
        alert.message = labelt
        
        alert.addButtonWithTitle("Dismiss")
        alert.show()
        self.tableView.resignFirstResponder()

    }

    @IBOutlet weak var tableView: UITableView!

    func loadMeals() {
        
        dateLabel.text = self.date
        if (today != self.date) {
            today = self.date;
            SwiftSpinner.show("Loading Meals");
        }
        let d1 = ["mealName":"None Entered"]
        let d2 = [d1]
        let d3 = ["Flik":d2]
        let d4 = JSON(d3)
        
        Alamofire.request(.GET,"http://flik.ma1geek.org/getMeals.php", parameters:["date":self.date,"version":2]).responseJSON{response in
            SwiftSpinner.hide();
            if let data = response.2.value {
                var jsoncontent = JSON(data)
                if jsoncontent["Breakfast"] == nil {
                    jsoncontent["Breakfast"] = d4
                }
                if jsoncontent["Lunch"] == nil {
                    jsoncontent["Lunch"] = d4
                }
                if jsoncontent["Dinner"] == nil {
                    jsoncontent["Dinner"] = d4
                }
                self.TableData = jsoncontent
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    return
                })
                //format of dictionary mealtimes:
                //{mealtime:{mealclass:[menuitems],mealcalss2:[menuitems]},mealtime2:{mealclass:[menuitems],mealcalss2:[menuitems]}
                //for example:
                //{Lunch:{Entree:[Hamburgers, Hot Dogs, French Fries], Flik Live: Caesar Wraps},Dinner:{Entree: [Good ol' plain pasta, Yummy carrot sticks],Dessert:[Pink Ice Cream, Dog Biscuits]}}
                //TODO Justin please populate the table using this format
                //mealtimes and categories are SwiftyJSON Objects -- see https://github.com/SwiftyJSON/SwiftyJSON

            }
            else {
                let alert = UIAlertView();
                alert.title = "Try again"
                alert.message = "Please check your network connection to load the latest meals."
                alert.addButtonWithTitle("OK")
                alert.show()
            }
           
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func navbarclicked(sender: AnyObject) {
        AboutScreen.showAboutScreen(self)
    }
    @IBAction func openDatePicker(sender: AnyObject) {
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel") {
            (date) -> Void in
            //self.textField.text = "\(date)"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" //format style. Browse online to get a format that fits your needs.
            let dateString = dateFormatter.stringFromDate(date)
            self.date = dateString
            self.loadMeals()

        }
    }
    override func viewDidAppear(animated: Bool) {
        print("Started Here")
        super.viewDidAppear(animated)
        let date = NSDate() //get the time, in this case the time an object was created.
        //format date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(date)
        self.date = dateString
        if(selectedTime==""){
            selectedTime="Lunch"
        }
        loadMeals()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Started HEREEEEEE")
        let alert = UIAlertView();
        alert.title = "Allergy Warning"
        alert.message = "Before placing your order, please inform your server if a person in your party has a food allergy."
        alert.addButtonWithTitle("OK")
        alert.show()
    }
}

