import RFC_9293
import Testing

@Suite
struct `IETF.RFC.9293.SequenceNumber Tests` {

    @Test
    func `a sequence number carries the thirty-two-bit value it was built from`() {
        let sequenceNumber = IETF.RFC.`9293`.SequenceNumber(rawValue: 12345)
        #expect(sequenceNumber.rawValue == 12345)
    }

    @Test
    func `advancing a sequence number adds within the number space`() {
        let sequenceNumber = IETF.RFC.`9293`.SequenceNumber(rawValue: 100)
        #expect((sequenceNumber + 50).rawValue == 150)
    }

    @Test
    func `advancing past the end of the number space wraps around`() {
        let sequenceNumber = IETF.RFC.`9293`.SequenceNumber(rawValue: UInt32.max - 10)
        #expect((sequenceNumber + 20).rawValue == 9)
    }

    @Test
    func `comparison orders two sequence numbers in the same half of the space`() {
        let earlier = IETF.RFC.`9293`.SequenceNumber(rawValue: 100)
        let later = IETF.RFC.`9293`.SequenceNumber(rawValue: 200)
        #expect(earlier < later)
        #expect(!(later < earlier))
    }

    @Test
    func `comparison follows the wraparound rather than the raw value`() {
        let beforeWrap = IETF.RFC.`9293`.SequenceNumber(rawValue: UInt32.max - 100)
        let afterWrap = IETF.RFC.`9293`.SequenceNumber(rawValue: 100)
        #expect(beforeWrap < afterWrap)
    }

    @Test
    func `a sequence number reports whether it lies in a window`() {
        let left = IETF.RFC.`9293`.SequenceNumber(rawValue: 100)
        let right = IETF.RFC.`9293`.SequenceNumber(rawValue: 200)

        #expect(IETF.RFC.`9293`.SequenceNumber(rawValue: 150).isWithin(left: left, right: right))
        #expect(!IETF.RFC.`9293`.SequenceNumber(rawValue: 50).isWithin(left: left, right: right))
        #expect(IETF.RFC.`9293`.SequenceNumber(rawValue: 150).isBetween(left: left, right: right))
        #expect(!left.isBetween(left: left, right: right))
    }

    @Test
    func `subtracting two sequence numbers measures the distance between them`() {
        let earlier = IETF.RFC.`9293`.SequenceNumber(rawValue: 1000)
        let later = IETF.RFC.`9293`.SequenceNumber(rawValue: 1500)
        #expect(later - earlier == 500)
    }
}
