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

/// Unit tests for mathematical utilities and coordinate transformations.
struct MathTests {

    /// Verifies ECEF to LLH conversion at specific reference points.
    @Test func testXYZ2LLH() async throws {
        // Point on the equator at Greenwich meridian
        let origin = Vector3(Constants.WGS84_RADIUS, 0, 0)
        let llh = MathUtils.xyz2llh(origin)
        
        #expect(abs(llh.x) < 1e-9) // Lat 0
        #expect(abs(llh.y) < 1e-9) // Lon 0
        #expect(abs(llh.z) < 1e-3) // H 0
        
        // North Pole calculation
        let n_pole = Constants.WGS84_RADIUS / sqrt(1.0 - pow(Constants.WGS84_ECCENTRICITY, 2))
        let z_pole = n_pole * (1.0 - pow(Constants.WGS84_ECCENTRICITY, 2))
        let northPole = Vector3(0, 0, z_pole)
        let llhPole = MathUtils.xyz2llh(northPole)
        
        #expect(abs(llhPole.x - 90.0 * Constants.D2R) < 1e-9)
        #expect(abs(llhPole.z) < 1e-3)
    }
    
    /// Verifies bidirectional consistency between LLH and ECEF conversions.
    @Test func testLLH2XYZ() async throws {
        let llh = Vector3(52.2 * Constants.D2R, 0.1 * Constants.D2R, 100.0)
        let xyz = MathUtils.llh2xyz(llh)
        let llhBack = MathUtils.xyz2llh(xyz)
        
        #expect(abs(llh.x - llhBack.x) < 1e-9)
        #expect(abs(llh.y - llhBack.y) < 1e-9)
        #expect(abs(llh.z - llhBack.z) < 1e-3)
    }
    
    /// Verifies conversion from NEU vectors to Azimuth and Elevation angles.
    @Test func testNEU2Azel() async throws {
        // Point directly North
        let neuN = Vector3(100, 0, 0)
        let azelN = MathUtils.neu2azel(neuN)
        #expect(abs(azelN.az) < 1e-9)
        #expect(abs(azelN.el) < 1e-9)
        
        // Point directly East
        let neuE = Vector3(0, 100, 0)
        let azelE = MathUtils.neu2azel(neuE)
        #expect(abs(azelE.az - 90.0 * Constants.D2R) < 1e-9)
        #expect(abs(azelE.el) < 1e-9)
        
        // Point directly Up
        let neuU = Vector3(0, 0, 100)
        let azelU = MathUtils.neu2azel(neuU)
        #expect(abs(azelU.el - 90.0 * Constants.D2R) < 1e-9)
    }
}
