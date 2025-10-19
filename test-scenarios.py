#!/usr/bin/env python3
"""
OT/ICS Attack Test Scenarios
Script de test automatisé pour valider les attaques sur le laboratoire
"""

import time
import subprocess
import requests
import json
from scapy.all import *
import threading

class OTICSTestLab:
    def __init__(self):
        self.lab_config = {
            "openplc": {"ip": "192.168.1.10", "port": 8080, "modbus_port": 502},
            "fuxa": {"ip": "192.168.1.20", "port": 1881},
            "modbus_slave": {"ip": "192.168.1.30", "port": 503},
            "iec104": {"ip": "192.168.1.40", "port": 2404},
            "dnp3": {"ip": "192.168.1.50", "port": 20000}
        }
        
        self.test_results = {}
        
    def check_service_health(self, service_name, url):
        """Vérifier la santé d'un service"""
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                print(f"✅ {service_name} est accessible")
                return True
            else:
                print(f"❌ {service_name} répond avec le code {response.status_code}")
                return False
        except requests.exceptions.RequestException as e:
            print(f"❌ {service_name} n'est pas accessible: {e}")
            return False
    
    def check_all_services(self):
        """Vérifier tous les services du laboratoire"""
        print("🔍 Vérification des services du laboratoire...")
        
        services = {
            "OpenPLC": f"http://localhost:8080",
            "FUXA": f"http://localhost:1881",
            "Elasticsearch": f"http://localhost:9200",
            "Kibana": f"http://localhost:5601",
            "Grafana": f"http://localhost:3001"
        }
        
        all_healthy = True
        for service, url in services.items():
            if not self.check_service_health(service, url):
                all_healthy = False
        
        return all_healthy
    
    def run_modbus_attack_test(self):
        """Test d'attaque Modbus TCP"""
        print("\n🎯 Test d'attaque Modbus TCP...")
        
        try:
            # Exécuter l'attaque Modbus
            result = subprocess.run([
                "python3", "OT_ICS_ATTACK_MODBUS.py"
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print("✅ Attaque Modbus exécutée avec succès")
                self.test_results["modbus_attack"] = "SUCCESS"
            else:
                print(f"❌ Erreur lors de l'attaque Modbus: {result.stderr}")
                self.test_results["modbus_attack"] = "FAILED"
                
        except subprocess.TimeoutExpired:
            print("⏰ Timeout lors de l'attaque Modbus")
            self.test_results["modbus_attack"] = "TIMEOUT"
        except Exception as e:
            print(f"❌ Erreur inattendue: {e}")
            self.test_results["modbus_attack"] = "ERROR"
    
    def run_s7comm_attack_test(self):
        """Test d'attaque S7Comm"""
        print("\n🎯 Test d'attaque S7Comm...")
        
        try:
            result = subprocess.run([
                "python3", "OT_ICS_ATTACK_S7COMM.py"
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print("✅ Attaque S7Comm exécutée avec succès")
                self.test_results["s7comm_attack"] = "SUCCESS"
            else:
                print(f"❌ Erreur lors de l'attaque S7Comm: {result.stderr}")
                self.test_results["s7comm_attack"] = "FAILED"
                
        except subprocess.TimeoutExpired:
            print("⏰ Timeout lors de l'attaque S7Comm")
            self.test_results["s7comm_attack"] = "TIMEOUT"
        except Exception as e:
            print(f"❌ Erreur inattendue: {e}")
            self.test_results["s7comm_attack"] = "ERROR"
    
    def run_iec104_attack_test(self):
        """Test d'attaque IEC 104"""
        print("\n🎯 Test d'attaque IEC 104...")
        
        try:
            result = subprocess.run([
                "python3", "OT_ICS_ATTACK_IEC104.py"
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print("✅ Attaque IEC 104 exécutée avec succès")
                self.test_results["iec104_attack"] = "SUCCESS"
            else:
                print(f"❌ Erreur lors de l'attaque IEC 104: {result.stderr}")
                self.test_results["iec104_attack"] = "FAILED"
                
        except subprocess.TimeoutExpired:
            print("⏰ Timeout lors de l'attaque IEC 104")
            self.test_results["iec104_attack"] = "TIMEOUT"
        except Exception as e:
            print(f"❌ Erreur inattendue: {e}")
            self.test_results["iec104_attack"] = "ERROR"
    
    def run_dnp3_attack_test(self):
        """Test d'attaque DNP3"""
        print("\n🎯 Test d'attaque DNP3...")
        
        try:
            result = subprocess.run([
                "python3", "OT_ICS_ATTACK_DNP3.py"
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print("✅ Attaque DNP3 exécutée avec succès")
                self.test_results["dnp3_attack"] = "SUCCESS"
            else:
                print(f"❌ Erreur lors de l'attaque DNP3: {result.stderr}")
                self.test_results["dnp3_attack"] = "FAILED"
                
        except subprocess.TimeoutExpired:
            print("⏰ Timeout lors de l'attaque DNP3")
            self.test_results["dnp3_attack"] = "TIMEOUT"
        except Exception as e:
            print(f"❌ Erreur inattendue: {e}")
            self.test_results["dnp3_attack"] = "ERROR"
    
    def capture_network_traffic(self, duration=60):
        """Capturer le trafic réseau pendant les tests"""
        print(f"\n📡 Capture du trafic réseau pendant {duration} secondes...")
        
        def capture():
            try:
                # Capturer le trafic sur l'interface Docker
                packets = sniff(
                    filter="host 192.168.1.0/24",
                    timeout=duration,
                    iface=None  # Auto-détection de l'interface
                )
                
                # Sauvegarder les paquets capturés
                wrpcap("lab-config/wireshark/captures/test_capture.pcap", packets)
                print(f"✅ {len(packets)} paquets capturés et sauvegardés")
                
            except Exception as e:
                print(f"❌ Erreur lors de la capture: {e}")
        
        # Démarrer la capture en arrière-plan
        capture_thread = threading.Thread(target=capture)
        capture_thread.daemon = True
        capture_thread.start()
        
        return capture_thread
    
    def generate_test_report(self):
        """Générer un rapport de test"""
        print("\n📊 Génération du rapport de test...")
        
        report = {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "test_results": self.test_results,
            "lab_config": self.lab_config,
            "summary": {
                "total_tests": len(self.test_results),
                "successful_tests": sum(1 for result in self.test_results.values() if result == "SUCCESS"),
                "failed_tests": sum(1 for result in self.test_results.values() if result == "FAILED"),
                "timeout_tests": sum(1 for result in self.test_results.values() if result == "TIMEOUT"),
                "error_tests": sum(1 for result in self.test_results.values() if result == "ERROR")
            }
        }
        
        # Sauvegarder le rapport
        with open("lab-config/test_report.json", "w") as f:
            json.dump(report, f, indent=2)
        
        # Afficher le résumé
        print("\n📈 Résumé des Tests")
        print("===================")
        print(f"Tests totaux: {report['summary']['total_tests']}")
        print(f"Tests réussis: {report['summary']['successful_tests']}")
        print(f"Tests échoués: {report['summary']['failed_tests']}")
        print(f"Tests timeout: {report['summary']['timeout_tests']}")
        print(f"Tests en erreur: {report['summary']['error_tests']}")
        
        return report
    
    def run_comprehensive_test(self):
        """Exécuter une suite complète de tests"""
        print("🚀 Démarrage des tests complets du laboratoire OT/ICS")
        print("=" * 60)
        
        # Vérifier les services
        if not self.check_all_services():
            print("❌ Certains services ne sont pas disponibles. Arrêt des tests.")
            return False
        
        # Démarrer la capture réseau
        capture_thread = self.capture_network_traffic(300)  # 5 minutes
        
        # Exécuter les tests d'attaque
        self.run_modbus_attack_test()
        time.sleep(5)
        
        self.run_s7comm_attack_test()
        time.sleep(5)
        
        self.run_iec104_attack_test()
        time.sleep(5)
        
        self.run_dnp3_attack_test()
        
        # Attendre la fin de la capture
        capture_thread.join()
        
        # Générer le rapport
        report = self.generate_test_report()
        
        print("\n✅ Tests complets terminés!")
        return True

def main():
    """Fonction principale"""
    print("🏭 OT/ICS Attack Laboratory Test Suite")
    print("=====================================")
    
    lab = OTICSTestLab()
    
    # Menu interactif
    while True:
        print("\nOptions disponibles:")
        print("1. Vérifier les services")
        print("2. Test d'attaque Modbus")
        print("3. Test d'attaque S7Comm")
        print("4. Test d'attaque IEC 104")
        print("5. Test d'attaque DNP3")
        print("6. Tests complets")
        print("7. Quitter")
        
        choice = input("\nVotre choix (1-7): ").strip()
        
        if choice == "1":
            lab.check_all_services()
        elif choice == "2":
            lab.run_modbus_attack_test()
        elif choice == "3":
            lab.run_s7comm_attack_test()
        elif choice == "4":
            lab.run_iec104_attack_test()
        elif choice == "5":
            lab.run_dnp3_attack_test()
        elif choice == "6":
            lab.run_comprehensive_test()
        elif choice == "7":
            print("👋 Au revoir!")
            break
        else:
            print("❌ Choix invalide. Veuillez choisir entre 1 et 7.")

if __name__ == "__main__":
    main()
