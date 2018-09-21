library IEEE;
use IEEE.STD_LOGIC_1164.all;
package my_data_types is
               constant m : integer := 2;       -- size in bits of the arrows
                type matrix is array (natural range <>) of std_logic_vector (m-1 downto 0);
end my_data_types;