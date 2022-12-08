----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/03/2022 05:50:25 PM
-- Design Name: 
-- Module Name: test_bench_merge - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.Types.all; -- from bitonic_sort.vhd

entity bitonic_sort_tb is
end bitonic_sort_tb;

architecture behavior of bitonic_sort_tb is
    constant N : positive := 16;
    -- Component declaration for the Unit Under Test (UUT)
    component bitonic_sort is
        generic (
            N : positive := 16  -- Number of items to sort
        );
        port (
            clk     : in  std_logic;
            data    : in  input_array(0 to N-1);
            sorted  : out input_array(0 to N-1);
            done    : out std_logic
        );
    end component;

    -- Inputs
    signal clk : std_logic := '0';
    signal data : input_array(0 to N-1) := (others => 0);

    -- Outputs
    signal sorted : input_array(0 to N-1);
    signal done : std_logic;

    -- Clock period for the test bench
    constant clk_period : time := 1 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: bitonic_sort
        generic map (
            N => N  -- Number of items to sort
        )
        port map (
            clk => clk,
            done => done,
            data => data,
            sorted => sorted
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply input stimuli
        data <= (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);

        wait until done = '1';

        -- Check the outputs
        assert sorted = (16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
            report "Incorrect sorting!"
            severity error;

        wait;
    end process;
end;

