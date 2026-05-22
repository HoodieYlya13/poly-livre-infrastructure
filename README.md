# 📚 Poly Livre - Full Stack Collaborative Platform

Welcome to **Poly Livre**, a comprehensive full-stack web application designed for interactive book sharing and collaborative libraries. This project was developed as a collaborative school full-stack engineering project by:

[![Author - HoodieYlya13](https://img.shields.io/badge/Developer-HoodieYlya13-cyan?style=for-the-badge&logo=github)](https://github.com/HoodieYlya13)
[![Author - Akaby](https://img.shields.io/badge/Developer-Akaby-blue?style=for-the-badge&logo=github)](https://github.com/Akaby)
[![Author - Algebrino](https://img.shields.io/badge/Developer-Algebrino-green?style=for-the-badge&logo=github)](https://github.com/Algebrino)

---

## 🏗️ Architecture Overview

The system consists of two primary components orchestrated inside a unified development environment:

```
                  ┌────────────────────────────────────────┐
                  │          Next.js Frontend              │
                  │          (localhost:3000)              │
                  └──────────────────┬─────────────────────┘
                                     │ (HTTP / API Calls)
                                     ▼
                  ┌────────────────────────────────────────┐
                  │          Spring Boot Backend           │
                  │          (localhost:8080)              │
                  └──────────┬───────────────────┬─────────┘
                             │                   │
                             ▼                   ▼
                  ┌────────────────────┐ ┌───────────────┐
                  │ PostgreSQL Database│ │ Mailpit Server│
                  │  (localhost:5432)  │ │(localhost:8025)
                  └────────────────────┘ └───────────────┘
```

| Service | Technology | Internal Port | External Port | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Frontend** | Next.js 16 (App Router, TS, Tailwind) | `3000` | `3000` | User Web Interface |
| **Backend** | Spring Boot 3.5 (Java 21, JPA) | `8080` | `8080` | Business API & Security |
| **Database** | PostgreSQL 16 (Alpine) | `5432` | `5432` | Data Storage |
| **Mail Server** | Mailpit | `1025` (SMTP) | `8025` (UI) | Local Email Catcher / Testing |

---

## ⚡ Quick Start

### 1. Prerequisites
Ensure you have the following installed on your host system:
* **Docker & Docker Compose** (Required)
* **Node.js 20+ & npm 10+** (For local frontend development)
* **Git**

---

### 2. Initial Setup
Run the unified workspace initializer to pull the submodule repositories and install all dependencies:
```bash
make init
```
> [!NOTE]
> This command updates all Git submodules recursively and runs `npm install` in the frontend directory automatically.

---

### 3. Start Development Mode
To boot up the entire development stack:
```bash
make dev
```
> [!TIP]
> This command spins up PostgreSQL, Mailpit, and the Spring Boot backend inside Docker containers, and concurrently starts your Next.js local frontend development server with full hot-reloading!

---

### 4. Other Commands

| Command | Action |
| :--- | :--- |
| `make frontend` | Starts the Next.js frontend dev server locally |
| `make backend` | Starts the backend, database, and mail server in Docker |
| `make stop` | Tears down all running Docker containers |
| `make logs` | Tails live log output from all backend containers |
| `make status` | Displays active container stats and port interfaces |
| `make clean` | Purges docker volumes, maven targets, and local node modules |

---

## 🛠️ Individual Component Manuals

For more details regarding backend API specs, custom security tokens, next-intl internationalization, or client design patterns, please check:
* 🖥️ [Frontend Submodule Documentation](./frontend/README.md)
* ⚙️ [Backend Submodule Documentation](./backend/README.md)

---

Developed with ❤️ for academic excellence.
