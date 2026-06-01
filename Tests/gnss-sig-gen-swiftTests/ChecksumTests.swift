import Testing
import Foundation
@testable import gnss_sig_gen_swift

/// Unit tests for IS-GPS-200 parity and checksum logic.
struct ChecksumTests {

    /// Verifies the software implementation of population count.
    @Test func testCountBits() async throws {
        #expect(Checksum.countBits(0) == 0)
        #expect(Checksum.countBits(0xFFFFFFFF) == 32)
        #expect(Checksum.countBits(0x10101010) == 4)
        #expect(Checksum.countBits(0xAAAAAAAA) == 16)
    }
    
    /// Verifies GPS L1 C/A parity bit generation for navigation words.
    @Test func testChecksumV0() async throws {
        // Standard Preamble (0x8B) word
        let preamble: UInt32 = 0x8B0000 << 6
        let word = Checksum.calcChecksumV0(preamble, nib: 0)
        #expect((word >> 22) == 0x8B)
        // Parity bits (last 6) should be calculated
        #expect((word & 0x3F) != 0)
    }
}
