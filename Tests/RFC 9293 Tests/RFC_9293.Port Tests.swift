import RFC_9293
import Testing

@Suite
struct `RFC_9293.Port Tests` {

    @Test
    func `a port carries the sixteen-bit number it was built from`() {
        let port = RFC_9293.Port(8080)
        #expect(port.rawValue == 8080)
    }

    @Test
    func `the well-known service ports are named`() {
        #expect(RFC_9293.Port.http.rawValue == 80)
        #expect(RFC_9293.Port.https.rawValue == 443)
        #expect(RFC_9293.Port.ssh.rawValue == 22)
        #expect(RFC_9293.Port.ftp.rawValue == 21)
        #expect(RFC_9293.Port.smtp.rawValue == 25)
    }

    @Test
    func `a port falls in exactly one of the three registry ranges`() {
        let wellKnown = RFC_9293.Port(80)
        let registered = RFC_9293.Port(8080)
        let dynamic = RFC_9293.Port(50000)

        #expect(wellKnown.isWellKnown)
        #expect(!wellKnown.isRegistered)
        #expect(!wellKnown.isDynamic)

        #expect(!registered.isWellKnown)
        #expect(registered.isRegistered)
        #expect(!registered.isDynamic)

        #expect(!dynamic.isWellKnown)
        #expect(!dynamic.isRegistered)
        #expect(dynamic.isDynamic)
    }

    @Test
    func `a port reads back as its decimal number`() {
        let port: RFC_9293.Port = 443
        #expect(port.description == "443")
    }
}
