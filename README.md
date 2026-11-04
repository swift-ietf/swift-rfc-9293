# swift-rfc-9293

Use this package when you read or write TCP segments, or keep the bookkeeping of a TCP connection, as defined by RFC 9293. Start from `RFC_9293.Segment` for a segment on the wire, `RFC_9293.SequenceNumber` for sequence arithmetic, and `RFC_9293.TCB` for a connection's state and sequence variables. It doesn't run the state machine, retransmit or compute checksums. For UDP, use swift-rfc-768; IPv4 addresses come from swift-rfc-791.

## Laws

- Sequence numbers add and subtract modulo 2^32. One number is less than another when it is less than half the space behind it. Two numbers exactly half the space apart are ordered by raw value, so the order is never ambiguous, but it is not transitive across the whole space. Compare numbers only within a window narrower than half the space, and don't sort them.
- `RFC_9293.SequenceNumber.isWithin(left:right:)` includes both ends, and `RFC_9293.SequenceNumber.isBetween(left:right:)` excludes both.
- SYN and FIN each take one sequence number, so a segment's sequence length is its data plus one for each of those flags.
- The data offset counts the header in four-byte words, from 5 (20 bytes, no options) to 15 (60 bytes). It is written in the high four bits of its byte. The low four bits are written as zero and ignored when read.
- Reading a header takes exactly the option bytes its data offset announces and keeps them as raw bytes. Reading a segment takes everything after the header as data. Each failed read puts the input back where it started.
- Reading one option checks the declared length of the fixed-size kinds: 4 for maximum segment size, 3 for window scale, 2 for SACK permitted and 10 for timestamps. A SACK option must be 2 plus a multiple of 8. An unknown kind keeps its kind and payload. End of option list and no-operation are one byte with no length.
- A connection may send data only in ESTABLISHED and CLOSE-WAIT, and receive data only in ESTABLISHED, FIN-WAIT-1 and FIN-WAIT-2.
- Starting send variables from an initial send sequence number sets the unacknowledged number to it and the next number one past it, with a window of zero. Starting receive variables from an initial receive sequence number sets the next expected number one past it.
- With `RFC 9293 Foundation Integration`, ports, sequence numbers, data offsets and flags encode as their numbers, and a connection state as its RFC name, such as `SYN-SENT`. Decoding checks the data offset range and refuses an unknown state name.
