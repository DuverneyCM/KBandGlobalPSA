	component KBandIPsubPro_KBandInput_2 is
		port (
			clock_clk                    : in  std_logic                      := 'X';             -- clk
			reset_n_reset_n              : in  std_logic                      := 'X';             -- reset_n
			csr_writedata                : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- writedata
			csr_write                    : in  std_logic                      := 'X';             -- write
			csr_byteenable               : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- byteenable
			csr_readdata                 : out std_logic_vector(31 downto 0);                     -- readdata
			csr_read                     : in  std_logic                      := 'X';             -- read
			csr_address                  : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- address
			descriptor_slave_write       : in  std_logic                      := 'X';             -- write
			descriptor_slave_waitrequest : out std_logic;                                         -- waitrequest
			descriptor_slave_writedata   : in  std_logic_vector(127 downto 0) := (others => 'X'); -- writedata
			descriptor_slave_byteenable  : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- byteenable
			csr_irq_irq                  : out std_logic;                                         -- irq
			mm_read_address              : out std_logic_vector(31 downto 0);                     -- address
			mm_read_read                 : out std_logic;                                         -- read
			mm_read_readdata             : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- readdata
			mm_read_waitrequest          : in  std_logic                      := 'X';             -- waitrequest
			mm_read_readdatavalid        : in  std_logic                      := 'X';             -- readdatavalid
			st_source_data               : out std_logic_vector(7 downto 0);                      -- data
			st_source_valid              : out std_logic;                                         -- valid
			st_source_ready              : in  std_logic                      := 'X'              -- ready
		);
	end component KBandIPsubPro_KBandInput_2;

	u0 : component KBandIPsubPro_KBandInput_2
		port map (
			clock_clk                    => CONNECTED_TO_clock_clk,                    --            clock.clk
			reset_n_reset_n              => CONNECTED_TO_reset_n_reset_n,              --          reset_n.reset_n
			csr_writedata                => CONNECTED_TO_csr_writedata,                --              csr.writedata
			csr_write                    => CONNECTED_TO_csr_write,                    --                 .write
			csr_byteenable               => CONNECTED_TO_csr_byteenable,               --                 .byteenable
			csr_readdata                 => CONNECTED_TO_csr_readdata,                 --                 .readdata
			csr_read                     => CONNECTED_TO_csr_read,                     --                 .read
			csr_address                  => CONNECTED_TO_csr_address,                  --                 .address
			descriptor_slave_write       => CONNECTED_TO_descriptor_slave_write,       -- descriptor_slave.write
			descriptor_slave_waitrequest => CONNECTED_TO_descriptor_slave_waitrequest, --                 .waitrequest
			descriptor_slave_writedata   => CONNECTED_TO_descriptor_slave_writedata,   --                 .writedata
			descriptor_slave_byteenable  => CONNECTED_TO_descriptor_slave_byteenable,  --                 .byteenable
			csr_irq_irq                  => CONNECTED_TO_csr_irq_irq,                  --          csr_irq.irq
			mm_read_address              => CONNECTED_TO_mm_read_address,              --          mm_read.address
			mm_read_read                 => CONNECTED_TO_mm_read_read,                 --                 .read
			mm_read_readdata             => CONNECTED_TO_mm_read_readdata,             --                 .readdata
			mm_read_waitrequest          => CONNECTED_TO_mm_read_waitrequest,          --                 .waitrequest
			mm_read_readdatavalid        => CONNECTED_TO_mm_read_readdatavalid,        --                 .readdatavalid
			st_source_data               => CONNECTED_TO_st_source_data,               --        st_source.data
			st_source_valid              => CONNECTED_TO_st_source_valid,              --                 .valid
			st_source_ready              => CONNECTED_TO_st_source_ready               --                 .ready
		);

