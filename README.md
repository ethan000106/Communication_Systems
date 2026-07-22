```markdown
<div align="center">

# 📡 FPGA Serial Communication Protocol IP Suite (SPI & I2C)

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue?style=for-the-badge&logo=SystemVerilog)
![Protocols](https://img.shields.io/badge/Protocols-SPI%20%26%20I2C-orange?style=for-the-badge)
![EDA](https://img.shields.io/badge/EDA-AMD_Vivado-red?style=for-the-badge&logo=Xilinx)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**FPGA 기반 온칩/오프칩 시스템 구현을 위한 SPI 및 I2C 직렬 통신 프로토콜 IP 코어 종합 라이브러리**

</div>

---

## ✨ Supported Communication IPs

| Protocol | RTL Modules | Features & Specifications |
| :--- | :--- | :--- |
| ⚡ **SPI Protocol** | `spi_master.sv`, `spi_slave.sv`, `spi_top.sv` | Full-Duplex, Mode 0~3 (CPOL/CPHA), SCLK/MOSI/MISO/CS_N Control |
| 🚌 **I2C Protocol** | `i2c_master.sv`, `i2c_slave.sv`, `i2c_demo_top.sv` | Open-Drain SDA/SCL 양방향 버스 제어, 7-bit Address Matching, ACK/NACK |

---

## 📊 System Architecture

```mermaid
graph TD
    %% Styles
    classDef spi fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef i2c fill:#fff3e0,stroke:#e65100,stroke-width:2px;

    subgraph SPI_Suite ["⚡ SPI Communication Suite"]
        SPI_M["👑 SPI Master<br/>(spi_master.sv)"]:::spi
        SPI_S["🛡️ SPI Slave<br/>(spi_slave.sv)"]:::spi
        SPI_M <-->|SCLK / MOSI / MISO / CS_N| SPI_S
    end

    subgraph I2C_Suite ["🚌 I2C Communication Suite"]
        I2C_M["👑 I2C Master<br/>(i2c_master.sv)"]:::i2c
        I2C_S["🛡️ I2C Slave<br/>(i2c_slave.sv)"]:::i2c
        I2C_M <-->|SCL / SDA (Open-Drain)| I2C_S
    end
```

---

## 📂 Directory Structure

```text
📦 Communication
 ┣ 📂 rtl
 ┃ ┣ 📂 spi/            # SPI Master/Slave & Top RTL Source Files
 ┃ ┗ 📂 i2c/            # I2C Master/Slave & Top RTL Source Files
 ┣ 📂 tb
 ┃ ┣ 📂 spi/            # SPI Testbench Simulation Files
 ┃ ┗ 📂 i2c/            # I2C Testbench Simulation Files
 ┣ 📂 docs/             # Protocol Timing Diagrams & Docs
 ┗ 📜 .gitignore        # EDA Garbage File Filter
```

---

## 🛠️ Simulation Guide (AMD Vivado XSIM)

### 1️⃣ SPI Simulation
```bash
xvlog -sv rtl/spi/*.sv tb/spi/*.sv
xelab tb_spi_master -s tb_spi_sim -debug typical
xsim tb_spi_sim -gui
```

### 2️⃣ I2C Simulation
```bash
xvlog -sv rtl/i2c/*.sv tb/i2c/*.sv
xelab tb_i2c_master -s tb_i2c_sim -debug typical
xsim tb_i2c_sim -gui
```

---

## 👨‍💻 Author

- **GitHub**: [@ethan000106](https://github.com/ethan000106)
- **License**: MIT License
```

