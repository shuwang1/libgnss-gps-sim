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

/// Unit tests for satellite link state and navigation data encoding.
struct LinkTests {

    /// Verifies the encoding of ephemeris parameters into raw navigation subframe bits.
    @Test func testEph2SBF() async throws {
        var eph = Ephemeris()
        eph.vflg = true
        eph.toe = GPSTime(week: 2000, sec: 0.0)
        eph.toc = eph.toe
        eph.af[0] = 0.0001
        
        let ionoutc = IonUTC()
        let sbf = Link.eph2sbf(eph: eph, ionoutc: ionoutc)
        
        #expect(sbf.count == 5)
        #expect(sbf[0].count == 10)
        
        // Verify preamble (0x8B) in the first word
        #expect((sbf[0][0] >> 22) == 0x8B)
        
        // Verify subframe ID in the second word
        #expect((sbf[0][1] >> 8) == 1)
    }
}
