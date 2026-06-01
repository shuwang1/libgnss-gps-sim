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

/// Unit tests for GPS time and date conversions.
struct TimeTests {

    /// Verifies subtraction logic for GPSTime, including week rollovers.
    @Test func testGPSTimeArithmetic() async throws {
        let t1 = GPSTime(week: 2000, sec: 100.0)
        let t2 = GPSTime(week: 2000, sec: 50.0)
        #expect(t1 - t2 == 50.0)
        
        let t3 = GPSTime(week: 2001, sec: 0.0)
        #expect(t3 - t1 == Constants.SECONDS_IN_WEEK - 100.0)
    }
    
    /// Verifies addition of seconds to GPSTime with week overflow handling.
    @Test func testGPSTimeAdding() async throws {
        let t1 = GPSTime(week: 2000, sec: Constants.SECONDS_IN_WEEK - 10.0)
        let t2 = t1.adding(seconds: 20.0)
        #expect(t2.week == 2001)
        #expect(t2.sec == 10.0)
        
        let t3 = GPSTime(week: 2000, sec: 10.0)
        let t4 = t3.adding(seconds: -20.0)
        #expect(t4.week == 1999)
        #expect(t4.sec == Constants.SECONDS_IN_WEEK - 10.0)
    }
    
    /// Verifies conversion between Gregorian dates and GPS time formats.
    @Test func testDateTimeConversion() async throws {
        // GPS Epoch: 1980-01-06 00:00:00
        let dtEpoch = DateTime(y: 1980, m: 1, d: 6, hh: 0, mm: 0, sec: 0)
        let gpsEpoch = dtEpoch.toGPSTime()
        #expect(gpsEpoch.week == 0)
        #expect(gpsEpoch.sec == 0)
        
        let dtBack = DateTime(gpsTime: gpsEpoch)
        #expect(dtBack.y == 1980)
        #expect(dtBack.m == 1)
        #expect(dtBack.d == 6)
        
        // Random date check
        let dt = DateTime(y: 2023, m: 5, d: 15, hh: 12, mm: 30, sec: 45.5)
        let gps = dt.toGPSTime()
        let dtBack2 = DateTime(gpsTime: gps)
        #expect(dtBack2.y == 2023)
        #expect(dtBack2.m == 5)
        #expect(dtBack2.d == 15)
        #expect(dtBack2.hh == 12)
        #expect(dtBack2.mm == 30)
        #expect(abs(dtBack2.sec - 45.5) < 1e-3)
    }
}
