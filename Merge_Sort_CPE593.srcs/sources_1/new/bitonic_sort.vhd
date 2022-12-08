----------------------------------------------------------------------------------
-- Company: Stevens CPE 593 Group Hardware Accelerated Sorting
-- Engineer: Bradleu O'Cpnnell, Omkar Patol, Nirmohi Patel
-- 
-- Create Date: 12/05/2022 11:05:15 PM
-- Design Name: 
-- Module Name: bitonic_sort - Behavioral
-- Project Name: Hardware Accelerated Sorting
-- Target Devices: Artix 7
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

Package Types is 
    type input_array is array (natural range <>) of integer; --integer array with unconstrained range, can be constrained later
End Types;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.ALL;

use work.Types.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bitonic_sort is
    generic (
        N       : positive := 16  -- Number of items to sort
    );
    port (
        clk     : in  std_logic;
        data    : in  input_array(0 to N-1);
        sorted  : out input_array(0 to N-1);
        done    : out std_logic := '0'
    );
end bitonic_sort;

architecture Behavioral of bitonic_sort is
    signal items : input_array(0 to N-1);
    type state_type is (INIT, SORT);
    signal state, next_state : state_type;

    signal dir : std_logic;
    signal size : positive;
    
    signal sort_count : natural := 0;
    signal sub_sort_count : natural  := 0;
    constant scale : positive := 4; -- log2(N)
    signal count : integer := 0;
    
begin
    process (clk)
        -- check if array is in correct order, index_1 must be less than index_2
        -- increasing is '1' if index_1 should be less than index_2 and '0' if index_1 should be greater than index_2
        procedure check_and_swap(index_1 : natural; index_2 : natural; increasing : boolean) is
        begin
            if increasing then --check if increasing, swap if index_1 > index_2
                if items(index_1) > items(index_2) then -- if the element in the lower position is greater, swap (increasing sequence)
                    items(index_1) <= items(index_2);
                    items(index_2) <= items(index_1);
                end if;
            else --check if increasing, swap if index_1 < index_2
                if items(index_1) < items(index_2) then -- if the element in the lower position is lower, swap (decreasing sequence)
                    items(index_1) <= items(index_2);
                    items(index_2) <= items(index_1);
                end if;
            end if;
        end check_and_swap;
    begin
        if rising_edge(clk) then
            state <= next_state;
            case state is
                when INIT =>
                    items <= data;
                    dir <= '1';
                    size <= N;
                    next_state <= SORT;
                when SORT =>
                    case sort_count is
                        when 0 =>
                            case sub_sort_count is
                                when 0 =>
                                    for i in 0 to N/2-1 loop
                                        check_and_swap(2*i, 2*i+1, (i mod 2) = 0); -- increasing if even index
                                    end loop;
                                    sort_count <= sort_count + 1;
                                    sub_sort_count <= 0;
                                when others =>
                            end case;
                        when 1 =>
                            case sub_sort_count is
                                when 0 =>
                                    for i in 0 to N/4-1 loop
                                        check_and_swap(4*i, 4*i+2, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(4*i+1, 4*i+3, (i mod 2) = 0); -- increasing if even index
                                    end loop;
                                    sub_sort_count <= sub_sort_count + 1; 
                                when 1 =>
                                    for i in 0 to N/4-1 loop
                                        check_and_swap(4*i, 4*i+1, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(4*i+2, 4*i+3, (i mod 2) = 0); -- increasing if even index
                                    end loop;
                                    sort_count <= sort_count + 1;
                                    sub_sort_count <= 0;                                    
                                when others => -- do nothing
                            end case;    
                            sub_sort_count <= sub_sort_count + 1;
                        when 2 =>
                            case sub_sort_count is
                                when 0 =>
                                    for i in 0 to N/8-1 loop
                                        check_and_swap(8*i, 8*i+4, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+1, 8*i+5, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+2, 8*i+6, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+3, 8*i+7, (i mod 2) = 0); -- increasing if even index
                                    end loop;
                                    sub_sort_count <= sub_sort_count + 1; 
                                when 1 =>
                                    for i in 0 to N/8-1 loop
                                        check_and_swap(8*i, 8*i+2, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+1, 8*i+3, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+4, 8*i+6, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+5, 8*i+7, (i mod 2) = 0); -- increasing if even index
                                    end loop;
                                    sub_sort_count <= sub_sort_count + 1; 
                                when 2 =>
                                    for i in 0 to N/8-1 loop
                                        check_and_swap(8*i, 8*i+1, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+2, 8*i+3, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+4, 8*i+5, (i mod 2) = 0); -- increasing if even index
                                        check_and_swap(8*i+6, 8*i+7, (i mod 2) = 0); -- increasing if even index
                                    end loop;
                                    sort_count <= sort_count + 1;
                                    sub_sort_count <= 0;
                                when others => -- do nothing
                            end case;   
                        when 3 =>
                            case sub_sort_count is
                                when 0 =>
                                    for i in 0 to N/2-1 loop
                                        check_and_swap(i, i+8, false); -- increasing if even index
                                    end loop;
                                    sub_sort_count <= sub_sort_count + 1; 
                                when 1 => 
                                    for i in 0 to N/16-1 loop
                                        check_and_swap(16*i, 16*i+4, false); -- increasing if even index
                                        check_and_swap(16*i+1, 16*i+5, false); -- increasing if even index
                                        check_and_swap(16*i+2, 16*i+6, false); -- increasing if even index
                                        check_and_swap(16*i+3, 16*i+7, false); -- increasing if even index
                                        check_and_swap(16*i+8, 16*i+12, false); -- increasing if even index
                                        check_and_swap(16*i+9, 16*i+13, false); -- increasing if even index
                                        check_and_swap(16*i+10, 16*i+14, false); -- increasing if even index
                                        check_and_swap(16*i+11, 16*i+15, false); -- increasing if even index
                                    end loop;
                                    sub_sort_count <= sub_sort_count + 1; 
                                when 2 =>
                                    for i in 0 to N/16-1 loop -- blue/green boxes
                                        for j in i to N/4-1 loop -- red boxes
                                            for k in j*4 to j*4+(N/8-1) loop -- line low points
                                                check_and_swap(k, k+2, false); -- increasing if even index
                                            end loop;
                                        end loop;
                                    end loop;
                                    sub_sort_count <= sub_sort_count + 1; 
                                when 3 =>
                                    for i in 0 to N/16-1 loop --blue/green boxes
                                        for j in i to N/2-1 loop --red boxes
                                            for k in j*2 to j*2+(N/16-1) loop --line low points
                                                check_and_swap(k, k+1, false);
                                            end loop;
                                        end loop;
                                    end loop; 
                                    sort_count <= sort_count + 1;
                                    sub_sort_count <= 0;   
                                    done <= '1';
                                when others => -- do nothing     
                                    done <= '1';                   
                            end case; 
                        when others => -- do nothing
                    end case;
            end case;
        end if;
    end process;

    sorted <= items;
end architecture;
