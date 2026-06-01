/******************************************************************************
 * Copyright (c) 2019-2026 Shu Wang <shuwang1@outlook.com>. All rights reserved.
 *
 * The Software is licensed, not sold. You may use, download, and modify this 
 * Software strictly for Personal, Non-Commercial, or Educational purposes. 
 * Any commercial use, including but not limited to selling the Software, 
 * using it to provide a commercial service, or incorporating it into a 
 * for-profit product, is strictly prohibited without an explicit commercial 
 * license from the Licensor.
 *
 * All title, copyright, and other intellectual property rights in and to the 
 * Software are and shall remain the sole and exclusive property of the Licensor. 
 * All rights not expressly granted herein are reserved.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED. THE LICENSOR SHALL IN NO EVENT BE LIABLE FOR ANY CLAIMS, DAMAGES, 
 * OR OTHER LIABILITY ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * In no event shall the author or copyright holders be liable for any claim, 
 * damages, or other liability, whether in an action of contract, tort or 
 * otherwise, arising from, out of, or in connection with the software or the 
 * use or other dealings in the software.
 ******************************************************************************/

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
