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

/// Unit tests for trajectory and user motion file parsing.
struct TrajectoryTests {

    /// Verifies parsing of ECEF CSV trajectory files and robustness to whitespace.
    @Test func testReadUserMotion() async throws {
        let csvContent = "0.0, 1000.0, 2000.0, 3000.0\n0.1, 1001.0, 2001.0, 3001.0"
        let tempFile = "/tmp/test_motion.csv"
        try csvContent.write(toFile: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: tempFile) }
        
        guard let trajectory = Trajectory.readUserMotion(filename: tempFile) else {
            Issue.record("Failed to read trajectory")
            return
        }
        
        guard trajectory.count == 2 else {
            Issue.record("Expected 2 trajectory points, got \(trajectory.count)")
            return
        }
        #expect(trajectory[0] == Vector3(1000.0, 2000.0, 3000.0))
        #expect(trajectory[1] == Vector3(1001.0, 2001.0, 3001.0))
    }
}
