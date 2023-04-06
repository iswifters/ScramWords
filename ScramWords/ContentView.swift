//
//  ContentView.swift
//  ScramWords
//
//  Created by MAC on 20/03/2023.
//

import SwiftUI

struct ContentView: View {
    //Let’s start with the basics: we need an array of words they have already used, a root word for them to spell other words from, and a string we can bind to a text field. So, add these three properties to ContentView now:
    @State private var usedWords = [String] ()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var totalScore = 0
    @State private var level = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingError = false
    @State private var showingScore = false
    let blueish = Color(red: 0.643, green: 0.769, blue: 0.878, opacity: 1.0)
    let myColor = Color(red: 0.16, green: 0.427, blue: 0.663, opacity: 1.0)

    
    var body: some View {
            NavigationView {
                ZStack {
                    blueish.ignoresSafeArea()
                    VStack {
                        Text("SCRAM WORDS")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(myColor)
                            .padding(.top, 50)
                            .padding(.bottom, 8)
                        
                        Spacer()
                        
                        
                        List {
                            Section(header: Text("Enter your word").font(.headline)) {
                                TextField("", text:$newWord)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            Section(header: Text("Used Words").font(.headline)) {
                                ForEach(usedWords, id: \.self) { word in
                                    HStack{
                                        Text(word)
                                            .font(.title3)
                                        Spacer()
                                        Image(systemName: "\(word.count).circle.fill")
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            if showingScore {
                                Section(header: Text("Game total score").font(.headline)) {
                                    Text(String(totalScore))
                                        .font(.title2)
                                }
                            }
                            
                        }
                    
                            .foregroundColor(myColor)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.white, lineWidth: 6)
                            )
                            
                            .padding(.horizontal, 32.0)
                            .navigationTitle(rootWord)
                            .navigationBarItems(trailing:
                                                    Button(action: {
                                level = 1
                                startGame()
                            }) {
                                Text("Reset Word")
                            }
                            )
                            .onSubmit {addNewWord()}
                            .onAppear(perform: startGame)
                            .alert(isPresented: $showingError) {
                                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                            }
                            
                            Spacer()
                            Spacer()
                            
                    }.background(Color.clear)
                    
                }
          }
      }
   
       
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.trimmingCharacters(in: .whitespaces).lowercased()
        
        // exit if the remaining string is empty
        guard (answer.count >  2 ) else {
            wordError(title: "Word is less than 3 letters", message: "Give it another shot!")
            return
        }
        //'guard' == 'make sure that'. 'return' is used to exit the current function or closure and return control to the caller with a Void return value (i.e., nothing is returned).
        guard !(answer == rootWord) else {
            wordError(title: "Can't give back the same word", message: "Be Creative!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word isn't english", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation{usedWords.insert(answer, at: 0)}
        
        calculateScore(with: answer.count)
        
        newWord = ""
        
        level += 1
    
    }
    
    func startGame() {
        
        //1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource:"start", withExtension: "txt"){
            
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {//The value will either be an optional value or nil and the thrown error is completely ignored.
                
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
        //if we can’t locate start.txt in our app bundle, or if we can locate it but we can’t load it? In that case we have a serious problem, because our app is really broken.Regardless of what caused it, this is a situation that never ought to happen, and Swift gives us a function called fatalError() that lets us respond to unresolvable problems really clearly.
    }
    
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    
    func isPossible(word: String) -> Bool {
        var tempWord:String = rootWord
        
        for letter in word {//This line starts a loop that iterates over each character in the word argument. The loop assigns each character to a variable called letter.
            if let position = tempWord.firstIndex(of: letter) {//This line checks if the tempWord string contains the current letter. If it does, it uses the firstIndex(of:) method to find the index of the first occurrence of the letter in tempWord. If the method returns a non-nil value, the index is assigned to a constant called position, and the following block of code is executed. If the method returns nil, the block of code following the else keyword is executed instead.
                tempWord.remove(at: position)//If pos is not nil, this line removes the character at index position from tempWord. The purpose of this line is to ensure that each character in word can be found in tempWord and that tempWord contains no duplicate characters.
            }
            else{
                return false//If the firstIndex(of:) method returns nil, this block of code is executed. It simply returns false, which indicates that it's not possible to create word by removing characters from tempWord. If word contains a character that is not found in tempWord, this function will return false.
            }
        }
        return true//If the loop completes without returning false, this line is executed, and the function returns true. This indicates that it is possible to create word by removing characters from tempWord.
    }
    
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range =  NSRange(location:0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    
    func wordError(title: String, message:String) {
         alertTitle = title
         alertMessage = message
         showingError = true
    }
    
    
    func calculateScore(with count: Int) {
        totalScore += count * level
        showingScore = true
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




/**
 —return is a keyword in Swift that is used to exit a function or closure and return a value. In SwiftUI, return is used to return a view to be displayed on the screen. When return is used inside a function or closure that returns a view, it causes the function or closure to exit early and return the specified view.
 —break, on the other hand, is used to exit a loop or switch statement early. When break is used inside a loop or switch statement, it causes the loop or switch statement to exit and continue executing the code that follows the loop or switch statement.
 —So, in short, return is used to return a value or exit a function, while break is used to exit a loop or switch statement. They are not equivalent in Swift or SwiftUI.
        
 */








//https://www.hackingwithswift.com/100/swiftui/30
