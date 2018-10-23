library ieee;
use ieee.std_logic_1164.all;
use work.my_data_types.all;

entity Fordwarding is 
generic ( 
	n		: integer := 16;
	dimH	: integer := 8;
	dimADN		: 	natural  :=	3

);   -- numero de entradas en bits

port (	
			CLOCK_50, reset : in std_logic;
			start :	in std_logic;
         --flechas : in std_logic_vector (2*n-1 downto 0);
			direccion : in std_logic;
			en_read : out std_logic
);
end Fordwarding;

architecture behavioral of Fordwarding is
	type state_type is (s0, s1, s2, s3, s4);
	signal state   : state_type;
	signal run : std_logic;
	signal s_dato : std_logic_vector (m-1 downto 0);
	signal s_up, s_down, s_dir, s_en_read, s_en_cnt, s_set_dir : std_logic;
	
	signal	rflechas, wflechas	:	std_logic_vector (2*n-1 downto 0);
	signal	wadd,	radd	:	std_logic_vector(11 downto 0);
	signal	inAminoH, inAminoV	:	std_logic_vector(dimADN-1 downto 0);
	signal	wdata	:	std_logic_vector(2*n-1 downto 0);
	signal	inDireccion, flag	:	std_logic;
	
	
	component SystolicFordward is
		generic(
			NoCell		: 	natural  :=	8;
			dimH			: 	natural  :=	8;
			dimADN		: 	natural  :=	3
		);
		port(
			-- Input ports
			CLOCK_50		:	in	std_logic;
			reset			:	in std_logic;
			inDireccion	:	in std_logic;	--0 vertical, 1 horizontal
			inAminoH		:	in std_logic_vector(dimADN-1 downto 0);
			inAminoV		:	in std_logic_vector(dimADN-1 downto 0);
			
			flag			:	out	std_logic;

			-- Output ports
			outDireccionVector	:	out std_logic_vector(2*NoCell-1 downto 0)
		);
	end component;
	
	component ram_flechas IS
		PORT
		(
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdaddress		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			wraddress		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			wren		: IN STD_LOGIC  := '0';
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;
	
	component Alineador is 
		generic ( n : integer := 8);   -- numero de entradas en bits
		port (	
					CLOCK_50, reset : in std_logic;
					up, down, en_dir, en_cnt, set_dir: in std_logic;
					flechas : in std_logic_vector (2*n-1 downto 0);
					direccion :	in std_logic;
					dato: out std_logic_vector (m-1 downto 0);
					o_dir : out std_logic
		);
	end component; 
	
	component control_alineador is 
		generic ( n : integer := 8);   -- numero de entradas en bits
		port (	
					CLOCK_50, reset : in std_logic;
					start :	in std_logic;
					flecha: in std_logic_vector (m-1 downto 0);
					dir : in std_logic;
					up, down, en_cnt, en_read, set_dir: out std_logic;
					wadd	:	in		std_logic_vector(11 downto 0);
					radd	:	out	std_logic_vector(11 downto 0)
		);
	end component; 

begin
	fordward : SystolicFordward
		generic map ( NoCell => n, dimH => dimH, dimADN => dimADN )
		port map (	CLOCK_50	=> CLOCK_50,
						reset	=> reset,
						inDireccion	=> inDireccion,
						inAminoH	=> inAminoH,
						inAminoV	=> inAminoV,
						flag	=>	flag,
						outDireccionVector	=> wdata
		);

--	memoria : ram_flechas
--		port map (	clock	=>	CLOCK_50,
--						data	=>	wdata,
--						rdaddress	=> radd,
--						wraddress	=> "000000000000",
--						wren	=> '0',
--						q	=> rflechas
--		);
--	datapath : Alineador
--		generic map ( n => n )
--		port map (	CLOCK_50 => CLOCK_50,
--						reset => reset,
--						up => s_up,
--						down => s_down,
--						en_dir => s_en_read,
--						en_cnt => s_en_cnt,
--						set_dir => s_set_dir,
--						flechas => rflechas,
--						direccion => direccion,
--						dato =>  s_dato,
--						o_dir => s_dir
--		);
--		
--	control : control_alineador
--		generic map ( n => n )
--		port map (	CLOCK_50 => CLOCK_50,
--						reset => reset,
--						start => '1',
--						flecha => s_dato,
--						dir => s_dir,
--						up => s_up,
--						down => s_down,
--						en_cnt => s_en_cnt,
--						en_read => s_en_read,
--						set_dir => s_set_dir,
--						wadd	=>	wadd,
--						radd	=>	radd
--		);
		
	en_read <= s_en_read;
end behavioral;