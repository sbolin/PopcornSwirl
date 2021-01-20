//
//  Validation.swift
//  PopcornSwirl
//
//  Created by Scott Bolin on 1/2/21.
//

import Foundation

/// Validate text input, used in DetailViewController notes.
class Validation {
    func validatedText(newText: String, oldText: String) -> Bool {
        let trimmedNewText = newText.trimmingCharacters(in: .whitespaces)
        let trimmedOldText = oldText.trimmingCharacters(in: .whitespaces)
        let isValidatedNewText = trimmedNewText.count > 0
//        let isValidatedOldText = trimmedOldText.count > 0 // since default note text is "", this always fails.
        let isValidatedDifferent = trimmedNewText != trimmedOldText
        
        let isValid = isValidatedNewText && isValidatedDifferent // && isValidatedOldText
        return isValid
    }
}
