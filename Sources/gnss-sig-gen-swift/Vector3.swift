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

/// A simple 3D vector implementation for GNSS calculations.
/// 
/// Used for ECEF (Earth-Centered, Earth-Fixed) positions and LLH (Latitude, Longitude, Height) coordinates.
struct Vector3: Equatable {
    /// The X component (or Latitude in radians).
    var x: Double
    /// The Y component (or Longitude in radians).
    var y: Double
    /// The Z component (or Height in meters).
    var z: Double
    
    /// Initializes a new vector with the given components.
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /// Adds two vectors.
    static func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    /// Subtracts the second vector from the first.
    static func -(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    /// Multiplies a vector by a scalar.
    static func *(lhs: Vector3, rhs: Double) -> Vector3 {
        return Vector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    
    /// Multiplies a vector by a scalar.
    static func *(lhs: Double, rhs: Vector3) -> Vector3 {
        return rhs * lhs
    }
    
    /// Divides a vector by a scalar.
    static func /(lhs: Vector3, rhs: Double) -> Vector3 {
        return Vector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    
    /// Adds the second vector to the first in-place.
    static func +=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs + rhs
    }
    
    /// Subtracts the second vector from the first in-place.
    static func -=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs - rhs
    }
    
    /// Accesses the vector components by index (0: x, 1: y, 2: z).
    subscript(index: Int) -> Double {
        get {
            switch index {
            case 0: return x
            case 1: return y
            case 2: return z
            default: fatalError("Index out of range")
            }
        }
        set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: fatalError("Index out of range")
            }
        }
    }
}

/// Computes the Euclidean norm (length) of a 3D vector.
/// - Parameter v: The input vector.
/// - Returns: The magnitude of the vector.
func length(_ v: Vector3) -> Double {
    return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
}

/// Computes the dot product of two 3D vectors.
/// - Parameters:
///   - v1: The first vector.
///   - v2: The second vector.
/// - Returns: The scalar dot product.
func dot(_ v1: Vector3, _ v2: Vector3) -> Double {
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
}
