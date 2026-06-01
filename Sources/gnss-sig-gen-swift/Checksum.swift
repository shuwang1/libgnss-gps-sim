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

import Foundation

/// Parity bit calculations for GNSS navigation messages according to IS-GPS-200.
struct Checksum {
    /// Counts the number of set bits (1s) in a 32-bit integer.
    /// - Parameter v: Input value.
    /// - Returns: Number of set bits.
    static func countBits(_ v: UInt32) -> UInt32 {
        var c = v
        let S: [UInt32] = [1, 2, 4, 8, 16]
        let B: [UInt32] = [0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF, 0x0000FFFF]
        for i in 0..<5 {
            c = ((c >> S[i]) & B[i]) + (c & B[i])
        }
        return c
    }
    
    /// Bit masks for parity calculation (GPS L1 C/A).
    private static let bmask: [UInt32] = [
        0x3B1F3480, 0x1D8F9A40, 0x2EC7CD00,
        0x1763E680, 0x2BB1F340, 0x0B7A89C0
    ]
    
    /// Calculates the 6 parity bits for a 30-bit GPS navigation word.
    /// - Parameters:
    ///   - sbfmWord: The 24-bit navigation data word (with top 2 bits from previous word).
    ///   - nib: Special handling flag for TOW/HOW words.
    /// - Returns: A 30-bit word including 6 parity bits.
    static func calcChecksumV0(_ sbfmWord: UInt32, nib: Int) -> UInt32 {
        var d = sbfmWord & 0x3FFFFFC0
        let b29 = (sbfmWord >> 31) & 0x1
        let b30 = (sbfmWord >> 30) & 0x1
        
        if nib != 0 {
            if (b30 + countBits(bmask[4] & d)) % 2 != 0 { d ^= (0x1 << 6) }
            if (b29 + countBits(bmask[5] & d)) % 2 != 0 { d ^= (0x1 << 7) }
        }
        
        var wordj = d
        if b30 != 0 { wordj ^= 0x3FFFFFC0 }
        
        wordj |= ((b29 + countBits(bmask[0] & d)) % 2) << 5
        wordj |= ((b30 + countBits(bmask[1] & d)) % 2) << 4
        wordj |= ((b29 + countBits(bmask[2] & d)) % 2) << 3
        wordj |= ((b30 + countBits(bmask[3] & d)) % 2) << 2
        wordj |= ((b30 + countBits(bmask[4] & d)) % 2) << 1
        wordj |= ((b29 + countBits(bmask[5] & d)) % 2)
        
        return wordj & 0x3FFFFFFF
    }
}
