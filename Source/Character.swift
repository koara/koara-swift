extension Character {
    
    var intValue: UInt32? {
        return String(self).unicodeScalars.first?.value
    }
    
}
