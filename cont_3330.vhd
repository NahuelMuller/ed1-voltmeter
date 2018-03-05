-------------------------------------------------
-- Contador 3330	(cont_3330)
--
-- Descripcion:	Contador de 3330 pulsos
-- Entradas:	Clock y reset
-- Salidas:		Pulso 3329 y pulso 3330
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity cont_3330 is
	port(
		clk, rst: in std_logic;
		c3329, c3330: out std_logic
	);
end entity;

architecture cont_3330_arq of cont_3330 is

	signal aux_rst: std_logic;
	signal cont_out: std_logic_vector(11 downto 0);

	component cont_bN is	-- Contador binario de N bits
		generic (N : natural);
		port(
			clk, rst, ena: in std_logic;
			cont_out: out std_logic_vector(N-1 downto 0);
			carry: out std_logic
		);
	end component;

begin

	cont_bNx: cont_bN
		generic map (12)
		port map (clk, aux_rst, '1', cont_out);		-- Habilitado todo el tiempo

	-- 3329 (1101 0000 0001)
	c3329 <= cont_out(11) and cont_out(10) and cont_out(8) and cont_out(0);	-- 

	-- Reset externo o cuando llega a contar 3330 (1101 0000 0010)
	aux_rst <= rst or (cont_out(11) and cont_out(10) and cont_out(8) and cont_out(1));

	c3330 <= aux_rst;

end architecture;