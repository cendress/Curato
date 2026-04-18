//
//  CuratoTests.swift
//  CuratoTests
//
//  Created by Christopher Endress on 4/17/26.
//

import Testing
@testable import Curato

struct CuratoTests {
    @Test func priceFormatterHandlesNilAndValues() {
        #expect(PriceFormatter.string(from: nil) == "N/A")
        #expect(PriceFormatter.string(from: 49).contains("$"))
    }

    @Test func filterOptionsInitializeAsExpected() {
        let options = FilterOptions()
        #expect(options.vibeText.isEmpty)
        #expect(options.budgetMin == nil)
        #expect(options.budgetMax == nil)
        #expect(options.selectedCategories.isEmpty)
        #expect(options.location == nil)
    }
}
