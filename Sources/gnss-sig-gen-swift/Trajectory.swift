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

/// Utilities for reading user motion/trajectory files.
struct Trajectory {
    
    /// Reads ECEF user motion from a CSV file (t, x, y, z).
    /// - Parameter filename: Path to the CSV file.
    /// - Returns: An array of ECEF position vectors, or `nil` if the file could not be read.
    static func readUserMotion(filename: String) -> [Vector3]? {
        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
            Logger.error("Failed to open user motion file: \(filename)")
            return nil
        }
        
        var results = [Vector3]()
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count >= 4 {
                if let x = Double(parts[1]), let y = Double(parts[2]), let z = Double(parts[3]) {
                    results.append(Vector3(x, y, z))
                }
            }
        }
        return results
    }
    
    /// Reads LLH user motion from a CSV file (t, lat, lon, h) and converts to ECEF.
    /// - Parameter filename: Path to the CSV file.
    /// - Returns: An array of ECEF position vectors, or `nil` if the file could not be read.
    static func readUserMotionLLH(filename: String) -> [Vector3]? {
        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
            Logger.error("Failed to open user motion file: \(filename)")
            return nil
        }
        
        var results = [Vector3]()
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.components(separatedBy: ",")
            if parts.count >= 4 {
                if let lat = Double(parts[1]), let lon = Double(parts[2]), let h = Double(parts[3]) {
                    let llh = Vector3(lat * Constants.D2R, lon * Constants.D2R, h)
                    results.append(MathUtils.llh2xyz(llh))
                }
            }
        }
        return results
    }
    
    /// Reads user motion from an NMEA GGA stream/file and converts to ECEF.
    /// - Parameter filename: Path to the NMEA file.
    /// - Returns: An array of ECEF position vectors, or `nil` if the file could not be read.
    static func readNmeaGGA(filename: String) -> [Vector3]? {
        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
            Logger.error("Failed to open NMEA GGA file: \(filename)")
            return nil
        }
        
        var results = [Vector3]()
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.components(separatedBy: ",")
            if parts.count > 0 && parts[0].suffix(3) == "GGA" {
                if parts.count >= 10 {
                    let latStr = parts[2]
                    let lonStr = parts[4]
                    if latStr.count >= 2 && lonStr.count >= 3 {
                        var lat = (Double(latStr.prefix(2)) ?? 0) + (Double(latStr.dropFirst(2)) ?? 0) / 60.0
                        if parts[3] == "S" { lat *= -1.0 }
                        var lon = (Double(lonStr.prefix(3)) ?? 0) + (Double(lonStr.dropFirst(3)) ?? 0) / 60.0
                        if parts[5] == "W" { lon *= -1.0 }
                        
                        var alt = Double(parts[9]) ?? 0.0
                        if parts.count >= 12, let geoid = Double(parts[11]) {
                            alt += geoid
                        }
                        
                        let llh = Vector3(lat * Constants.D2R, lon * Constants.D2R, alt)
                        results.append(MathUtils.llh2xyz(llh))
                    }
                }
            }
        }
        return results
    }
}
