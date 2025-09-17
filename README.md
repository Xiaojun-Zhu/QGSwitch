# QGSwitch

Source code for the following paper:

**Anrun Wang, Xiaojun Zhu, Yuben Qu, Chao Dong. "Quick Gateway Switching for Reliable Data Collection in Multi-Gateway UAV Networks with Gateway Failures,"  IEEE Transactions on Vehicular Technology. https://doi.org/10.1109/TVT.2025.3609048**



If you find the software helpful, please cite the paper.

## Introduction

QGSwitch is a Quick Gateway Switching approach for UAV networks with multiple gateways. It addresses the problem of slow gateway switching caused by passive failure detection and ARP delays in existing routing protocols such as Batman-adv.  

## Hardware Requirements
A gateway is a node with
- a WiFi module that can work in IBSS mode, and
- a 4G/5G module that can connect to the Internet via cellular service


A non-gateway node is a node with
- a WiFi module that can work in IBSS mode.

## Project Structure

The current software has been tested on Raspberry Pi computers running Raspberry Pi OS with 5.10 kernel.

```
QGSwitch/
├── Gateway/                  # Gateway node configuration files
│   ├── start-batman-adv_GW.sh
│   └── start-batman-adv_GW.service
├── Non_gateway/              # Non-gateway node configuration files
│   ├── failure_detection.py
│   ├── start-batman-adv_Non_GW.sh
│   └── start-batman-adv_Non_GW.service
└── README.md                 # You are here!
```

## Gateway


The Gateway folder contains configuration files for UAVs that act as gateways, providing Internet connectivity to the UAV network.

### `start-batman-adv_GW.sh`

**Purpose**: Gateway UAV initialization script

**How to Run on Gateway UAVs**:

```bash
cd Gateway/
chmod +x start-batman-adv_GW.sh
sudo ./start-batman-adv_GW.sh
```

### `start-batman-adv_GW.service`

**Purpose**: Systemd service file for automatic gateway startup

**Usage**:

```bash
sudo cp Gateway/start-batman-adv_GW.service /etc/systemd/system/
sudo systemctl enable start-batman-adv_GW.service
sudo systemctl start start-batman-adv_GW.service
```

## Non-gateway

The Non_gateway folder contains configuration files for non-gateway UAVs that connect to gateway nodes for internet access and data transmission.

### `failure_detection.py`

**Purpose**: Intelligent gateway failure detection and switching mechanism

**How to Run on Non-Gateway Nodes**:

```bash
cd Non_gateway/

# Basic usage
python3 failure_detection.py

# Custom configuration
python3 failure_detection.py --gateway 192.168.199.1 --interface bat0 --fail-threshold 3
```

### `start-batman-adv_Non_GW.sh`

**Purpose**: Non-gateway UAV initialization script

**Usage**:

```bash
cd Non_gateway/
chmod +x start-batman-adv_Non_GW.sh
sudo ./start-batman-adv_Non_GW.sh
```

### `start-batman-adv_Non_GW.service`

**Purpose**: Systemd service for automatic non-gateway node startup

**Usage**:

```bash
sudo cp Non_gateway/start-batman-adv_Non_GW.service /etc/systemd/system/
sudo systemctl enable start-batman-adv_Non_GW.service
sudo systemctl start start-batman-adv_Non_GW.service
```
