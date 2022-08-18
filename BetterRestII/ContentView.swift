//
//  ContentView.swift
//  BetterRestII
//
//  Created by Caio Castro on 18/08/2022.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWaketime // Value deafault to Wake Time
    @State private var sleepAmount = 8.0 // Amount of hours that the person want to sleep
    @State private var coffeeAmount = 1 // Quantity for cups of coffee
    
    @State private var currentCoffee = [1,2,3,4,5,6,7,8,9,10] // Array for the quantity for cups of coffee
    
    @State private var alertTitle = "" // Property for the alert title telling the system that it's gonna receive an string value
    @State private var alertMessage = "" // Property for the alert message telling the system that it's gonna receive an string value
    @State private var showAlert = false // Show alert with false (Bool) as default
    
    static var defaultWaketime: Date { // Propety to choose 7:00AM as default value to wake time
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
            NavigationView {
                    Form{
                        Section{ // Section with a DatePicker to choose when you want to wake up
                            DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden() // Modifier to hidde the label "Please enter a date"
                        } header: {
                            Text("When do you want to wake up?") // Title of this section
                                .bold()
                        }
                        Section{ // Section to choose how long you want sleep
                            Stepper("\(sleepAmount.formatted())hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        } header: {
                            Text("Desire amount of sleep") // Title of this section
                                .bold()
                        }
                        Section{ // Section to choose how many cups of coffee you drink per day
                            Picker("Tip how many cups", selection: $coffeeAmount) {
                                ForEach(currentCoffee, id: \.self) {
                                    Text($0, format: .number)
                                }
                            }.pickerStyle(.segmented) // Modifier to choose the style of this Picker
                        } header: {
                            Text("Daily coffee intake") // Title of this section
                                .bold()
                        }
                        }
                    .background(Color("BlueSleep")) // Color of the background inserted on this form
                    .onAppear { // Trick made for this form accept this background(Color)
                        UITableView.appearance().backgroundColor = .clear
                    }
                    .onDisappear{
                        UITableView.appearance().backgroundColor = .systemGroupedBackground
                    }
                    .navigationTitle("BetterRest") // Title of this navigation
                    .toolbar{
                        Button("Calculate", action: calculeteBedtime) // Button "Calculate" of this navigation
                            .buttonStyle(.bordered)
                    }
            }
            .alert(alertTitle, isPresented: $showAlert) { // Alert to show the result
                Button("Ok") {}
            } message: {
                Text(alertMessage)
            }
    }
    func calculeteBedtime() { // Func to calculate the time
        do {
            let config = MLModelConfiguration() // Getting the configuration of our ML Model
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp) // Configuring the calculator to calculate the time
            let hour = (components.hour ?? 0) * 60 * 60 // Hour x 60 Minutes x 60 Seconds
            let minute = (components.minute ?? 0) * 60 // Minute x 60 Seconds
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount)) 
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..." // Message to the alertTitle
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened) // Message telling the user the result
        } catch {
            alertTitle = "Error" // Title for the alertTitle if we get some error during the process of calculation
            alertMessage = "Sorry, there was a problem calculating your bedtime." // Message for the alertMessage if we get some error during the process of calculation
        }
        showAlert = true // Func always returning true to show the alert when the function be activated
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
