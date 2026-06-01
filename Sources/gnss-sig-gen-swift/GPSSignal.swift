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

/// Core signal processing for GNSS baseband generation.
struct GPSSignal {
    /// Updates the code and carrier phases for a channel based on receiver motion.
    /// - Parameters:
    ///   - chan: The channel link to update.
    ///   - rho1: The new estimated range parameters.
    ///   - dt: Simulation time step.
    ///   - delt: Sample period.
    static func updateCodePhase(chan: inout Link, rho1: Range, dt: Double, delt: Double) {
        let fCenter = Constants.FREQ_GPS_L1
        let fCodeBase = Constants.CODE_FREQ
        
        let lambda = Constants.SPEED_OF_LIGHT / fCenter
        chan.fCarr = (chan.rho0.range - rho1.range) / (dt * lambda)
        chan.fCode = fCodeBase + chan.fCarr * (fCodeBase / fCenter)
        
        let ms = ((chan.rho0.g - chan.g0) + 6.0 - chan.rho0.range / Constants.SPEED_OF_LIGHT) * 1000.0
        let ims = Int(floor(ms))
        chan.codePhase = (ms - Double(ims)) * Double(chan.codeLength)
        
        var msVal = ims
        chan.iword = msVal / 600
        msVal -= chan.iword * 600
        chan.ibit = msVal / 20
        msVal -= chan.ibit * 20
        chan.icode = msVal
        
        chan.codePhaseFixed = UInt64(chan.codePhase * 4294967296.0)
        chan.codePhaseStep = UInt64(chan.fCode * delt * 4294967296.0)
        
        let chipIdx = Int(chan.codePhase)
        chan.codeCA = Int(((chan.ca[chipIdx >> 5] >> (chipIdx & 0x1F)) & 1) << 1) - 1
        
        chan.dataBit = Int((chan.dwrd[chan.iword] >> (29 - chan.ibit)) & 0x1) * 2 - 1
        chan.rho0 = rho1
    }
    
    /// Generates interleaved I/Q samples for the active channels.
    /// - Parameters:
    ///   - iqBuff: The output buffer for I/Q samples.
    ///   - iqBuffSize: Number of complex samples to generate.
    ///   - channels: Array of all simulation channels.
    ///   - gains: Signal gain for each channel.
    ///   - active: Indices of active channels to synthesize.
    static func generateSamples(iqBuff: inout [Int16], iqBuffSize: Int, channels: inout [Link], gains: [Int], active: [Int]) {
        var iAcc = [Int](repeating: 0, count: iqBuffSize)
        var qAcc = [Int](repeating: 0, count: iqBuffSize)
        
        for ai in active {
            var c = channels[ai]
            var g = gains[ai] * c.dataBit
            var codePhase = c.codePhaseFixed
            let codeStep = c.codePhaseStep
            var carrPhase = c.carrPhase
            let carrStep = UInt32(c.carrPhaseStep)
            
            var isamp = 0
            while isamp < iqBuffSize {
                var chip = UInt32(codePhase >> 32)
                if chip >= UInt32(c.codeLength) {
                    codePhase -= UInt64(c.codeLength) << 32
                    chip -= UInt32(c.codeLength)
                    c.icode += 1
                    if c.icode >= 20 {
                        c.icode = 0
                        c.ibit += 1
                        if c.ibit >= 30 {
                            c.ibit = 0
                            c.iword += 1
                        }
                        c.dataBit = Int((c.dwrd[c.iword] >> (29 - c.ibit)) & 0x1) * 2 - 1
                        g = gains[ai] * c.dataBit
                    }
                }
                
                let remainingFixed = (UInt64(chip + 1) << 32) - codePhase
                let nSamplesInChip = Int((remainingFixed + codeStep - 1) / codeStep)
                var nToDo = iqBuffSize - isamp
                if nToDo > nSamplesInChip { nToDo = nSamplesInChip }
                
                let p_val = Int(((c.ca[Int(chip) >> 5] >> (Int(chip) & 0x1F)) & 1) << 1) - 1
                var p = p_val
                if c.mod == .boc11 {
                    let subPhase = UInt32(codePhase >> 31)
                    if (subPhase & 1) != 0 { p = -p }
                }
                p *= g
                
                for _ in 0..<nToDo {
                    let iTable = Int((carrPhase >> 16) & 0x1ff)
                    iAcc[isamp] += p * Int(LUT.iq_lut[iTable << 1])
                    qAcc[isamp] += p * Int(LUT.iq_lut[(iTable << 1) + 1])
                    carrPhase = carrPhase &+ carrStep
                    codePhase += codeStep
                    isamp += 1
                }
            }
            c.codePhaseFixed = codePhase
            c.carrPhase = carrPhase
            let currentChip = Int(codePhase >> 32)
            c.codeCA = Int(((c.ca[currentChip >> 5] >> (currentChip & 0x1F)) & 1) << 1) - 1
            channels[ai] = c
        }
        
        for isamp in 0..<iqBuffSize {
            iqBuff[isamp << 1] = Int16(truncatingIfNeeded: (iAcc[isamp] + 64) >> 7)
            iqBuff[(isamp << 1) + 1] = Int16(truncatingIfNeeded: (qAcc[isamp] + 64) >> 7)
        }
    }
}
