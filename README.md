

\### 📄 4. 포트폴리오용 `README.md` 작성



터미널에서 `notepad README.md` 실행 후 아래 내용을 붙여넣고 저장합니다:



```markdown

<div align="center">



\# 📡 FPGA Serial Communication Protocol IP Suite (SPI \& I2C)



!\[Language](https://img.shields.io/badge/Language-SystemVerilog%20%2F%20Verilog-blue?style=for-the-badge\&logo=SystemVerilog)

!\[Protocol](https://img.shields.io/badge/Protocol-SPI%20%26%20I2C-orange?style=for-the-badge)

!\[EDA](https://img.shields.io/badge/EDA-Vivado%20%2F%20ModelSim-red?style=for-the-badge)

!\[License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)



\*\*FPGA 기반 온칩/오프칩 통신을 위한 SPI 및 I2C 직렬 통신 프로토콜 IP 코어 설계 및 검증 라이브러리\*\*



</div>



\---



\## ✨ Supported Communication Protocols



| Protocol | Mode / Feature | Clock / Speed | Control Flags |

| :--- | :--- | :--- | :--- |

| ⚡ \*\*SPI (Serial Peripheral Interface)\*\* | Master/Slave, Full-Duplex | CPOL / CPHA (Mode 0\~3) | SCLK, MOSI, MISO, CS\_N |

| 🚌 \*\*I2C (Inter-Integrated Circuit)\*\* | Master/Slave, Multi-Byte | Standard (100kHz) / Fast (400kHz) | SCL, SDA (Open-Drain, ACK/NACK) |



\---



\## 📊 System Architecture \& Protocol Overview



```mermaid

graph TD

&#x20;   subgraph SPI\_Module \["⚡ SPI Communication Protocol"]

&#x20;       SPI\_M\["👑 SPI Master"] <-->|SCLK / MOSI / MISO / CS\_N| SPI\_S\["🛡️ SPI Slave"]

&#x20;   end



&#x20;   subgraph I2C\_Module \["🚌 I2C Communication Protocol"]

&#x20;       I2C\_M\["👑 I2C Master"] <-->|SCL / SDA (Open-Drain Bus)| I2C\_S\["🛡️ I2C Slave"]

&#x20;   end

```



\---



\## 📂 Directory Structure



```text

📦 Communication

&#x20;┣ 📂 rtl

&#x20;┃ ┣ 📂 spi             # SPI Master/Slave RTL Source Files

&#x20;┃ ┗ 📂 i2c             # I2C Master/Slave RTL Source Files

&#x20;┣ 📂 tb

&#x20;┃ ┣ 📂 spi             # SPI Testbench Verification Files

&#x20;┃ ┗ 📂 i2c             # I2C Testbench Verification Files

&#x20;┣ 📂 docs              # Protocol Timing Diagrams \& Documentation

&#x20;┗ 📜 .gitignore        # EDA Garbage File Filters

```



\---



\## 🛠️ Simulation \& Verification Guide



\### 1️⃣ SPI Simulation

```bash

vlog -sv rtl/spi/\*.sv tb/spi/\*.sv

vsim -voptargs="+acc" tb\_spi

```



\### 2️⃣ I2C Simulation

```bash

vlog -sv rtl/i2c/\*.sv tb/i2c/\*.sv

vsim -voptargs="+acc" tb\_i2c

```



\---



\## 👨‍💻 Author



\- \*\*GitHub\*\*: \[@ethan000106](https://github.com/ethan000106)

\- \*\*License\*\*: MIT License

```



\---



