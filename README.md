# Sports Odds Intelligence Platform

A real-time sports betting market aggregator and arbitrage detection engine.

This project collects live odds data from multiple bookmakers, normalizes markets across providers, and identifies pricing inefficiencies (including near-arbitrage opportunities).

---

## 🚀 Overview

The system consists of:

- Unofficial API integrations for:
  - Fortuna
  - Chance.sk
- Odds normalization layer
- Market matching engine
- Arbitrage detection algorithm
- Web interface for live monitoring

The platform scans cross-bookmaker markets and identifies spreads below a configurable arbitrage threshold (e.g. <5%).

---

## 🧠 Core Features

- Real-time odds ingestion
- Market canonicalization (team names, kickoff rounding, etc.)
- Cross-provider event matching
- Spread / implied probability calculations
- Arbitrage detection engine
- Dockerized deployment
- Web UI (React frontend)
- FastAPI backend

---

## 🏗 Architecture

Frontend (Web UI)
    ↓
API Layer (FastAPI)
    ↓
Normalization Engine
    ↓
Arbitrage Detection Logic
    ↓
Unofficial Bookmaker APIs

---

## ⚙️ Tech Stack

- Python (FastAPI)
- Docker / Docker Compose
- Uvicorn
- React (frontend)
- Custom odds normalization logic

---

## 📊 Arbitrage Logic

For two-outcome markets:

If:

1 / odds_A + 1 / odds_B < 1

An arbitrage opportunity exists.

The engine also detects near-arbitrage spreads (<5%) for monitoring market inefficiencies.

---

## 🐳 Running Locally

```bash
docker compose up -d
Frontend:
http://localhost:3000

API:
http://localhost:8000


---

## ⚠️ Disclaimer

This project is for educational and research purposes only.
It demonstrates data normalization, cross-source reconciliation, and real-time arbitrage detection algorithms.

---

## 📌 Roadmap

- Add more bookmakers
- Historical data storage
- Statistical edge analysis
- Automated stake optimization
- Alerting system
- ML-based pricing anomaly detection

---

## 🎯 Purpose

This project explores:

- Market efficiency in sports betting
- Real-time data reconciliation
- Infrastructure automation
- Arbitrage mathematics
- Applied probability systems
