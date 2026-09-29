import RFC_9293
import Testing

@Suite
struct `RFC_9293 Constants Tests` {

    @Test
    func `tcp is protocol number six`() {
        #expect(RFC_9293.protocolNumber == 6)
    }

    @Test
    func `a header is between twenty and sixty octets`() {
        #expect(RFC_9293.minimumHeaderSize == 20)
        #expect(RFC_9293.maximumHeaderSize == 60)
    }

    @Test
    func `the default maximum segment size differs between the two address families`() {
        #expect(RFC_9293.defaultMSSIPv4 == 536)
        #expect(RFC_9293.defaultMSSIPv6 == 1220)
    }

    @Test
    func `time-wait lasts two maximum segment lifetimes`() {
        #expect(RFC_9293.mslSeconds == 120)
        #expect(RFC_9293.timeWaitDurationSeconds == 240)
    }
}
