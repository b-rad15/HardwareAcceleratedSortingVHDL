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
    constant scale_max : positive := 32;
End Types;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

use work.Types.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bitonic_sort is
    generic (
        N       : positive := scale_max  -- Number of items to sort
    );
    port (
        clk     : in  std_logic;
        data    : in  input_array(0 to N-1);
        sorted  : out input_array(0 to N-1);
        done    : out std_logic := '0'
    );
end bitonic_sort;

architecture Behavioral of bitonic_sort is
    -- log base 2 lookup table
   function log_base2(n : positive) return natural is
   begin
        case n is
            when 1 => return 0;
            when 2 => return 1;
            when 4 => return 2;
            when 8 => return 3;
            when 16 => return 4;
            when 32 => return 5;
            when 64 => return 6;
            when 128 => return 7;
            when 256 => return 8;
            when 512 => return 9;
            when 1024 => return 10;
            when 2048 => return 11;
            when 4096 => return 12;
            when 8192 => return 13;
            when 16384 => return 14;
            when others => return 0;
        end case;
    end log_base2;
    signal items : input_array(0 to N-1);
    type state_type is (INIT, SORT, FINISHED);
    signal state, next_state : state_type;

    signal dir : std_logic;
    signal size : positive;
    
    signal sort_count : positive := 1;
    signal sub_sort_count : positive  := 1;
    constant scale : positive := log_base2(N); -- log2(N)
    signal count : integer := 0;
    
    -- TODO: Investigate faster alternative using left shifts
    function power_of_2(power : natural) return positive is
    variable result : positive;
    begin
        return  2**power;
   end power_of_2;
begin

    process (clk)
        
        variable sort_exp : positive;
        variable sort_minus1_exp : positive;
        variable sub_sort_exp : positive;
        variable sub_sort_minus1_exp : positive;
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
        
        procedure bitonic_swap_procedure(sort_count : positive; sub_sort_count : positive) is
            variable sort_exp           : positive := power_of_2(sort_count);
            variable sort_minus1_exp    : positive := sort_exp/2;
            variable sub_sort_exp       : positive := power_of_2(sub_sort_count);
            variable sub_sort_minus1_exp: positive := sub_sort_exp/2;
        begin 
            for i in 0 to N/sort_exp-1 loop --blue/green boxes
                for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
                    for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
                        check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
                    end loop;
                end loop;
            end loop;
        end bitonic_swap_procedure;
           
        
    begin
        if rising_edge(clk) then
            sort_exp := power_of_2(sort_count);
            sort_minus1_exp := sort_exp/2;
            sub_sort_exp := power_of_2(sub_sort_count);
            sub_sort_minus1_exp := sub_sort_exp/2;
            state <= next_state;
            case state is
                when INIT =>
                    items <= data;
                    dir <= '1';
                    size <= N;
                    next_state <= SORT;
                when SORT =>
                    case sort_count is
                        when 1 =>
                            case sub_sort_count is
                                when 1 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when others =>
                            end case;
                        when 2 =>
                            case sub_sort_count is
                                when 1 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 2 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when others =>
                            end case;
                        when 3 =>
                            case sub_sort_count is
                                when 1 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 2 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 3 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when others =>
                            end case;
                        when 4 =>
                            case sub_sort_count is
                                when 1 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 2 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 3 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 4 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when others =>
                            end case;
                        when 5 =>
                            case sub_sort_count is
                                when 1 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 2 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 3 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 4 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when 5 =>
                                    bitonic_swap_procedure(sort_count, sub_sort_count);
                                when others =>
                            end case;
                        when others =>
                    end case;
--                    bitonic_swap_procedure(sort_count, sub_sort_count);
                    if sub_sort_count = 1 then
                        sub_sort_count <= sort_count + 1;
                        sort_count <= sort_count + 1;
                        if sort_count = scale then
                            next_state <= FINISHED;
                        end if;
                    else
                        sub_sort_count <= sub_sort_count - 1;
                    end if;
                    --Code intentionally commented out, synthesis fails and this may be the key to fixing it
