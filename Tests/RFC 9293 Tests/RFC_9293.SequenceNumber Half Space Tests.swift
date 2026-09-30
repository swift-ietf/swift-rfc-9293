import Testing

@testable import RFC_9293

@Suite
struct `Sequence number half space` {
    @Test(arguments: [(UInt32(0), UInt32(1) << 31), (UInt32(5), UInt32(5) &+ (1 << 31)), (UInt32.max, UInt32.max &+ (1 << 31))])
    func `two numbers half the space apart are ordered one way only`(_ a: UInt32, _ b: UInt32) {
        let lhs = RFC_9293.SequenceNumber(rawValue: a)
        let rhs = RFC_9293.SequenceNumber(rawValue: b)

        #expect((lhs < rhs) != (rhs < lhs))
        #expect((lhs < rhs) == (a < b))
    }
}

extension `Sequence number half space` {
    @Test
    func `wrap-aware ordering is not transitive across the number space`() {
        let a = RFC_9293.SequenceNumber(rawValue: 0)
        let b = RFC_9293.SequenceNumber(rawValue: 1 << 30)
        let c = RFC_9293.SequenceNumber(rawValue: (1 << 31) + 1)

        #expect(a < b)
        #expect(b < c)
        #expect(c < a)
        #expect(!(a < c))
    }

    @Test
    func `a window narrower than half the space is checked pairwise`() {
        let left = RFC_9293.SequenceNumber(rawValue: UInt32.max - 10)
        let right = left + 20

        #expect(RFC_9293.SequenceNumber(rawValue: 5).isWithin(left: left, right: right))
        #expect(!RFC_9293.SequenceNumber(rawValue: 100).isWithin(left: left, right: right))
    }
}
