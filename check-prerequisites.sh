#!/bin/bash

# OT/ICS Attack Laboratory - Prerequisites Checker for Kali Linux
# This script verifies that all required tools and dependencies are installed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  OT/ICS Attack Lab - Prerequisites Check${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Check if running on Kali Linux
check_kali_linux() {
    print_status "Checking if running on Kali Linux..."
    
    if [ -f /etc/os-release ]; then
        if grep -q "Kali" /etc/os-release; then
            print_success "Running on Kali Linux"
            return 0
        else
            print_warning "Not running on Kali Linux. Some tools may not be available."
            return 1
        fi
    else
        print_warning "Cannot determine OS version"
        return 1
    fi
}

# Check system requirements
check_system_requirements() {
    print_status "Checking system requirements..."
    
    # Check available disk space (minimum 20GB)
    AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
    if [ $AVAILABLE_SPACE -lt 20971520 ]; then
        print_error "Insufficient disk space. Minimum 20GB required."
        print_error "Available: $(($AVAILABLE_SPACE / 1024 / 1024))GB"
        return 1
    else
        print_success "Disk space OK: $(($AVAILABLE_SPACE / 1024 / 1024))GB available"
    fi
    
    # Check RAM (minimum 8GB)
    TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
    if [ $TOTAL_RAM -lt 8192 ]; then
        print_error "Insufficient RAM. Minimum 8GB required."
        print_error "Available: ${TOTAL_RAM}MB"
        return 1
    else
        print_success "RAM OK: ${TOTAL_RAM}MB available"
    fi
    
    # Check CPU cores (minimum 2)
    CPU_CORES=$(nproc)
    if [ $CPU_CORES -lt 2 ]; then
        print_warning "Low CPU cores: ${CPU_CORES}. Recommended: 2+ cores"
    else
        print_success "CPU OK: ${CPU_CORES} cores"
    fi
}

# Check Docker installation
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        print_status "Installing Docker..."
        
        # Update package list
        sudo apt update
        
        # Install Docker
        sudo apt install -y docker.io docker-compose
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        
        # Start and enable Docker service
        sudo systemctl start docker
        sudo systemctl enable docker
        
        print_success "Docker installed successfully"
        print_warning "Please log out and log back in for group changes to take effect"
    else
        print_success "Docker is installed: $(docker --version)"
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running!"
        print_status "Starting Docker daemon..."
        sudo systemctl start docker
        sleep 5
        
        if docker info &> /dev/null; then
            print_success "Docker daemon started"
        else
            print_error "Failed to start Docker daemon"
            return 1
        fi
    else
        print_success "Docker daemon is running"
    fi
}

# Check Docker Compose
check_docker_compose() {
    print_status "Checking Docker Compose..."
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed!"
        print_status "Installing Docker Compose..."
        sudo apt install -y docker-compose
    else
        print_success "Docker Compose is installed: $(docker-compose --version)"
    fi
}

# Check Python 3
check_python() {
    print_status "Checking Python 3 installation..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed!"
        print_status "Installing Python 3..."
        sudo apt install -y python3 python3-pip python3-venv
    else
        print_success "Python 3 is installed: $(python3 --version)"
    fi
    
    # Check pip3
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is not installed!"
        print_status "Installing pip3..."
        sudo apt install -y python3-pip
    else
        print_success "pip3 is installed: $(pip3 --version)"
    fi
}

# Check required Python packages
check_python_packages() {
    print_status "Checking Python packages..."
    
    # Check if requirements.txt exists
    if [ ! -f "requirements.txt" ]; then
        print_warning "requirements.txt not found. Skipping package check."
        return 0
    fi
    
    # Check if virtual environment exists
    if [ ! -d ".venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv .venv
    fi
    
    # Activate virtual environment
    source .venv/bin/activate
    
    # Install requirements
    print_status "Installing Python requirements..."
    pip install --upgrade pip
    pip install -r requirements.txt
    
    print_success "Python packages installed"
}

# Check network tools
check_network_tools() {
    print_status "Checking network tools..."
    
    # Check for common network tools
    TOOLS=("nmap" "netcat" "tcpdump" "wireshark" "curl" "wget")
    
    for tool in "${TOOLS[@]}"; do
        if command -v $tool &> /dev/null; then
            print_success "$tool is installed"
        else
            print_warning "$tool is not installed"
            print_status "Installing $tool..."
            sudo apt install -y $tool
        fi
    done
}

# Check Kali Linux specific tools
check_kali_tools() {
    print_status "Checking Kali Linux specific tools..."
    
    # Check for Scapy (should be pre-installed on Kali)
    if python3 -c "import scapy" 2>/dev/null; then
        print_success "Scapy is available"
    else
        print_warning "Scapy not found, will be installed with requirements"
    fi
    
    # Check for other useful tools
    KALI_TOOLS=("metasploit-framework" "nmap" "wireshark" "tcpdump")
    
    for tool in "${KALI_TOOLS[@]}"; do
        if dpkg -l | grep -q $tool; then
            print_success "$tool is installed"
        else
            print_warning "$tool is not installed (optional)"
        fi
    done
}

# Check firewall and network configuration
check_network_config() {
    print_status "Checking network configuration..."
    
    # Check if ufw is active
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "Status: active"; then
            print_warning "UFW firewall is active. You may need to allow Docker ports."
        else
            print_success "UFW firewall is not active"
        fi
    fi
    
    # Check Docker network
    if docker network ls | grep -q "bridge"; then
        print_success "Docker bridge network is available"
    else
        print_warning "Docker bridge network not found"
    fi
}

# Check file permissions
check_permissions() {
    print_status "Checking file permissions..."
    
    # Check if user is in docker group
    if groups $USER | grep -q docker; then
        print_success "User is in docker group"
    else
        print_warning "User is not in docker group"
        print_status "Adding user to docker group..."
        sudo usermod -aG docker $USER
        print_warning "Please log out and log back in for changes to take effect"
    fi
    
    # Check script permissions
    if [ -f "lab-setup.sh" ]; then
        if [ ! -x "lab-setup.sh" ]; then
            print_status "Making lab-setup.sh executable..."
            chmod +x lab-setup.sh
        fi
        print_success "lab-setup.sh is executable"
    fi
}

# Main function
main() {
    print_header
    
    local exit_code=0
    
    # Run all checks
    check_kali_linux || exit_code=1
    check_system_requirements || exit_code=1
    check_docker || exit_code=1
    check_docker_compose || exit_code=1
    check_python || exit_code=1
    check_python_packages || exit_code=1
    check_network_tools || exit_code=1
    check_kali_tools || exit_code=1
    check_network_config || exit_code=1
    check_permissions || exit_code=1
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        print_success "All prerequisites are satisfied!"
        print_status "You can now run: ./lab-setup.sh"
    else
        print_error "Some prerequisites are missing or failed!"
        print_status "Please fix the issues above and run this script again."
    fi
    
    echo ""
    print_status "Next steps:"
    echo "1. Run: ./lab-setup.sh"
    echo "2. Wait for services to start"
    echo "3. Access the lab at the URLs shown"
    
    exit $exit_code
}

# Run main function
main "$@"
