#if Coder
    import Byte

    func bytes(_ values: UInt8...) -> [Byte] {
        values.map(Byte.init(bitPattern:))
    }
#endif
