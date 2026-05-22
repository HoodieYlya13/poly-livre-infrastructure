#!/usr/bin/env bash

# ==============================================================================
# Poly Livre - Full Stack Project Setup Script
# Developed by: HoodieYlya13, Akaby, & Algebrino
# ==============================================================================

set -euo pipefail

BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

log_info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} ${BOLD}$1${RESET}"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

echo -e "${CYAN}"
echo -e "  _____       _         _      _                  "
echo -e " |  __ \     | |       | |    (_)                 "
echo -e " | |__) |___ | |_   _  | |     ___   ___ __ ___   "
echo -e " |  ___// _ \| | | | | | |    | \ \ / / '__/ _ \  "
echo -e " | |   | (_) | | |_| | | |____| |\ V /| | |  __/  "
echo -e " |_|    \___/|_|\__, | |______|_| \_/ |_|  \___|  "
echo -e "                 __/ |                            "
echo -e "                |___/                             "
echo -e "${RESET}"
echo -e "${BOLD}====================================================================${RESET}"
echo -e " ${BOLD}Project:${RESET} Poly Livre - Full Stack Collaborative Platform"
echo -e " ${BOLD}Authors:${RESET} ${CYAN}HoodieYlya13${RESET} | ${CYAN}Akaby${RESET} | ${CYAN}Algebrino${RESET}"
echo -e "${BOLD}====================================================================${RESET}"
echo ""

log_info "Verifying development environment prerequisites..."

check_cmd() {
    if ! command -v "$1" &> /dev/null; then
        log_warn "Command '$1' was not found. Please install it for full functionality."
        return 1
    else
        log_info "Found '$1': $($1 --version | head -n 1)"
        return 0
    fi
}

check_cmd "git" || true
check_cmd "docker" || true
check_cmd "node" || true
check_cmd "npm" || true

log_info "Initializing and updating git submodules recursively..."
if git submodule update --init --recursive; then
    log_success "Submodules initialized successfully!"
else
    log_error "Failed to update submodules. Please check your git configuration."
    exit 1
fi

if [ -d "frontend" ]; then
    log_info "Installing npm dependencies in /frontend..."
    if cd frontend && npm install && cd ..; then
        log_success "Frontend packages installed successfully!"
    else
        log_error "Frontend 'npm install' failed."
        exit 1
    fi
else
    log_warn "/frontend directory was not found. Skipping npm installs."
fi

echo ""
echo -e "${BOLD}====================================================================${RESET}"
log_success "Poly Livre setup is now complete!"
log_success "You can run 'make all' or 'make dev' to start the full stack application."
echo -e "${BOLD}====================================================================${RESET}"