--                    case sort_count is
--                        when 1 =>
--                            case sub_sort_count is
--                                when 1 =>
----                                    for i in 0 to N/(sort_exp)-1 loop
----                                        for j in 0 to power_of_2(sort_count-1)-1 loop -- 0
----                                            check_and_swap(2*sort_count*i+j, 2*sort_count*i+sub_sort_minus1_exp+j, (i mod 2) = 0); -- increasing if even index
----                                        end loop;
----                                    end loop;
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
--                                    sub_sort_count <= sort_count + 1;
--                                    sort_count <= sort_count + 1;
--                                when others =>
--                            end case;
--                        when 2 =>
--                            case sub_sort_count is
--                                when 2 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/(sort_exp)-1 loop
----                                        for j in 0 to sort_minus1_exp-1 loop -- 0 and 1
----                                            check_and_swap(2*sort_count*i+j, 2*sort_count*i+j+sub_sort_minus1_exp, (i mod 2) = 0); -- increasing if even index
----                                        end loop;
----                                    end loop;
--                                    sub_sort_count <= sub_sort_count - 1; 
--                                when 1 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/(sort_exp)-1 loop
----                                        for j in 0 to sort_minus1_exp-1 loop -- 0 and 1
----                                            check_and_swap(2*sort_count*i+j, 2*sort_count*i+sub_sort_minus1_exp+j, (i mod 2) = 0); -- increasing if even index
----                                        end loop;
----                                    end loop;
--                                    sub_sort_count <= sort_count + 1;
--                                    sort_count <= sort_count + 1;                                
--                                when others => -- do nothing
--                            end case;    
--                        when 3 =>
--                            case sub_sort_count is
--                                when 3 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/8-1 loop
----                                        check_and_swap(8*i, 8*i+4, (i mod 2) = 0); -- increasing if even index
----                                        check_and_swap(8*i+1, 8*i+5, (i mod 2) = 0); -- increasing if even index
----                                        check_and_swap(8*i+2, 8*i+6, (i mod 2) = 0); -- increasing if even index
----                                        check_and_swap(8*i+3, 8*i+7, (i mod 2) = 0); -- increasing if even index
----                                    end loop;
--                                    sub_sort_count <= sub_sort_count - 1; 
--                                when 2 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/8-1 loop
----                                        check_and_swap(8*i, 8*i+2, (i mod 2) = 0); -- increasing if even index
----                                        check_and_swap(8*i+1, 8*i+3, (i mod 2) = 0); -- increasing if even index
----                                        check_and_swap(8*i+4, 8*i+6, (i mod 2) = 0); -- increasing if even index
----                                        check_and_swap(8*i+5, 8*i+7, (i mod 2) = 0); -- increasing if even index
----                                    end loop;
--                                    sub_sort_count <= sub_sort_count - 1; 
--                                when 1 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/(sort_exp)-1 loop
----                                        for j in 0 to sort_minus1_exp-1 loop -- 0 and 1
----                                            check_and_swap(sort_exp*i+2*j, sort_exp*i+sub_sort_count+2*j, (i mod 2) = 0); -- increasing if even index
----                                        end loop;
----                                    end loop;
--                                    sub_sort_count <= sort_count + 1;
--                                    sort_count <= sort_count + 1;
--                                when others => -- do nothing
--                            end case;   
--                        when 4 =>
--                            case sub_sort_count is
--                                when 4 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/2-1 loop
----                                        check_and_swap(i, i+8, false); -- increasing if even index
----                                    end loop;
--                                    sub_sort_count <= sub_sort_count - 1; 
--                                when 3 => 
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/16-1 loop
----                                        check_and_swap(16*i, 16*i+4, false); -- increasing if even index
----                                        check_and_swap(16*i+1, 16*i+5, false); -- increasing if even index
----                                        check_and_swap(16*i+2, 16*i+6, false); -- increasing if even index
----                                        check_and_swap(16*i+3, 16*i+7, false); -- increasing if even index
----                                        check_and_swap(16*i+8, 16*i+12, false); -- increasing if even index
----                                        check_and_swap(16*i+9, 16*i+13, false); -- increasing if even index
----                                        check_and_swap(16*i+10, 16*i+14, false); -- increasing if even index
----                                        check_and_swap(16*i+11, 16*i+15, false); -- increasing if even index
----                                    end loop;
--                                    sub_sort_count <= sub_sort_count - 1; 
--                                when 2 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/16-1 loop -- blue/green boxes
----                                        for j in i to N/4-1 loop -- red boxes
----                                            for k in j*4 to j*4+(N/8-1) loop -- line low points
----                                                check_and_swap(k, k+2, false); -- increasing if even index
----                                            end loop;
----                                        end loop;
----                                    end loop;
--                                    sub_sort_count <= sub_sort_count - 1; 
--                                when 1 =>
--                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
--                                        for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes
--                                            for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points
--                                                check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0);
--                                            end loop;
--                                        end loop;
--                                    end loop;
----                                    for i in 0 to N/(sort_exp)-1 loop
----                                        for j in 0 to power_of_2(sort_count-1)-1 loop -- 0 and 1
----                                            check_and_swap(sort_exp*i+2*j, sort_exp*i+sub_sort_count+2*j, false); -- increasing if even index
----                                        end loop;
----                                    end loop;
----                                    for i in 0 to N/sort_exp-1 loop --blue/green boxes
----                                        for j in i to N/sub_sort_exp-1 loop --red boxes
----                                            for k in j*sub_sort_exp to j*sub_sort_exp+(N/sort_exp-1) loop --line low points
----                                                check_and_swap(k, k+1, false);
----                                            end loop;
----                                        end loop;
----                                    end loop; 
--                                    sub_sort_count <= sort_count + 1;
--                                    sort_count <= sort_count + 1;
--                                    state <= FINISHED;
--                                when others => -- do nothing     
--                                    next_state <= FINISHED;                  
--                            end case; 
--                        when others => -- do nothing
--                    end case;
                when FINISHED =>
                    done <= '1';
                    
            end case;
        end if;
    end process;

    sorted <= items;
end architecture;
