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
use ieee.numeric_std.all;

-- using real number functions for generating random numbers, will not affect synthesis
use ieee.math_real.uniform;
use ieee.math_real.floor;

use work.Types.all; -- from bitonic_sort.vhd

entity bitonic_sort_tb is
end bitonic_sort_tb;

architecture behavior of bitonic_sort_tb is
    constant N : positive := scale_max;
    -- Component declaration for the Unit Under Test (UUT)
    component bitonic_sort is
        generic (
            N : positive := scale_max  -- Number of items to sort
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

    -- Clock period for the test bench, 2.5ns is roughly 400MHz (Artix 7 clock speed is 450MHz or a 2.2222ns repeating clock period)
    constant clk_period : time := 2.5 ns;

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
    stim_proc: process is 
        variable seed1 : positive := 1;
        variable seed2 : positive := 1;
        variable x : real;
        variable y : integer;
        variable is_sorted : boolean := true; 
    begin
        -- random integer generation from https://stackoverflow.com/a/53353673/7537973
        for i in 0 to N-1 loop
            uniform(seed1, seed2, x);
            y := integer(floor((x-0.5)*2.0**31));
            data(i) <= y;
        end loop;

        wait until done = '1';

        -- Check the outputs
        for i in 0 to N-2 loop
            if(sorted(i) < sorted(i+1)) then
                is_sorted := false;
            end if;
        end loop;
        assert is_sorted
            report "Incorrect sorting!"
            severity error;
        report "Correct sorting!";
        wait;
    end process;
end;

