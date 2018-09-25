library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity KbandControl is
	port(
		-- clk and reset interface
		clk, reset						:	in		std_logic;
		-- Sink control
		oSinkRead						:	out	std_logic;
		iSinkFIFOempty1				:	in		std_logic;
		iFinalPacket					:	in		std_logic;
		-- Systolic Control
		oDirection						:	out	std_logic;
		oSystolicProcesar				:	out	std_logic;
		iSystolicFinish				:	in		std_logic;
		oResetSync						:	out	std_logic;
		-- Source Control
		oSourceWrite					:	out	std_logic;
		oTransmitir						:	out	std_logic;
		oSourceSendDirection			:	out	std_logic;
		iSourceFIFOfull				:	in		std_logic;
		iSourceFIFOEmpty				:	in		std_logic
	);
end KbandControl;

architecture rtl of KbandControl  is


signal	sFifoCount	:	std_logic_vector(6 downto 0);
signal	sFifoRead, sFifoWrite, sFifoEmpty, sFifoFull		:	std_logic;
signal	sLoadShReg, shr	:	std_logic;
signal	cnt	:	std_logic_vector(3 downto 0);
signal	start	:	std_logic;
signal	sSinkRead, sDirection, sSourceWrite, sSystolicProcesar, sSourceSendDirection, sSystolicFinish	:	std_logic;
signal	sResetSync, sFinalPacket	:	std_logic;
signal	sTransmitir	:	std_logic;


	type state_type is (s0, s0a, s1, s2, s00, s2a, s3, s4, s5, s6);
	signal state   : state_type;

begin

	--start	<=	not(iSinkFIFOempty1 or iSinkFIFOempty2);
	start	<=	not(iSinkFIFOempty1);
	sFinalPacket	<= iFinalPacket;

	--logica de estados para controlar la salida habilitada
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>	--IDLE
					if iSinkFIFOempty1 = '0' then
						state <= s0a;
					else
						state <= s0;
					end if;
				when s0a	=>
					state <= s1;
				when s1=>	--RUN
					if iSinkFIFOempty1 = '1' and sFinalPacket = '0' then -- fin de paquete
						state <= s0;
					elsif sSystolicFinish = '0' then --seguir procesando, pero empezar a guardar flechas
						state <= s2;
					else
						state <= s1;
					end if;
				when s2=>	--Run & Send
					if iSinkFIFOempty1 = '1' and sFinalPacket = '0' then -- fin de paquete
						state <= s00;
					elsif sSystolicFinish = '1' then --finalizar
						state <= s3;
					elsif iSourceFIFOfull = '1' then --pausa
						state <= s4;
					else
						state <= s2;
					end if;
				when s00=>	--IDLE
					if iSinkFIFOempty1 = '0' then
						state <= s2a;
					else
						state <= s00;
					end if;
				when s2a	=>
					state <= s2;
				when s3 =>	--Send Direction (guarda cod de dirección en el buffer)
					state <= s5;
				when s4 =>	--Pause systolic, continue transmission
					if iSourceFIFOfull = '0' then
						state <= s2;
					else
						state <= s4;
					end if;
				when s5 =>	--Send  Enviar todos los bytes de dirección, luego finish
					if iSourceFIFOEmpty = '1' then
						state <= s6;
					else
						state <= s5;
					end if;
				when s6 =>	--Reset de registros internos antes de finalizar
					state <= s0;
			end case;
		end if;
	end process;
	--Logica de salida
	process (state)
	begin
		case state is
			when s0 =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'0';

			when s0a =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'0';
			when s1 =>
				--oSinkRead				<=	sSinkRead;
				sSystolicProcesar		<=	'1';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'0';
			when s2 =>
				--oSinkRead				<=	sSinkRead;
				sSystolicProcesar		<=	'1';
				sSourceWrite			<=	'1';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'1';
			when s00 =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'0';
			when s2a =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'0';
			when s3 =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'1';
				sSourceSendDirection	<=	'1';
				sResetSync				<=	'0';
				sTransmitir				<=	'1';
			when s4 =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'1';
			when s5 =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'0';
				sTransmitir				<=	'1';
			when s6 =>
				--oSinkRead				<=	'0';
				sSystolicProcesar		<=	'0';
				sSourceWrite			<=	'0';
				sSourceSendDirection	<=	'0';
				sResetSync				<=	'1';
				sTransmitir				<=	'0';
		end case;
	end process;


	--Direction
	process (clk, reset)
	begin
		if reset = '1' then
			sDirection <= '0';
			--sSinkRead <= '0';
			--oSystolicProcesar 	<= '0';
			--oSourceWrite			<=	'0';
			--oSourceSendDirection	<=	'0';
			--sSystolicFinish	<= '0';
		elsif (rising_edge(clk)) then
			--oSystolicProcesar <= sSystolicProcesar;
			--oSourceWrite		<=	sSourceWrite;
			--oSourceSendDirection	<=	sSourceSendDirection;
			--sSystolicFinish	<= iSystolicFinish;
			if sSystolicProcesar = '1' then
				sDirection <= NOT(sDirection);
				--sSinkRead <= NOT(sDirection);
			else
				sDirection <= sDirection;
--				if sSinkRead = '1' then
--					sSinkRead <= not(sSinkRead);
--				else
--					sSinkRead <= sSinkRead;
--				end if;
			end if;
		end if;
	end process;
	sSinkRead	<=	NOT(sDirection) when sSystolicProcesar = '1' else '0';
	sSystolicFinish	<= iSystolicFinish;
	oDirection <= (sDirection);
	oSinkRead				<=	sSinkRead;
	oSystolicProcesar <= sSystolicProcesar;
	oSourceWrite		<=	sSourceWrite;
	oSourceSendDirection	<=	sSourceSendDirection;
	oResetSync	<=	sResetSync;
	oTransmitir	<=	sTransmitir;
	--flags MM or irq
--		ADNdirection
--		Start
--		Pause
--		Finish

	--sink
	--data length is defined by DMA descriptor
	--Adquirir	<=	run or pause;
	--sinkRead	<=	run and not(FIFOempty);

	--source
	--data length is defined in DMA descriptor
--	valid

end rtl;
