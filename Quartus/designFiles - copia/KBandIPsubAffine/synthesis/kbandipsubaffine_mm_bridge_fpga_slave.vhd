-- kbandipsubaffine_mm_bridge_fpga_slave.vhd

-- Generated using ACDS version 16.1 196

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kbandipsubaffine_mm_bridge_fpga_slave is
	generic (
		DATA_WIDTH        : integer := 64;
		SYMBOL_WIDTH      : integer := 8;
		HDL_ADDR_WIDTH    : integer := 18;
		BURSTCOUNT_WIDTH  : integer := 1;
		PIPELINE_COMMAND  : integer := 1;
		PIPELINE_RESPONSE : integer := 1
	);
	port (
		clk              : in  std_logic                     := '0';             --   clk.clk
		reset            : in  std_logic                     := '0';             -- reset.reset
		s0_waitrequest   : out std_logic;                                        --    s0.waitrequest
		s0_readdata      : out std_logic_vector(63 downto 0);                    --      .readdata
		s0_readdatavalid : out std_logic;                                        --      .readdatavalid
		s0_burstcount    : in  std_logic_vector(0 downto 0)  := (others => '0'); --      .burstcount
		s0_writedata     : in  std_logic_vector(63 downto 0) := (others => '0'); --      .writedata
		s0_address       : in  std_logic_vector(17 downto 0) := (others => '0'); --      .address
		s0_write         : in  std_logic                     := '0';             --      .write
		s0_read          : in  std_logic                     := '0';             --      .read
		s0_byteenable    : in  std_logic_vector(7 downto 0)  := (others => '0'); --      .byteenable
		s0_debugaccess   : in  std_logic                     := '0';             --      .debugaccess
		m0_waitrequest   : in  std_logic                     := '0';             --    m0.waitrequest
		m0_readdata      : in  std_logic_vector(63 downto 0) := (others => '0'); --      .readdata
		m0_readdatavalid : in  std_logic                     := '0';             --      .readdatavalid
		m0_burstcount    : out std_logic_vector(0 downto 0);                     --      .burstcount
		m0_writedata     : out std_logic_vector(63 downto 0);                    --      .writedata
		m0_address       : out std_logic_vector(17 downto 0);                    --      .address
		m0_write         : out std_logic;                                        --      .write
		m0_read          : out std_logic;                                        --      .read
		m0_byteenable    : out std_logic_vector(7 downto 0);                     --      .byteenable
		m0_debugaccess   : out std_logic;                                        --      .debugaccess
		m0_response      : in  std_logic_vector(1 downto 0)  := (others => '0');
		s0_response      : out std_logic_vector(1 downto 0)
	);
end entity kbandipsubaffine_mm_bridge_fpga_slave;

architecture rtl of kbandipsubaffine_mm_bridge_fpga_slave is
	component altera_avalon_mm_bridge is
		generic (
			DATA_WIDTH        : integer := 32;
			SYMBOL_WIDTH      : integer := 8;
			HDL_ADDR_WIDTH    : integer := 10;
			BURSTCOUNT_WIDTH  : integer := 1;
			PIPELINE_COMMAND  : integer := 1;
			PIPELINE_RESPONSE : integer := 1
		);
		port (
			clk              : in  std_logic                     := 'X';             -- clk
			reset            : in  std_logic                     := 'X';             -- reset
			s0_waitrequest   : out std_logic;                                        -- waitrequest
			s0_readdata      : out std_logic_vector(63 downto 0);                    -- readdata
			s0_readdatavalid : out std_logic;                                        -- readdatavalid
			s0_burstcount    : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			s0_writedata     : in  std_logic_vector(63 downto 0) := (others => 'X'); -- writedata
			s0_address       : in  std_logic_vector(17 downto 0) := (others => 'X'); -- address
			s0_write         : in  std_logic                     := 'X';             -- write
			s0_read          : in  std_logic                     := 'X';             -- read
			s0_byteenable    : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- byteenable
			s0_debugaccess   : in  std_logic                     := 'X';             -- debugaccess
			m0_waitrequest   : in  std_logic                     := 'X';             -- waitrequest
			m0_readdata      : in  std_logic_vector(63 downto 0) := (others => 'X'); -- readdata
			m0_readdatavalid : in  std_logic                     := 'X';             -- readdatavalid
			m0_burstcount    : out std_logic_vector(0 downto 0);                     -- burstcount
			m0_writedata     : out std_logic_vector(63 downto 0);                    -- writedata
			m0_address       : out std_logic_vector(17 downto 0);                    -- address
			m0_write         : out std_logic;                                        -- write
			m0_read          : out std_logic;                                        -- read
			m0_byteenable    : out std_logic_vector(7 downto 0);                     -- byteenable
			m0_debugaccess   : out std_logic;                                        -- debugaccess
			s0_response      : out std_logic_vector(1 downto 0);                     -- response
			m0_response      : in  std_logic_vector(1 downto 0)  := (others => 'X')  -- response
		);
	end component altera_avalon_mm_bridge;

begin

	mm_bridge_fpga_slave : component altera_avalon_mm_bridge
		generic map (
			DATA_WIDTH        => DATA_WIDTH,
			SYMBOL_WIDTH      => SYMBOL_WIDTH,
			HDL_ADDR_WIDTH    => HDL_ADDR_WIDTH,
			BURSTCOUNT_WIDTH  => BURSTCOUNT_WIDTH,
			PIPELINE_COMMAND  => PIPELINE_COMMAND,
			PIPELINE_RESPONSE => PIPELINE_RESPONSE
		)
		port map (
			clk              => clk,              --   clk.clk
			reset            => reset,            -- reset.reset
			s0_waitrequest   => s0_waitrequest,   --    s0.waitrequest
			s0_readdata      => s0_readdata,      --      .readdata
			s0_readdatavalid => s0_readdatavalid, --      .readdatavalid
			s0_burstcount    => s0_burstcount,    --      .burstcount
			s0_writedata     => s0_writedata,     --      .writedata
			s0_address       => s0_address,       --      .address
			s0_write         => s0_write,         --      .write
			s0_read          => s0_read,          --      .read
			s0_byteenable    => s0_byteenable,    --      .byteenable
			s0_debugaccess   => s0_debugaccess,   --      .debugaccess
			m0_waitrequest   => m0_waitrequest,   --    m0.waitrequest
			m0_readdata      => m0_readdata,      --      .readdata
			m0_readdatavalid => m0_readdatavalid, --      .readdatavalid
			m0_burstcount    => m0_burstcount,    --      .burstcount
			m0_writedata     => m0_writedata,     --      .writedata
			m0_address       => m0_address,       --      .address
			m0_write         => m0_write,         --      .write
			m0_read          => m0_read,          --      .read
			m0_byteenable    => m0_byteenable,    --      .byteenable
			m0_debugaccess   => m0_debugaccess,   --      .debugaccess
			s0_response      => open,             -- (terminated)
			m0_response      => "00"              -- (terminated)
		);

end architecture rtl; -- of kbandipsubaffine_mm_bridge_fpga_slave
