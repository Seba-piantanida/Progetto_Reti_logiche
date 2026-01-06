# VHDL Serial Data Decoder & Router ⚡💾

**Logic Networks Final Project (2022-2023)**
**Politecnico di Milano** | **Prof. Gianluca Palermo**
**Final Grade:** 30/30 cum Laude 

---

A hardware component implemented in **VHDL** designed to interface with a RAM module. It deserializes an input bitstream to extract a memory address and an output channel ID, retrieves the data from memory, and routes it to the specific output port.

> **Note:** For further technical details and specifications, please refer to the full **project report/specification file** included in this repository.

## 📋 Project Overview

The component acts as a bridge between a serial input controller and a synchronous RAM. It operates on a single-bit input line to decode instructions of variable length and manages the memory handshaking protocols.

### Key Features
* **Serial Deserialization:** Reads a continuous stream of bits to reconstruct a 2-bit Output Port ID and a Variable-Length Memory Address (up to 16 bits).
* **Memory Interface:** Manages `Enable` (EN) and `Write Enable` (WE) signals to fetch data from an external RAM.
* **Data Routing:** Directs the fetched 8-bit word to one of the four output channels (`o_z0` to `o_z3`).
* **FSM Architecture:** Implemented as a Finite State Machine to ensure strict synchronization and handling of corner cases (e.g., asynchronous resets).

## ⚙️ Architecture: Finite State Machine

The design logic is encapsulated in a single FSM to optimize resource usage and timing:

* **S0-S1 (Idle/Start):** Waits for the `START` signal to begin the transaction.
* **S2-S3 (Decoding):** Reads the output port bits and shifts the incoming address bits into a temporary register. Handles variable address lengths dynamically.
* **S4-S5 (Memory Access):** Asserts the memory address and waits for the RAM response.
* **S6-S7 (Routing & Output):** Latches the data to the correct output vector and asserts the `DONE` signal.
* **S8 (Reset):** Cleans internal registers to prepare for the next stream.

## 🔌 Component Interface

| Signal | Direction | Description |
| :--- | :--- | :--- |
| `i_clk` | IN | System Clock. |
| `i_rst` | IN | Asynchronous Reset. |
| `i_start` | IN | Start of transmission signal. |
| `i_w` | IN | **Serial Input Bitstream** (Port ID + Address). |
| `o_z0`...`o_z3` | OUT | Four 8-bit output data channels. |
| `o_done` | OUT | Signal indicating valid data on output. |
| `o_mem_addr` | OUT | Address bus to RAM (16-bit). |
| `i_mem_data` | IN | Data bus from RAM (8-bit). |

## 🧪 Testing and Validation

The component underwent rigorous testing to ensure reliability under stress and corner cases.

### Automated Testing (Python)
To validate the logic beyond standard manual cases, a **Python script** was developed to generate:
* **1000+ Random Test Cases:** Covering variable address lengths and data patterns.
* **VHDL Testbench Generation:** Automatically creating `.vhd` simulation files compatible with Vivado.

### Corner Cases Covered
* **Minimal Address Length:** Correct handling of 0-bit addresses (Base Address).
* **Mid-Stream Reset:** Ability to recover correctly if `i_rst` is triggered during data transmission.

### Synthesis Results
* **Status:** Passed Behavioral, Post-Synthesis Functional, and **Post-Synthesis Timing** simulations.
* **Optimization:** The final design reduced state redundancy compared to the initial multi-component approach, solving synchronization issues.

## 🛠️ Tools Used
* **Language:** VHDL
* **IDE:** Xilinx Vivado
* **Simulation:** Vivado Simulator
* **Scripting:** Python (for Testbench generation)
