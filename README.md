# Modbus MITM (Man-in-the-Middle) Tool

A Python script for performing Man-in-the-Middle attacks on Modbus TCP communications using Scapy.

## Description

This tool demonstrates how to intercept and modify Modbus TCP packets in a network environment. It constructs and injects custom Modbus TCP packets to simulate communication between a Modbus master and PLC (Programmable Logic Controller).

## Features

- Constructs Modbus TCP packets with custom parameters
- Supports Modbus function code 5 (Write Single Register)
- Configurable source and destination IP addresses
- Customizable TCP sequence and acknowledgment numbers
- Packet injection using Scapy

## Requirements

- Python 3.x
- Scapy library

## Installation

1. Clone this repository:
```bash
git clone <your-repo-url>
cd modbus-mitm
```

2. Install required dependencies:
```bash
pip install scapy
```

## Usage

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

3. Run the script:
```bash
python MITM_MODBUS.py
```

## Configuration

The script includes the following configurable parameters:

### Network Configuration
- `ip_master = "192.168.1.60"` - Master device IP
- `ip_plc = "192.168.1.20"` - PLC device IP
- `sport = 12345` - Source TCP port
- `dport = 502` - Modbus TCP port

### Modbus Configuration
- `transaction_id = 0x0001` - Transaction identifier
- `function_code = 5` - Write Single Register function
- `register_address = 0x000A` - Target register address
- `register_value = 0x0019` - Value to write

## Security Notice

⚠️ **WARNING**: This tool is for educational and authorized testing purposes only. Only use this tool on networks you own or have explicit permission to test. Unauthorized network interception may violate laws and regulations.

## Legal Disclaimer

This software is provided for educational purposes only. The authors are not responsible for any misuse of this tool. Users must ensure they have proper authorization before using this tool on any network.

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
