#!/bin/bash

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Update package list
print_status "Updating package list..."
sudo apt update

# Install Docker
print_status "Checking Docker installation..."
if command_exists docker; then
    print_warning "Docker is already installed"
    docker --version
else
    print_status "Installing Docker..."
    
    # Install required packages
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package list
    sudo apt update
    
    # Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    print_success "Docker installed successfully"
fi

# Install Docker Compose
print_status "Checking Docker Compose installation..."
if command_exists docker-compose; then
    print_warning "Docker Compose is already installed"
    docker-compose --version
else
    print_status "Installing Docker Compose..."
    
    # Get latest version
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    
    # Download and install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Make it executable
    sudo chmod +x /usr/local/bin/docker-compose
    
    print_success "Docker Compose installed successfully"
fi

# Install Python 3.9+
print_status "Checking Python installation..."
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 9 ]; then
        print_warning "Python $PYTHON_VERSION is already installed (meets requirement 3.9+)"
        python3 --version
    else
        print_status "Installing Python 3.9+..."
        sudo apt install -y python3.9 python3.9-venv python3.9-dev python3-pip
        print_success "Python 3.9+ installed successfully"
    fi
else
    print_status "Installing Python 3.9+..."
    sudo apt install -y python3.9 python3.9-venv python3.9-dev python3-pip
    print_success "Python 3.9+ installed successfully"
fi

# Install pip if not present
if ! command_exists pip3; then
    print_status "Installing pip..."
    sudo apt install -y python3-pip
fi

# Install Django
print_status "Checking Django installation..."
if python3 -c "import django" 2>/dev/null; then
    DJANGO_VERSION=$(python3 -c "import django; print(django.get_version())")
    print_warning "Django $DJANGO_VERSION is already installed"
else
    print_status "Installing Django..."
    pip3 install django
    print_success "Django installed successfully"
fi

# Final verification
print_status "Verifying installations..."

echo ""
echo "=== INSTALLATION SUMMARY ==="
echo ""

if command_exists docker; then
    print_success "Docker: $(docker --version)"
else
    print_error "Docker: Not installed"
fi

if command_exists docker-compose; then
    print_success "Docker Compose: $(docker-compose --version)"
else
    print_error "Docker Compose: Not installed"
fi

if command_exists python3; then
    print_success "Python: $(python3 --version)"
else
    print_error "Python: Not installed"
fi

if python3 -c "import django" 2>/dev/null; then
    DJANGO_VERSION=$(python3 -c "import django; print(django.get_version())")
    print_success "Django: $DJANGO_VERSION"
else
    print_error "Django: Not installed"
fi

echo ""
print_success "Installation completed!"
print_warning "Note: You may need to log out and log back in for Docker group changes to take effect."