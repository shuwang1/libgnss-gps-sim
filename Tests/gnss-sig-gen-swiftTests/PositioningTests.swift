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

/// Unit tests for satellite orbit and clock bias calculations.
struct PositioningTests {

    /// Verifies satellite ECEF position calculation from a test ephemeris.
    @Test func testSatPosCalculation() async throws {
        // Create a dummy ephemeris
        var eph = Ephemeris()
        eph.vflg = true
        eph.sqrtA = 5153.5
        eph.ecc = 0.005
        eph.M0 = 0.0
        eph.OMG0 = 0.0
        eph.inc0 = 0.95 // radians
        eph.aop = 0.0
        eph.OMGd = 0.0
        eph.idot = 0.0
        eph.deltan = 0.0
        eph.toe = GPSTime(week: 2000, sec: 0.0)
        eph.toc = eph.toe
        eph.updateDerived()
        
        let t = GPSTime(week: 2000, sec: 0.0)
        let result = Positioning.calculateSatPos(eph: eph, g: t)
        
        // Verify geometric consistency
        let A = eph.sqrtA * eph.sqrtA
        #expect(abs(length(result.pos) - A * (1.0 - eph.ecc)) < 1.0)
    }
}
