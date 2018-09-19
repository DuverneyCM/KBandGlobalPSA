	component FFT_sub is
		port (
			clk_clk                    : in  std_logic                     := 'X';             -- clk
			reset_reset_n              : in  std_logic                     := 'X';             -- reset_n
			s0_waitrequest             : out std_logic;                                        -- waitrequest
			s0_readdata                : out std_logic_vector(31 downto 0);                    -- readdata
			s0_readdatavalid           : out std_logic;                                        -- readdatavalid
			s0_burstcount              : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			s0_writedata               : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			s0_address                 : in  std_logic_vector(18 downto 0) := (others => 'X'); -- address
			s0_write                   : in  std_logic                     := 'X';             -- write
			s0_read                    : in  std_logic                     := 'X';             -- read
			s0_byteenable              : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			s0_debugaccess             : in  std_logic                     := 'X';             -- debugaccess
			sgdma_from_fft_csr_irq_irq : out std_logic;                                        -- irq
			sgdma_to_fft_csr_irq_irq   : out std_logic;                                        -- irq
			to_ddr_waitrequest         : in  std_logic                     := 'X';             -- waitrequest
			to_ddr_readdata            : in  std_logic_vector(63 downto 0) := (others => 'X'); -- readdata
			to_ddr_readdatavalid       : in  std_logic                     := 'X';             -- readdatavalid
			to_ddr_burstcount          : out std_logic_vector(4 downto 0);                     -- burstcount
			to_ddr_writedata           : out std_logic_vector(63 downto 0);                    -- writedata
			to_ddr_address             : out std_logic_vector(29 downto 0);                    -- address
			to_ddr_write               : out std_logic;                                        -- write
			to_ddr_read                : out std_logic;                                        -- read
			to_ddr_byteenable          : out std_logic_vector(7 downto 0);                     -- byteenable
			to_ddr_debugaccess         : out std_logic                                         -- debugaccess
		);
	end component FFT_sub;

	u0 : component FFT_sub
		port map (
			clk_clk                    => CONNECTED_TO_clk_clk,                    --                    clk.clk
			reset_reset_n              => CONNECTED_TO_reset_reset_n,              --                  reset.reset_n
			s0_waitrequest             => CONNECTED_TO_s0_waitrequest,             --                     s0.waitrequest
			s0_readdata                => CONNECTED_TO_s0_readdata,                --                       .readdata
			s0_readdatavalid           => CONNECTED_TO_s0_readdatavalid,           --                       .readdatavalid
			s0_burstcount              => CONNECTED_TO_s0_burstcount,              --                       .burstcount
			s0_writedata               => CONNECTED_TO_s0_writedata,               --                       .writedata
			s0_address                 => CONNECTED_TO_s0_address,                 --                       .address
			s0_write                   => CONNECTED_TO_s0_write,                   --                       .write
			s0_read                    => CONNECTED_TO_s0_read,                    --                       .read
			s0_byteenable              => CONNECTED_TO_s0_byteenable,              --                       .byteenable
			s0_debugaccess             => CONNECTED_TO_s0_debugaccess,             --                       .debugaccess
			sgdma_from_fft_csr_irq_irq => CONNECTED_TO_sgdma_from_fft_csr_irq_irq, -- sgdma_from_fft_csr_irq.irq
			sgdma_to_fft_csr_irq_irq   => CONNECTED_TO_sgdma_to_fft_csr_irq_irq,   --   sgdma_to_fft_csr_irq.irq
			to_ddr_waitrequest         => CONNECTED_TO_to_ddr_waitrequest,         --                 to_ddr.waitrequest
			to_ddr_readdata            => CONNECTED_TO_to_ddr_readdata,            --                       .readdata
			to_ddr_readdatavalid       => CONNECTED_TO_to_ddr_readdatavalid,       --                       .readdatavalid
			to_ddr_burstcount          => CONNECTED_TO_to_ddr_burstcount,          --                       .burstcount
			to_ddr_writedata           => CONNECTED_TO_to_ddr_writedata,           --                       .writedata
			to_ddr_address             => CONNECTED_TO_to_ddr_address,             --                       .address
			to_ddr_write               => CONNECTED_TO_to_ddr_write,               --                       .write
			to_ddr_read                => CONNECTED_TO_to_ddr_read,                --                       .read
			to_ddr_byteenable          => CONNECTED_TO_to_ddr_byteenable,          --                       .byteenable
			to_ddr_debugaccess         => CONNECTED_TO_to_ddr_debugaccess          --                       .debugaccess
		);

