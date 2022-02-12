package lock_state is
    type lock_state is (locked, unlocking, unlocked);
end package;
use work.lock_state.all;

library IEEE;
use IEEE.NUMERIC_STD.ALL;

entity lock is
    Port (
        clk             : in      bit                   :=    '1';
        lock            : in      lock_state            := locked;
        led_out         : out     bit_vector(7 downto 0)
    );
end lock;

architecture arch_lock of lock is
    constant u_size       : natural                     :=                      3; -- Enough to fit flash_period
    constant flash_period : unsigned(u_size-1 downto 0) := to_unsigned(4, u_size); -- Desired flash clk period
begin

    led_flash: process(clk, lock)
        variable i : unsigned(u_size-1 downto 0)        := to_unsigned(1, u_size);
    begin
        if    lock = locked then
            if i <= (flash_period / 2) then
                led_out <= b"1010_1010";
            else
                led_out <= b"0101_0101";
            end if;
        elsif lock = unlocking then
            led_out <= b"1000_0001";
        else--lock = unlocked
            if i <= (flash_period / 2) then
                led_out <= b"1111_1111";
            else
                led_out <= b"0000_0000";
            end if;
        end if;

        if i < flash_period then
            i := i + to_unsigned(1, u_size);
        else
            i := to_unsigned(1, u_size);
        end if;
    end process led_flash;

end arch_lock;