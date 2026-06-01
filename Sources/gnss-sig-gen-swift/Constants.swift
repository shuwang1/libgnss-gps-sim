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

/// A collection of mathematical and physical constants used in GNSS simulations.
enum Constants {
    /// Mathematical constant Pi.
    static let PI = 3.1415926535898
    /// Conversion factor from Radians to Degrees.
    static let R2D = 57.2957795131
    /// Conversion factor from Degrees to Radians.
    static let D2R = PI / 180.0
    
    /// Speed of light in vacuum (m/s).
    static let SPEED_OF_LIGHT = 2.99792458e8
    /// Wavelength of the GPS L1 signal (meters).
    static let LAMBDA_L1 = 0.190293672798365
    
    /// Fundamental frequency of GPS L1 carrier (Hz).
    static let FREQ_GPS_L1 = 1575.42e6
    /// Standard GPS C/A code chipping rate (chips/s).
    static let CODE_FREQ = 1.023e6
    /// Ratio of carrier frequency to code frequency.
    static let CARR_TO_CODE = 1.0 / 1540.0
    
    /// Earth's gravitational parameter (m^3/s^2).
    static let GM_EARTH = 3.986005e14
    /// WGS84 semi-major axis of the Earth (meters).
    static let WGS84_RADIUS = 6378137.0
    /// WGS84 first eccentricity of the Earth.
    static let WGS84_ECCENTRICITY = 0.0818191908426
    
    /// Maximum number of GPS satellites in the constellation.
    static let MAX_SAT = 32
    /// Maximum number of hardware channels simulated.
    static let MAX_CHAN = 16
    
    /// Default simulation time step (seconds).
    static let TIME_STEP = 0.1
    /// Earth's rotation rate (rad/s).
    static let OMEGA_EARTH = 7.2921151467e-5
    /// Size of the ephemeris history array.
    static let EPHEM_ARRAY_SIZE = 15
    
    /// Number of seconds in a GPS week.
    static let SECONDS_IN_WEEK = 604800.0
    /// Number of seconds in half a GPS week.
    static let SECONDS_IN_HALF_WEEK = 302400.0
    /// Number of seconds in a day.
    static let SECONDS_IN_DAY = 86400.0
    /// Number of seconds in an hour.
    static let SECONDS_IN_HOUR = 3600.0
    /// Number of seconds in a minute.
    static let SECONDS_IN_MINUTE = 60.0
}
