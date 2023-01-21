//
//  ContentView.swift
//  WordScramble
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var fileContents = [String]()
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
        
    func startGame() {
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let contents = try? String(contentsOf: fileUrl) {
                fileContents = contents.components(separatedBy: "\n")
                if let word = fileContents.randomElement() {
                    rootWord = word
                    return
                }
            }
        } else {
            fatalError("Could not load start.txt")
        }
    }
    
    func newGame() {
        if let word = fileContents.randomElement() {
            rootWord = word
            usedWords = []
        } else {
            fatalError("Words are not loaded")
        }
    }
    
    func getWord() -> String {
        return fileContents.randomElement()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    func addNewWord(_ word: String) {
        let w = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard w.count > 0 else { return }
    
        guard w.count > 2 else {
            wordError(title: "Word is too short", message: "Try a longer word")
            return
        }
        
        guard isOriginal(word: w) else {
            wordError(title: "Word is already used", message: "Be more original!")
            return
        }
        
        guard isPossible(word: w) else {
            wordError(title: "Word is not possible", message: "You cannot spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: w) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know")
            return
        }
        
        withAnimation {
            usedWords.insert(w, at: 0)
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var totalScore: Int {
        var score = 0
        for word in usedWords {
            score += word.count
        }
        return score
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    
                    if usedWords.count > 0 {
                        Text("Your score is \(totalScore)")
                    }
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                                .foregroundColor(.accentColor)
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord(newWord)
                newWord = ""
            }.toolbar {
                Button("New game") {
                    newGame()
                }
            }
            
        }
        .onAppear(perform: startGame)
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
