import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def basic_test(dut):
    # Start zegara
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Inicjalizacja
    dut.rstn.value = 0
    dut.valid.value = 0
    
    # Reset
    await RisingEdge(dut.clk)
    dut.rstn.value = 1
    
    # Testowanie wejść
    dut.data_in.value = 0xAA
    dut.valid.value = 1
    await RisingEdge(dut.clk)
    
    # Sprawdzenie wyjścia
    assert dut.ready.value == 1, "DUT nie jest gotowy!"