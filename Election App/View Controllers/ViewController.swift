//
//  ViewController.swift
//  Election App
//
//  Created by Administrator on 26/06/2018.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GoogleMaps

struct PollingData {
    var StNo : Int
    var Candidate : String
    var Votes : Int
    var PartyName : String
    var Coordinates : [String : Double]
}

class ViewController: UIViewController {

    var Ref : DatabaseReference?
    var AssembliesData = [[PollingData]]()
    let locationManager = CLLocationManager()
    let marker = GMSMarker()
    let markerImage = UIImage(named: "mapMarker")!.withRenderingMode(.alwaysTemplate)
    //let markerView = UIImageView(image: markerImage)
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Polling Stations"
        Ref = Database.database().reference()
        ReadDatabase()
        //ReadFile()
    }
    
    func ReadDatabase(){
        let Assemblies = ["National Assembly", "Provincial Assembly - Balouchistan", "Provincial Assembly - KPK", "Provincial Assembly - Punjab", "Provincial Assembly - Sindh"]
        
        for i in 0..<Assemblies.count {
            var TempData = [PollingData]()
            Ref?.child(Assemblies[i]).observe(.value, with: {(snapshot) in
                if snapshot.childrenCount > 0 {
                    for St in snapshot.children.allObjects as! [DataSnapshot] {
                        let Obj = St.value as? [String : AnyObject]
                        let StNo = Obj?["StNo"] as! Int
                        let Candidate = Obj?["Candidate"] as! String
                        let Votes = Obj?["Votes"] as! Int
                        let PartyName = Obj?["PartyName"] as! String
                        let Cr = Obj?["Coordinate"] as! String
                        let Coordinates = Cr.components(separatedBy: ",")
                        let Cordinates2D = ["Latitude" : Double(Coordinates[0])!, "Longitude" : Double(Coordinates[1])!]
                        let myObj = PollingData(StNo: StNo, Candidate: Candidate, Votes: Votes, PartyName: PartyName, Coordinates: Cordinates2D)
                        
                        TempData.append(myObj)
                    }
                }
            })
            AssembliesData.append(TempData)
        }
    }
    
    func ReadFile(){
        let NA_File = Bundle.main.path(forResource: "PS", ofType: "txt")
        let NA_Address_File = Bundle.main.path(forResource: "NA - Addresses", ofType: "txt")
        
        do{
            let Data1 = try String(contentsOfFile: NA_File!, encoding: String.Encoding.utf8)
            let Data2 = try String(contentsOfFile: NA_Address_File!, encoding: String.Encoding.utf8)
            let RawData1 = Data1.components(separatedBy: "\r\n")
            let RawData2 = Data2.components(separatedBy: "\r\n")
            
            AddData(Data1: RawData1, Data2: RawData2)
        }
        catch let error as NSError {
            print(error)
        }
    }

    func AddData(Data1 : [String], Data2 : [String]) {
        var i : Int = 0
        var j : Int = 0
        
        while i < Data1.count - 1 {
            let key = Ref?.child(String(j + 1)).key
            let Data = ["Polling Station" : Data1[i],
                        "Candidate" : Data1[i + 1],
                        "Party Name" : Data1[i + 2],
                        "Votes" : Data1[i + 3],
                        "Coordinates" : Data2[j]]
            
            Ref?.child(key!).setValue(Data)
            print(i)
            i += 4
            j += 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
