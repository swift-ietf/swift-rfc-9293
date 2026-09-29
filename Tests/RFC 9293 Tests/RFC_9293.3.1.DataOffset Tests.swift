import RFC_9293
import Testing

@Suite
struct `RFC_9293.3.1.DataOffset Tests` {

    @Test
    func `the smallest data offset describes a header with no options`() {
        let offset = RFC_9293.`3`.`1`.DataOffset.minimum
        #expect(offset.rawValue == 5)
        #expect(offset.headerLength == 20)
        #expect(offset.optionsLength == 0)
    }

    @Test
    func `the largest data offset describes forty octets of options`() {
        let offset = RFC_9293.`3`.`1`.DataOffset.maximum
        #expect(offset.rawValue == 15)
        #expect(offset.headerLength == 60)
        #expect(offset.optionsLength == 40)
    }

    @Test
    func `a data offset measures the header in four-octet words`() throws {
        let offset = try RFC_9293.`3`.`1`.DataOffset(rawValue: 8)
        #expect(offset.headerLength == 32)
        #expect(offset.optionsLength == 12)
    }

    @Test
    func `a data offset below five is rejected`() {
        #expect(throws: RFC_9293.`3`.`1`.DataOffset.Error.valueTooSmall) {
            try RFC_9293.`3`.`1`.DataOffset(rawValue: 4)
        }
    }

    @Test
    func `a data offset above fifteen is rejected`() {
        #expect(throws: RFC_9293.`3`.`1`.DataOffset.Error.valueTooLarge) {
            try RFC_9293.`3`.`1`.DataOffset(rawValue: 16)
        }
    }

    @Test
    func `a header length becomes the data offset that measures it`() throws {
        let offset = try RFC_9293.`3`.`1`.DataOffset.fromHeaderLength(28)
        #expect(offset.rawValue == 7)
    }

    @Test
    func `a header length that is not a whole number of words is rejected`() {
        #expect(throws: RFC_9293.`3`.`1`.DataOffset.Error.notAligned) {
            try RFC_9293.`3`.`1`.DataOffset.fromHeaderLength(30)
        }
    }
}
