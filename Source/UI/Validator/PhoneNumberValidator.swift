import Foundation
import PhoneNumberKit
import Checkout

class PhoneNumberValidator: Validator {

    static let shared = PhoneNumberValidator()

    var countryCode: String = PhoneNumberKit.defaultRegionCode()
    private let validator = PhoneValidator()
    private let phoneKit = PhoneNumberKit()
    private let validCharacterSet: CharacterSet = {
        var validInputs = "-+() "
        (0...9).forEach { validInputs.append("\($0)") }
        return CharacterSet(charactersIn: validInputs)
    }()

    init() {}

    func shouldAccept(text: String) -> Bool {
        CharacterSet(charactersIn: text).isSubset(of: validCharacterSet) &&
            text.count < Checkout.Constants.Phone.phoneMaxLength
    }

    func isValid(text: String) -> Bool {
        do {
            let formattedNumber = try phoneKit.parse(text,
                                                     withRegion: countryCode,
                                                     ignoreType: true)
            let phone = Phone(number: String(formattedNumber.numberString),
                              country: Country(iso3166Alpha2: formattedNumber.regionID ?? ""))
            return validator.validate(phone) == .success
        } catch {
            return false
        }
    }

    func formatForDisplay(text: String) -> String {
        do {
            let formattedNumber = try phoneKit.parse(text,
                                                     withRegion: countryCode)
            return phoneKit.format(formattedNumber, toType: .international)
        } catch {
            return text
        }
    }

}
