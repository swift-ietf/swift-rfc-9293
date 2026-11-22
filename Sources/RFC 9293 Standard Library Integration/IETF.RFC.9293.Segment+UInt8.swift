import Byte
public import RFC_9293

extension IETF.RFC.`9293`.Segment {

    @_disfavoredOverload
    public init(header: IETF.RFC.`9293`.`3`.`1`.Header, data: [UInt8]) {
        self.init(header: header, data: [Byte](data.lazy.map(Byte.init(bitPattern:))))
    }
}
