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
    constant scale_max : positive := 32;--defines the number of inputs to the system
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
        clk     : in  std_logic;--clock signal, program will run on rising edge of clock
        data    : in  input_array(0 to N-1); --input data to be sorted, will not be modified by entity
        sorted  : out input_array(0 to N-1); --sorted out data, will not be populated until 1 clock passes and will be sorted on rising edge of done
        done    : out std_logic := '0' -- signal signifying whether the "sorted" signal is sorted or not
    );
end bitonic_sort;

architecture Behavioral of bitonic_sort is
    -- log base 2 lookup table, required as built in log function is real number arithmetic and unsynthesizable
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
    signal items : input_array(0 to N-1); -- signal to be written to by the functions
    type state_type is (INIT, SORT, FINISHED); --possible states for the main finite state machine
    signal state, next_state : state_type; --use and extra next_state variable to store the next state while still operating on current state
    
    signal sort_count : positive := 1; -- signal to store the main state of the sort function, from 1 to log(scale_max)
    signal sub_sort_count : positive  := 1; --signal to store the sub state of the main state, from 1 to sort_count
    constant scale : positive := log_base2(N); -- log2(N), used to find the total number of states the function will go through
    signal count : integer := 0;
    
    -- Helper function so exponential function can be modified wihtout needing to update many places in code
    -- TODO: Investigate faster alternative using left shifts
    function power_of_2(power : natural) return positive is
    variable result : positive;
    begin
        return  2**power; -- this is an integer function and therefore safe for synthesis
   end power_of_2;
begin

    process (clk)
        
        variable sort_exp : positive; -- will store 2^sort_count, helper variable
        variable sort_minus1_exp : positive; -- will store 2^(sort_count-1), helper variable
        variable sub_sort_exp : positive; -- will store 2^sub_sort_count, helper variable
        variable sub_sort_minus1_exp : positive; -- will store 2^(sub_sort_count-1), helper variable
        -- check if array is in correct order, index_1 must be less than index_2
        -- increasing is '1' if the item at position index_1 should be less than the item at position index_2 and '0' if the item at position index_1 should be greater than the item at position index_2
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
            for i in 0 to N/sort_exp-1 loop --blue/green boxes in diagram, starts counting from 0 to scale_max/2 then is cut in half each sort_state
                for j in 0 to sort_exp/sub_sort_exp-1 loop --red boxes in the diagram, creates one box in the first sub_sort state then doubles each sub_state iteration ending at 0 to 2**(sort_state-1)
                    for k in i*sort_exp+j*sub_sort_exp to i*sort_exp+j*sub_sort_exp+sub_sort_minus1_exp-1 loop --line low points in the diagram, multiply i and j by 2**sort_state and 2**sub_sort_state respectively to increase their step.
                        check_and_swap(k, k+sub_sort_minus1_exp, ((N/sort_exp-i) mod 2) = 0); --call the swap function given line low point and comparing it to the element 2**(sub_sort_state-1) above it, Alternate decreasing or increasing starting from the top and counting down
                    end loop;
                end loop;
            end loop;
        end bitonic_swap_procedure;
           
        
    begin
        if rising_edge(clk) then
            state <= next_state;-- assign state to next_state that may or may not have been assigned last iteration
            case state is --define main finite state machine
                when INIT => --initialize array variable and change state
                    items <= data;
                    next_state <= SORT;
                when SORT => --main state for sorting the array, must have strongly defined sort_count and sub_sort_count or function will not be synthesizable
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
                    end case;--more states can be added to this in order to increase maximum sorting size
                    if sub_sort_count = 1 then --check if in the final sub_sort state, if so sorting of this state is over and we must increase the state by one and reset sub_sort state
                        sub_sort_count <= sort_count + 1;
                        sort_count <= sort_count + 1;
                        if sort_count = scale then --if the in the final sub state of the final sort state then switch to finished state
                            next_state <= FINISHED;
                        end if;
                    else --otherwise move to the next sub_sort_state
                        sub_sort_count <= sub_sort_count - 1;
                    end if;
                when FINISHED =>
                    done <= '1';--signal that the entity is done sorting and can be read from
            end case;
        end if;
    end process;
    sorted <= items;--write out to the sorted signal every iteration
end architecture;
