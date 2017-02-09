extension Character {
    
    var asciiValue: Int? {
        return Int((String(self).unicodeScalars.filter{$0.isASCII}.first?.value)!)
    }
    
}
