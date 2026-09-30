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
