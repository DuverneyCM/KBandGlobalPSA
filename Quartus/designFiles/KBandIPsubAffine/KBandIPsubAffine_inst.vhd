	component KBandIPsubAffine is
		port (
			clk_clk                  : in  std_logic                      := 'X';             -- clk
			clk_int_clk              : in  std_logic                      := 'X';             -- clk
			kbandinput_1_csr_irq_irq : out std_logic;                                         -- irq
			kbandoutput_csr_irq_irq  : out std_logic;                                         -- irq
			m0_waitrequest           : in  std_logic                      := 'X';             -- waitrequest
			m0_readdata              : in  std_logic_vector(127 downto 0) := (others => 'X'); -- readdata
			m0_readdatavalid         : in  std_logic                      := 'X';             -- readdatavalid
			m0_burstcount            : out std_logic_vector(4 downto 0);                      -- burstcount
			m0_writedata             : out std_logic_vector(127 downto 0);                    -- writedata
			m0_address               : out std_logic_vector(29 downto 0);                     -- address
			m0_write                 : out std_logic;                                         -- write
			m0_read                  : out std_logic;                                         -- read
			m0_byteenable            : out std_logic_vector(15 downto 0);                     -- byteenable
			m0_debugaccess           : out std_logic;                                         -- debugaccess
			reset_reset_n            : in  std_logic                      := 'X';             -- reset_n
			sfpga_waitrequest        : out std_logic;                                         -- waitrequest
			sfpga_readdata           : out std_logic_vector(63 downto 0);                     -- readdata
			sfpga_readdatavalid      : out std_logic;                                         -- readdatavalid
			sfpga_burstcount         : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			sfpga_writedata          : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			sfpga_address            : in  std_logic_vector(17 downto 0)  := (others => 'X'); -- address
			sfpga_write              : in  std_logic                      := 'X';             -- write
			sfpga_read               : in  std_logic                      := 'X';             -- read
			sfpga_byteenable         : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			sfpga_debugaccess        : in  std_logic                      := 'X';             -- debugaccess
			slw_waitrequest          : out std_logic;                                         -- waitrequest
			slw_readdata             : out std_logic_vector(31 downto 0);                     -- readdata
			slw_readdatavalid        : out std_logic;                                         -- readdatavalid
			slw_burstcount           : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			slw_writedata            : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- writedata
			slw_address              : in  std_logic_vector(16 downto 0)  := (others => 'X'); -- address
			slw_write                : in  std_logic                      := 'X';             -- write
			slw_read                 : in  std_logic                      := 'X';             -- read
			slw_byteenable           : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- byteenable
			slw_debugaccess          : in  std_logic                      := 'X'              -- debugaccess
		);
	end component KBandIPsubAffine;

	u0 : component KBandIPsubAffine
		port map (
			clk_clk                  => CONNECTED_TO_clk_clk,                  --                  clk.clk
			clk_int_clk              => CONNECTED_TO_clk_int_clk,              --              clk_int.clk
			kbandinput_1_csr_irq_irq => CONNECTED_TO_kbandinput_1_csr_irq_irq, -- kbandinput_1_csr_irq.irq
			kbandoutput_csr_irq_irq  => CONNECTED_TO_kbandoutput_csr_irq_irq,  --  kbandoutput_csr_irq.irq
			m0_waitrequest           => CONNECTED_TO_m0_waitrequest,           --                   m0.waitrequest
			m0_readdata              => CONNECTED_TO_m0_readdata,              --                     .readdata
			m0_readdatavalid         => CONNECTED_TO_m0_readdatavalid,         --                     .readdatavalid
			m0_burstcount            => CONNECTED_TO_m0_burstcount,            --                     .burstcount
			m0_writedata             => CONNECTED_TO_m0_writedata,             --                     .writedata
			m0_address               => CONNECTED_TO_m0_address,               --                     .address
			m0_write                 => CONNECTED_TO_m0_write,                 --                     .write
			m0_read                  => CONNECTED_TO_m0_read,                  --                     .read
			m0_byteenable            => CONNECTED_TO_m0_byteenable,            --                     .byteenable
			m0_debugaccess           => CONNECTED_TO_m0_debugaccess,           --                     .debugaccess
			reset_reset_n            => CONNECTED_TO_reset_reset_n,            --                reset.reset_n
			sfpga_waitrequest        => CONNECTED_TO_sfpga_waitrequest,        --                sfpga.waitrequest
			sfpga_readdata           => CONNECTED_TO_sfpga_readdata,           --                     .readdata
			sfpga_readdatavalid      => CONNECTED_TO_sfpga_readdatavalid,      --                     .readdatavalid
			sfpga_burstcount         => CONNECTED_TO_sfpga_burstcount,         --                     .burstcount
			sfpga_writedata          => CONNECTED_TO_sfpga_writedata,          --                     .writedata
			sfpga_address            => CONNECTED_TO_sfpga_address,            --                     .address
			sfpga_write              => CONNECTED_TO_sfpga_write,              --                     .write
			sfpga_read               => CONNECTED_TO_sfpga_read,               --                     .read
			sfpga_byteenable         => CONNECTED_TO_sfpga_byteenable,         --                     .byteenable
			sfpga_debugaccess        => CONNECTED_TO_sfpga_debugaccess,        --                     .debugaccess
			slw_waitrequest          => CONNECTED_TO_slw_waitrequest,          --                  slw.waitrequest
			slw_readdata             => CONNECTED_TO_slw_readdata,             --                     .readdata
			slw_readdatavalid        => CONNECTED_TO_slw_readdatavalid,        --                     .readdatavalid
			slw_burstcount           => CONNECTED_TO_slw_burstcount,           --                     .burstcount
			slw_writedata            => CONNECTED_TO_slw_writedata,            --                     .writedata
			slw_address              => CONNECTED_TO_slw_address,              --                     .address
			slw_write                => CONNECTED_TO_slw_write,                --                     .write
			slw_read                 => CONNECTED_TO_slw_read,                 --                     .read
			slw_byteenable           => CONNECTED_TO_slw_byteenable,           --                     .byteenable
			slw_debugaccess          => CONNECTED_TO_slw_debugaccess           --                     .debugaccess
		);

