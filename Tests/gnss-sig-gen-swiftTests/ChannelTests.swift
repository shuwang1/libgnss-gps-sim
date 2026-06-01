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

/// Unit tests for signal propagation channel modeling.
struct ChannelTests {

    /// Verifies range estimation including corrections for signal flight time and Earth rotation.
    @Test func testRangeEstimation() async throws {
        let ionoutc = IonUTC() 
        let g = GPSTime(week: 2000, sec: 0.0)
        let xyz = Vector3(Constants.WGS84_RADIUS, 0, 0) // Receiver at equator
        
        let satPos = Vector3(Constants.WGS84_RADIUS + 20000000.0, 0, 0) // Sat directly above
        let satVel = Vector3(0, 3000.0, 0)
        let clk = (bias: 0.0, drift: 0.0)
        
        let rho = Channel.estimateRange(ionoutc: ionoutc, g: g, xyz: xyz, satPos: satPos, satVel: satVel, clk: clk)
        
        #expect(abs(rho.d - 20000000.0) < 100.0) 
        #expect(abs(rho.azel.el - 90.0 * Constants.D2R) < 1.0 * Constants.D2R)
    }
    
    /// Verifies ionospheric delay estimation using the Klobuchar model.
    @Test func testIonoCorrection() async throws {
        var ionoutc = IonUTC()
        ionoutc.vflg = false // Triggers default 5ns delay
        ionoutc.enable = true
        
        let g = GPSTime(week: 2000, sec: 0.0)
        let llh = Vector3(0, 0, 0)
        let azel = (az: 0.0, el: 90.0 * Constants.D2R)
        
        let corr = Channel.estimateIonosphericCorrection(ionoutc: ionoutc, g: g, llh: llh, azel: azel)
        // F = 1.0 for el = 90
        #expect(abs(corr - 5.0e-9 * Constants.SPEED_OF_LIGHT) < 1e-3)
    }
}
