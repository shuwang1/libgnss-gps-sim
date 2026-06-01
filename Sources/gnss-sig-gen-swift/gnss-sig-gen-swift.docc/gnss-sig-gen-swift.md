# ``gnss_sig_gen_swift``

A modularized GNSS L1 C/A baseband signal generator for SDR hardware.

## Overview

`gnss-sig-gen-swift` is a high-performance Swift port of the original C-based signal generator. It allows for the simulation of GPS, GLONASS, Galileo, and BeiDou signals, generating raw baseband I/Q samples suitable for transmission via Software Defined Radio (SDR) hardware.

### Key Features

- **Multi-constellation Support**: Simulation logic for various GNSS constellations.
- **Physics-Based Simulation**: Includes Earth rotation, relativistic effects, and ionospheric delays.
- **Custom Trajectories**: Support for ECEF/LLH CSV files and NMEA GGA streams.
- **Scalable Sample Generation**: Optimized synthesis supporting various sampling frequencies and bit depths.

## Usage

For detailed installation and execution instructions, please refer to the `INSTALL.md` file in the project root.

## Topics

### Core Simulation

- ``Simulator``
- ``GPSSignal``
- ``Channel``

### Data Models

- ``Ephemeris``
- ``IonUTC``
- ``GPSTime``
- ``DateTime``
- ``Vector3``

### Utilities

- ``Logger``
- ``GPSCode``
- ``MathUtils``
- ``Checksum``
