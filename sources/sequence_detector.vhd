library IEEE;
use IEEE.NUMERIC_STD.ALL;
package sequence_detector_shared_constants is
    constant counter_size   : natural                           := 4; -- Must be enough to inputs_allowed & input_counter
    constant inputs_allowed : unsigned(counter_size-1 downto 0) := to_unsigned(12, counter_size);
end package;
use work.sequence_detector_shared_constants.all;

library IEEE;
use IEEE.NUMERIC_STD.ALL;

use work.lock_state.all;   -- lock.vhd
use work.button_state.all; -- buttons.vhd

entity sequence_detector is
    Port (
        lock   : inout lock_state  ;
        button : in    button_state
    );
end sequence_detector;

architecture arch_register_based of sequence_detector is
    constant reg_size       : natural                           := 3; -- Must be enough for U(000),1(001),2(010),3(011),4(100)
begin
    seq_det: process(button)
        variable reg_4         : unsigned(reg_size-1 downto 0)     := to_unsigned(0, reg_size);
        variable reg_3         : unsigned(reg_size-1 downto 0)     := to_unsigned(0, reg_size);
        variable reg_2         : unsigned(reg_size-1 downto 0)     := to_unsigned(0, reg_size);
        variable reg_1         : unsigned(reg_size-1 downto 0)     := to_unsigned(0, reg_size);
        variable reg_0         : unsigned(reg_size-1 downto 0)     := to_unsigned(0, reg_size);
        variable input_counter : unsigned(counter_size-1 downto 0) := to_unsigned(0, counter_size);
        
        procedure reset is
        begin
            input_counter := to_unsigned(0, counter_size);
            reg_4         := to_unsigned(0, reg_size);
            reg_3         := to_unsigned(0, reg_size);
            reg_2         := to_unsigned(0, reg_size);
            reg_1         := to_unsigned(0, reg_size);
            reg_0         := to_unsigned(0, reg_size);
        end procedure reset;
    begin
        if button /= none then
            if    lock = locked then
                if button = button_init then
                    lock <= unlocking;
                    reset;
                end if;
            elsif lock = unlocking then
                if button = button_init then
                    lock <= locked;
                    reset;
                else
                    -- Shift registers
                    reg_0 := reg_1;
                    reg_1 := reg_2;
                    reg_2 := reg_3;
                    reg_3 := reg_4;
                    
                    -- Insert new
                    if    button = button_1 then
                        reg_4 := to_unsigned(1, reg_size);
                    elsif button = button_2 then
                        reg_4 := to_unsigned(2, reg_size);
                    elsif button = button_3 then
                        reg_4 := to_unsigned(3, reg_size);
                    elsif button = button_4 then
                        reg_4 := to_unsigned(4, reg_size);
                    end if;
                    
                    if reg_0 = 1 and reg_1 = 4 and reg_2 = 2 and reg_3 = 3 and reg_4 = 3 then -- check match 1-4-2-3-3
                        lock <= unlocked;
                        reset;
                    else
                        input_counter := input_counter + to_unsigned(1, counter_size);
                        if input_counter >= inputs_allowed then
                           lock <= locked;
                           reset;
                        end if;
                    end if;
                end if;
            elsif lock = unlocked then
                if button = button_init then
                    lock <= locked;
                    reset;
                end if;
            end if;
        end if;            
    end process seq_det;
end arch_register_based;



architecture arch_moore_fsm of sequence_detector is
    type states is (s0, s1, s2, s3, s4, s5, s6);
    signal state : states := s0;
begin

    seq_det: process(button)
        variable input_counter : unsigned(counter_size-1 downto 0) := to_unsigned(0, counter_size);

        procedure increment_counter is
        begin
            input_counter := input_counter + to_unsigned(1, counter_size);
        end procedure;

        procedure reset_counter is
        begin
            input_counter := to_unsigned(0, counter_size);
        end procedure;
    begin
        if button /= none then
            if    state = s0 then
                reset_counter;
                if button = button_init then
                    state <= s1;
                end if;
            elsif state = s1 then
                increment_counter;
                if button = button_1 then
                    state <= s2;
                elsif button = button_init then
                    state <= s0;
                else
                    state <= s1;
                end if;
            elsif state = s2 then
                increment_counter;
                if button = button_4 then
                    state <= s3;
                elsif button = button_init then
                    state <= s0;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            elsif state = s3 then
                increment_counter;
                if button = button_2 then
                    state <= s4;
                elsif button = button_init then
                    state <= s0;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            elsif state = s4 then
                increment_counter;
                if button = button_3 then
                    state <= s5;
                elsif button = button_init then
                    state <= s0;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            elsif state = s5 then
                increment_counter;
                if button = button_3 then
                    reset_counter;
                    state <= s6;
                elsif button = button_init then
                    state <= s0;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            else--state = s6
                if button = button_init then
                    state <= s0;
                end if;
            end if;

            if input_counter >= 12 then
                state <= s0;
            end if;
        end if;
    end process seq_det;

    fsm_output: process(state)
    begin
        if    state = s0 then
            lock <= locked;
        elsif state = s6 then
            lock <= unlocked;
        else--state = s1,s2,s3,s4,s5
            lock <= unlocking;
        end if;
    end process fsm_output;

end arch_moore_fsm;



architecture arch_mealy_fsm of sequence_detector is
    type states is (s0, s1, s2, s3, s4, s5);
    signal state : states := s0;
begin

    seq_det: process(button)
        variable input_counter : unsigned(counter_size-1 downto 0) := to_unsigned(0, counter_size);

        procedure increment_counter is
        begin
            input_counter := input_counter + to_unsigned(1, counter_size);
        end procedure;

        procedure reset_counter is
        begin
            input_counter := to_unsigned(0, counter_size);
        end procedure;
    begin
        if button /= none then
            if    state = s0 then
                reset_counter;
                if button = button_init then
                    state <= s1;
                    lock <= unlocking;
                end if;
            elsif state = s1 then
                increment_counter;
                if button = button_1 then
                    state <= s2;
                elsif button = button_init then
                    state <= s0;
                    lock <= locked;
                else
                    state <= s1;
                end if;
            elsif state = s2 then
                increment_counter;
                if button = button_4 then
                    state <= s3;
                elsif button = button_init then
                    state <= s0;
                    lock <= locked;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            elsif state = s3 then
                increment_counter;
                if button = button_2 then
                    state <= s4;
                elsif button = button_init then
                    state <= s0;
                    lock <= locked;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            elsif state = s4 then
                increment_counter;
                if button = button_3 then
                    state <= s5;
                elsif button = button_init then
                    state <= s0;
                    lock <= locked;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            elsif state = s5 then
                increment_counter;
                if button = button_3 then
                    reset_counter;
                    state <= s0;
                    lock <= unlocked;
                elsif button = button_init then
                    state <= s0;
                    lock <= locked;
                elsif button = button_1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            end if;

            if input_counter >= 12 then
                state <= s0;
            end if;
        end if;
    end process seq_det;

end arch_mealy_fsm;