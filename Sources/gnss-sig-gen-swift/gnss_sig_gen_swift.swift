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
import ArgumentParser

/// The main entry point for the GNSS Signal Generator CLI application.
@main
struct GNSSSigGen: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "gnss-sig-gen-swift",
        abstract: "A modularized GNSS L1 C/A baseband signal generator for SDR hardware.",
        version: "1.0.0"
    )
    
    @Option(name: .shortAndLong, help: "Path to the RINEX navigation file.")
    var ephemeris: String?
    
    @Option(name: .shortAndLong, help: "Path to an ECEF motion CSV file (columns: t,x,y,z).")
    var userMotion: String?
    
    @Option(name: .customLong("llh-motion"), help: "Path to an LLH motion CSV file (columns: t,lat,lon,h).")
    var llhMotion: String?
    
    @Option(name: .customLong("nmea-gga"), help: "Path to an NMEA GGA stream file.")
    var nmeaGga: String?
    
    @Option(name: .shortAndLong, help: "Path for the output binary signal file.")
    var output: String = "gpssim.bin"
    
    @Option(name: .shortAndLong, help: "Sampling frequency in Hz.")
    var sampFreq: Double = 2600000.0
    
    @Option(name: .customLong("elv-mask"), help: "Satellite elevation mask in degrees.")
    var elvMask: Double = 5.0
    
    @Option(name: .shortAndLong, help: "Simulation duration in seconds.")
    var duration: Int = 300
    
    @Option(name: .shortAndLong, help: "I/Q sample format: 1, 8, or 16 bits.")
    var bits: Int = 16
    
    @Flag(name: .shortAndLong, help: "Enable verbose debug logging.")
    var verbose: Bool = false

    /// Executes the CLI command logic.
    mutating func run() throws {
        Logger.minLevel = verbose ? .debug : .info
        
        var config = Simulator.Config()
        config.navFile = ephemeris ?? ""
        config.umFile = userMotion ?? llhMotion ?? nmeaGga ?? ""
        config.outFile = output
        config.sampFreq = sampFreq
        config.elvMask = elvMask
        config.duration = duration
        config.dataFormat = bits
        config.verbose = verbose
        
        if llhMotion != nil { config.umLLH = true }
        if nmeaGga != nil { config.nmeaGGA = true }
        if config.umFile.isEmpty { config.staticMode = true }
        
        guard !config.navFile.isEmpty else {
            Logger.error("RINEX navigation file is required. Use -e to provide one.")
            throw ExitCode.failure
        }
        
        let simulator = Simulator(config: config)
        guard simulator.initialize() else {
            Logger.error("Simulator initialization failed. Please check your RINEX and trajectory files.")
            throw ExitCode.failure
        }
        
        Logger.info("Starting simulation for \(config.duration) seconds...")
        
        guard let fileHandle = FileHandle(forWritingAtPath: config.outFile) ?? 
                (FileManager.default.createFile(atPath: config.outFile, contents: nil) ? FileHandle(forWritingAtPath: config.outFile) : nil) else {
            Logger.error("Failed to open output file \(config.outFile)")
            throw ExitCode.failure
        }
        
        defer { try? fileHandle.close() }
        
        for i in 0..<simulator.numSteps {
            if let samples = simulator.step(stepIdx: i) {
                let data = samples.withUnsafeBufferPointer { Data(buffer: $0) }
                try fileHandle.write(contentsOf: data)
            }
            if i % 100 == 0 {
                let progress = Int(Double(i) / Double(simulator.numSteps) * 100)
                print("Progress: \(progress)%", terminator: "\r")
                try? FileHandle.standardOutput.synchronize()
            }
        }
        Logger.info("\nSimulation completed.")
    }
}
