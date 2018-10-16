//
//  InterfaceController.swift
//  BinarI WatchKit Extension
//
//  Created by Eskil Sviggum on 13/10/2018.
//  Copyright © 2018 SIGABRT. All rights reserved.
//

import WatchKit
import Foundation


final class InterfaceController: WKInterfaceController {
    
    @IBOutlet var VerLabel: WKInterfaceLabel!
    
    @IBOutlet var ActivityRing: WKInterfaceActivityRing!
    
    //--TimeSwitchar
    @IBOutlet var Time16Bilde: WKInterfaceImage!
    
    @IBOutlet var Time8Bilde: WKInterfaceImage!
    
    @IBOutlet var Time4Bilde: WKInterfaceImage!
    
    @IBOutlet var Time2Bilde: WKInterfaceImage!
    
    @IBOutlet var Time1Bilde: WKInterfaceImage!
    
    //MinuttSwitchar
    
    @IBOutlet var Minutt32Bilde: WKInterfaceImage!
    
    @IBOutlet var Minutt16Bilde: WKInterfaceImage!
    
    @IBOutlet var Minutt8Bilde: WKInterfaceImage!
    
    @IBOutlet var Minutt4Bilde: WKInterfaceImage!
    
    @IBOutlet var Minutt2Bilde: WKInterfaceImage!
    
    @IBOutlet var Minutt1Bilde: WKInterfaceImage!
    
    
    @IBOutlet var DatoLabel: WKInterfaceDate!
    @IBOutlet var SetbarDatoLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        
        //--Get todays date and set it to the label called "SetbarDatoLabel"--//
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yy-MM-dd"
        
        let datoFormater = DateFormatter()
        datoFormater.dateFormat = "EEEE d. MMMM"
        
        let dato = Date()
        let cal = Calendar(identifier: .gregorian)
        
        let year = cal.component(.year, from: dato)
        let monde = cal.component(.month, from: dato)
        let dag = cal.component(.day, from: dato)
        
        if let date = dateFormatterGet.date(from: "\(year)-\(monde)-\(dag)") {
            print(datoFormater.string(from: date))
            let datoStreng = datoFormater.string(from: date)
            SetbarDatoLabel.setText("\(datoStreng)".uppercased())
        } else {
            print("There was an error decoding the string")
        }
        
        //---------//
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //--Run a function every secound--//
        DennaBlirKjoyrdKvartSekund()
    }
    
    var timer = Timer()
    
    func DennaBlirKjoyrdKvartSekund(){
        //--Run a function every secound--//
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.kvartSekund), userInfo: nil, repeats: true)
    }
    
    @objc func kvartSekund(){
        
        //--Get a datestamp
        let dato = Date()
        
        //--Configure a NSCalendar
        let cal = Calendar(identifier: .gregorian)
        
        //--Figure out what hour,minute and secound we are at in the decimal system
        let time = cal.component(.hour, from: dato)
        let minutt = cal.component(.minute, from: dato)
        let sekund = cal.component(.second, from: dato)
        
        //--Convert the hour,secound and minute to the binary system with the function Totalifiser().
        let timeTotal = Totalifiser(time)
        //--Because the hour does not have the 32-place, we can remove that place from the binary string created for displaying hour
        let KonTimeTotal = timeTotal[1...(timeTotal.count - 1)]
        
        let sekundTotal = Totalifiser(sekund)
        let minuttTotal = Totalifiser(minutt)
        
        //--Update the image for i in the "BildeViews" array(which contains the images for the minutes). Send the status(an integer of the character at i, typically 1 or 0) and the WKInterfaceImage at i (from the array) to the function OppdaterBilde(bilde: WKInterfaceImage, status: Int).
        for i in 0...minuttTotal.count - 1 {
            let BildeViews = [Minutt32Bilde,Minutt16Bilde,Minutt8Bilde,Minutt4Bilde,Minutt2Bilde,Minutt1Bilde]
            if minuttTotal.count >= i {
            let status = minuttTotal[i]
            OppdaterBilde(bilde: BildeViews[i]!, status: Int("\(status)")!)
            }
        }
        
        //--Same thing here basically, but for the hours.
        for i in 0...KonTimeTotal.count - 1 {
            let BildeViews = [Time16Bilde,Time8Bilde,Time4Bilde,Time2Bilde,Time1Bilde]
            if BildeViews.count >= i {
            let status = KonTimeTotal[i]
            OppdaterBilde(bilde: BildeViews[i]!, status: Int("\(status)")!)
            }
        }
        
        //Just nicely set the created secound binary to its own little label up in the corner there.
        VerLabel.setText(sekundTotal)
        
        
        
    }
    
    func OppdaterBilde(bilde: WKInterfaceImage, status: Int) {
            //--If the status is 0, set the image of the WKInterfaceImage to off, else if it is 1, set the image to On. Otherwise (for some bizarre reason if that ever in some case happens) just set the image to off.
        switch status {
        case 0:
            bilde.setImageNamed("BinerOff")
            //bilde.setImage(#imageLiteral(resourceName: "BinerOff"))
        case 1:
            bilde.setImageNamed("BinerOn")
            //bilde.setImage(#imageLiteral(resourceName: "BinerOn"))
        default:
            bilde.setImageNamed("BinerOff")
            //bilde.setImage(#imageLiteral(resourceName: "BinerOff"))
        }
            
        
    }
    
    func Totalifiser(_ desimaltal: Int) -> String {
        //--I FREAKIN LOVE THIS METHOD!!!--//
        
        //--Make a nice little string called "byte" with nothing in it.
        var byte = ""
        var desi = desimaltal
        
        //--let the set of factors to be the multiples of 2. [2^5,2^4,2^3,2^2,2^1,2^0]
        let faktorar = [32,16,8,4,2,1]
        
        //--Go through every number in the array, if the number is bigger than the desimal number, then append a 0 to the nice little string called "byte" and go to the next number.
        //--If the number is less than the desimal number, then perform some modulo and set the decimal number to the result(of the modulo "%"), and append a 1 to the nice little string called "byte".
        for faktor in faktorar {
            if desi % faktor != desi {
                //Faktoren tilfredsstillar!
                byte.append("1")
                
            }else {
                byte.append("0")
            }
            desi = desi % faktor
        }
        print(byte)
        return byte
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}


extension String {
    //An extension for Strings to substring index of characters like you would substring any array.
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
