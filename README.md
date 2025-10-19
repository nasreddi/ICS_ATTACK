# ICS_ATTACK

A collection of Industrial Control Systems (ICS) security testing tools and attack demonstrations.

## About

This repository contains various tools and scripts for testing and demonstrating security vulnerabilities in Industrial Control Systems, including SCADA networks and PLC communications. These tools are designed for educational purposes and authorized security testing only.

## Tools Included

### 1. Modbus OT/ICS Attack Tool
**File:** `OT_ICS_ATTACK_MODBUS.py`

A Python script for performing Man-in-the-Middle attacks on Modbus TCP communications using Scapy.

#### Description
This tool demonstrates how to intercept and modify Modbus TCP packets in a network environment. It constructs and injects custom Modbus TCP packets to simulate communication between a Modbus master and PLC (Programmable Logic Controller).

#### Features
- Constructs Modbus TCP packets with custom parameters
- Supports Modbus function code 5 (Write Single Register)
- Configurable source and destination IP addresses
- Customizable TCP sequence and acknowledgment numbers
- Packet injection using Scapy

### 2. S7CommPlus OT/ICS Attack Tool
**File:** `OT_ICS_ATTACK_S7COMMPLUS.py`

A comprehensive attack tool targeting Siemens S7-1200/1500 PLCs using the S7CommPlus protocol.

#### Features
- Read/Write operations on PLC data blocks
- CPU stop commands
- Malicious code injection
- System reconnaissance
- Multiple attack vectors

### 3. S7Comm OT/ICS Attack Tool
**File:** `OT_ICS_ATTACK_S7COMM.py`

Advanced attack tool for Siemens S7-300/400 PLCs using the S7Comm protocol.

#### Features
- Data block manipulation
- Hot/Cold restart attacks
- Malicious block download
- DoS attacks
- Code injection capabilities

### 4. IEC 61850 OT/ICS Attack Tool
**File:** `OT_ICS_ATTACK_IEC61850.py`

Sophisticated attack tool targeting IEC 61850 substation automation systems.

#### Features
- MMS (Manufacturing Message Specification) attacks
- GOOSE message injection
- Sampled Values (SV) manipulation
- Association establishment attacks
- GOOSE flooding attacks

### 5. IEC 104 OT/ICS Attack Tool
**File:** `OT_ICS_ATTACK_IEC104.py`

Comprehensive attack tool for IEC 104 telecontrol systems used in SCADA networks.

#### Features
- Single and double command injection
- Setpoint manipulation
- Clock synchronization attacks
- Test command flooding
- General interrogation attacks

### 6. DNP3 OT/ICS Attack Tool
**File:** `OT_ICS_ATTACK_DNP3.py`

Advanced attack tool targeting DNP3 (Distributed Network Protocol) systems.

#### Features
- Direct operate commands
- Select and operate sequences
- Analog output manipulation
- Time synchronization attacks
- Cold/Warm restart attacks

#### Requirements

- Python 3.x
- Scapy library

#### Installation

1. Clone this repository:
```bash
git clone https://github.com/nasreddi/ICS_ATTACK.git
cd ICS_ATTACK
```

2. Install required dependencies:
```bash
pip install scapy
```

#### Usage

1. Configure the network parameters in the script:
   - `ip_master`: IP address of the Modbus master
   - `ip_plc`: IP address of the PLC
   - `sport`: Source TCP port
   - `dport`: Destination TCP port (typically 502 for Modbus)
   - `seq_num` and `ack_num`: TCP sequence and acknowledgment numbers

2. Modify the Modbus parameters as needed:
   - `transaction_id`: Modbus transaction identifier
   - `function_code`: Modbus function code (5 for Write Single Register)
   - `register_address`: Target register address
   - `register_value`: Value to write to the register

3. Run any of the scripts:
```bash
python OT_ICS_ATTACK_MODBUS.py
python OT_ICS_ATTACK_S7COMMPLUS.py
python OT_ICS_ATTACK_S7COMM.py
python OT_ICS_ATTACK_IEC61850.py
python OT_ICS_ATTACK_IEC104.py
python OT_ICS_ATTACK_DNP3.py
```

#### General Configuration

All scripts include configurable network parameters:

##### Network Configuration (Common to all tools)
- `ip_master` - Master/HMI/SCADA IP address
- `ip_target` - Target device IP address (PLC/RTU/IED)
- `sport` - Source TCP port
- `dport` - Destination TCP port (protocol-specific)
- `seq_num` and `ack_num` - TCP sequence and acknowledgment numbers

##### Protocol-Specific Configuration

**Modbus TCP:**
- `transaction_id = 0x0001` - Transaction identifier
- `function_code = 5` - Write Single Register function
- `register_address = 0x000A` - Target register address
- `register_value = 0x0019` - Value to write

**S7Comm/S7CommPlus:**
- `db_number` - Data block number
- `area` - Memory area (DB, Input, Output, etc.)
- `address` - Memory address offset

**IEC 61850:**
- `object_name` - Logical node object name
- `goose_id` - GOOSE message identifier
- `sv_id` - Sampled Values identifier

**IEC 104:**
- `asdu_addr` - ASDU address
- `io_addr` - Information object address
- `cot` - Cause of transmission

**DNP3:**
- `object_group` - Object group number
- `object_variation` - Object variation
- `index` - Point index

## Security Notice

⚠️ **WARNING**: These tools are for educational and authorized testing purposes only. Only use these tools on networks you own or have explicit permission to test. Unauthorized network interception and attacks may violate laws and regulations.

## Legal Disclaimer

This software is provided for educational purposes only. The authors are not responsible for any misuse of these tools. Users must ensure they have proper authorization before using these tools on any network.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For questions or issues, please open an issue in the GitHub repository.