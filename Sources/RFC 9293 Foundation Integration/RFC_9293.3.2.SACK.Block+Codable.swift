public import RFC_9293

extension RFC_9293.`3`.`2`.SACK.Block: Encodable, Decodable {

    public enum CodingKeys: String, CodingKey {
        case leftEdge
        case rightEdge
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            leftEdge: RFC_9293.SequenceNumber(
                rawValue: try container.decode(UInt32.self, forKey: .leftEdge)
            ),
            rightEdge: RFC_9293.SequenceNumber(
                rawValue: try container.decode(UInt32.self, forKey: .rightEdge)
            )
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(leftEdge.rawValue, forKey: .leftEdge)
        try container.encode(rightEdge.rawValue, forKey: .rightEdge)
    }
}
