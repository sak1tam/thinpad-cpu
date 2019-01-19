library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
port(
	clk : in  STD_LOGIC;
	rst : in  STD_LOGIC;
	ram_en : out std_logic;
	ram_we : out std_logic;
	ram_oe : out std_logic;
	ram_addr : out std_logic_vector(17 downto 0);
	ram_data : inout std_logic_vector(15 downto 0);
	led : out std_logic_vector(15 downto 0)
	);

end cpu;

architecture Behavioral of cpu is
	signal pc : std_logic_vector(15 downto 0) :="0000000000000001";   --程序计数器
	signal instructions : STD_LOGIC_VECTOR(15 downto 0);         --指令
	type controler_state is(instruction_fetch,decode,execute,mem_control,write_reg);  --取指、译码、执行、访存、写回
	signal state : controler_state;
	signal rx : std_logic_vector(15 downto 0);    --alu
   signal ry : std_logic_vector(15 downto 0);
   signal alu_out : std_logic_vector(15 downto 0);
	signal r0: std_logic_vector(15 downto 0) := "0000000000000000";   --寄存器r0~r6、寄存器T
   signal r1: std_logic_vector(15 downto 0) := "0000000000000000";
   signal r2: std_logic_vector(15 downto 0) := "0000000000000000";
   signal r3: std_logic_vector(15 downto 0) := "0000000000000000";
   signal r4: std_logic_vector(15 downto 0) := "0000000000000000";
   signal r5:  std_logic_vector(15 downto 0) := "0000000000000000";
   signal r6: std_logic_vector(15 downto 0) := "0000000000000000";
   signal T: std_logic_vector(15 downto 0) := "0000000000000000";
	signal imme : std_logic_vector(15 downto 0) := "0000000000000000";
	signal data : std_logic_vector(15 downto 0); 	--内存储器
	signal mem_data : std_logic_vector(15 downto 0);
	signal mem_addr : std_logic_vector(15 downto 0);
	signal mem_read_data: std_logic_vector(15 downto 0);
	signal mem_read :  std_logic;
	signal mem_write :  std_logic;
	signal status :  std_logic_vector(2 downto 0) :="000";

begin 
process(rst,clk)
	begin
		if(rst='0')then                               -------复位
			state<=instruction_fetch;
			status<="000";
			pc<="0000000000000001";
			led<="0000000000000000";			
			r0<="0000000000000000";
			r1<="0000000000000000";
			r2<="0000000000000000";
			r3<="0000000000000000";
			r4<="0000000000000000";
			r5<="0000000000000000";
			r6<="0000000000000000";
			T<="0000000000000000";
			
		elsif(clk'event and clk='1')then                        -------五个周期
			case state is
				when instruction_fetch=>                  -------取指
								if(status="000")then
									ram_addr<="00" & pc;
									ram_en <= '0';
									ram_oe <= '1';
									ram_we <= '1';
									ram_data<="ZZZZZZZZZZZZZZZZ";
									--led <= (others => '1');
									status<="001";
								elsif(status="001")then                       
									ram_en <= '0';
									ram_oe <= '0';
									ram_we <= '1';
									status<="010";
								elsif(status="010")then
									instructions<=ram_data;
									led<=ram_data;
									status<="000";
									pc <= pc + '1';
									state<=decode;
								end if;
				when decode=>							  	-------译码
					case instructions(15 downto 11)is
						when "00001"=>                       -------LI
							imme <= "00000000" & instructions(7 downto 0);
						when "00010"=>                       -------SLL
							case instructions(7 downto 5) is
                        when "000" => ry <= r0;
								when "001" => ry <= r1;
								when "010" => ry <= r2;
								when "011" => ry <= r3;
								when "100" => ry <= r4;
								when "101" => ry <= r5;
								when "110" => ry <= r6;
								when others => null;
							end case;
							imme <= "0000000000000" & instructions(4 downto 2);
						when "00011"=>                       -------LW
							case instructions(10 downto 8) is
                        when "000" => rx <= r0;
								when "001" => rx <= r1;
								when "010" => rx <= r2;
								when "011" => rx <= r3;
								when "100" => rx <= r4;
								when "101" => rx <= r5;
								when "110" => rx <= r6;
								when others => null;
							end case;
							imme <= "00000000000" & instructions(4 downto 0);
						when "00100"=>                       -------SW
							case instructions(10 downto 8) is
                        when "000" => rx <= r0;
								when "001" => rx <= r1;
								when "010" => rx <= r2;
								when "011" => rx <= r3;
								when "100" => rx <= r4;
								when "101" => rx <= r5;
								when "110" => rx <= r6;
								when others => null;
							end case;
							case instructions(7 downto 5) is
                        when "000" => ry <= r0;
								when "001" => ry <= r1;
								when "010" => ry <= r2;
								when "011" => ry <= r3;
								when "100" => ry <= r4;
								when "101" => ry <= r5;
								when "110" => ry <= r6;
								when others => null;
							end case;
							imme <= "00000000000" & instructions(4 downto 0);
						when "00101"=>                       -------ADDU
							case instructions(10 downto 8) is
                        when "000" => rx <= r0;
								when "001" => rx <= r1;
								when "010" => rx <= r2;
								when "011" => rx <= r3;
								when "100" => rx <= r4;
								when "101" => rx <= r5;
								when "110" => rx <= r6;
								when others => null;
							end case;
							case instructions(7 downto 5) is
                        when "000" => ry <= r0;
								when "001" => ry <= r1;
								when "010" => ry <= r2;
								when "011" => ry <= r3;
								when "100" => ry <= r4;
								when "101" => ry <= r5;
								when "110" => ry <= r6;
								when others => null;
							end case;
						when "00110"=>                       -------ADDIU
							case instructions(10 downto 8) is
                        when "000" => rx <= r0;
								when "001" => rx <= r1;
								when "010" => rx <= r2;
								when "011" => rx <= r3;
								when "100" => rx <= r4;
								when "101" => rx <= r5;
								when "110" => rx <= r6;
								when others => null;
							end case;
							if(instructions(7)='0')then
							imme <= "00000000" & instructions(7 downto 0);
							else
							imme <= "11111111" & instructions(7 downto 0);
							end if;
						when "00111"=>                       -------BNEZ
							case instructions(10 downto 8) is
                        when "000" => rx <= r0;
								when "001" => rx <= r1;
								when "010" => rx <= r2;
								when "011" => rx <= r3;
								when "100" => rx <= r4;
								when "101" => rx <= r5;
								when "110" => rx <= r6;
								when others => null;
							end case;
							if(instructions(7)='1')then
							imme <= "11111111" & instructions(7 downto 0) ;
							else
							imme <= "00000000" & instructions(7 downto 0) ;
							end if;
						when "01001"=>                       -------SLTI
							case instructions(10 downto 8) is
                        when "000" => rx <= r0;
								when "001" => rx <= r1;
								when "010" => rx <= r2;
								when "011" => rx <= r3;
								when "100" => rx <= r4;
								when "101" => rx <= r5;
								when "110" => rx <= r6;
								when others => null;
							end case;
							imme <= "00000000" & instructions(7 downto 0);
						when "01010"=>                       -------BTNEZ
							if(instructions(7)='1')then
							imme <= "11111111" & instructions(7 downto 0) -2;
							else
							imme <= "00000000" & instructions(7 downto 0);
							end if;
						when "01011"=>                       -------NOP
							NULL;
						when "01100"=>                       -------SLTU
							case instructions(10 downto 8) is
                        when "000" => rx <= r0;
								when "001" => rx <= r1;
								when "010" => rx <= r2;
								when "011" => rx <= r3;
								when "100" => rx <= r4;
								when "101" => rx <= r5;
								when "110" => rx <= r6;
								when others => null;
							end case;
							case instructions(7 downto 5) is
                        when "000" => ry <= r0;
								when "001" => ry <= r1;
								when "010" => ry <= r2;
								when "011" => ry <= r3;
								when "100" => ry <= r4;
								when "101" => ry <= r5;
								when "110" => ry <= r6;
								when others => null;
							end case;
						when "01101"=>                       -------MOVE
							case instructions(7 downto 5) is
                        when "000" => ry <= r0;
								when "001" => ry <= r1;
								when "010" => ry <= r2;
								when "011" => ry <= r3;
								when "100" => ry <= r4;
								when "101" => ry <= r5;
								when "110" => ry <= r6;
								when others => null;
							end case;	
						when others=>
							null;
						end case;
						state<=execute;
				when execute=>                                -------执行
					case instructions(15 downto 11)is
						when "00001"=>                       -------LI
							alu_out <= imme;
							led <= imme;
							state<=write_reg;
						when "00010"=>                       -------SLL
							if(imme /= "0000000000000000")then
								alu_out <= to_stdlogicvector(to_bitvector(ry) sll conv_integer(imme));
								led <= to_stdlogicvector(to_bitvector(ry) sll conv_integer(imme));
							else
								alu_out <= to_stdlogicvector(to_bitvector(ry) sll 8);
								led <= to_stdlogicvector(to_bitvector(ry) sll 8);
							end if;
							state<=write_reg;
						when "00011"=>                       -------LW
							alu_out <= rx + imme;
							led <= rx + imme;
							state<=mem_control;
						when "00100"=>                       -------SW
							alu_out <= rx + imme;
							led <= rx + imme;
							state<=mem_control;
						when "00101"=>                       -------ADDU
							alu_out <= rx + ry;
							led <= rx + ry;
							state<=write_reg;
						when "00110"=>                       -------ADDIU
							alu_out <= rx + imme;
							led <= rx + imme;
							state<=write_reg;
						when "00111"=>                       -------BNEZ
							if(rx /= "0000000000000000")then
								pc <= pc + imme;
								led <= pc + imme;
							end if;
							state<=instruction_fetch;                
						when "01001"=>                       -------SLTUI
							if(rx < imme)then
								alu_out <= "0000000000000001";
								led<="0000000000000001";
							else
								alu_out <= "0000000000000000";
								led<="0000000000000000";
							end if;
							state<=write_reg;
						when "01010"=>                       -------BTNEZ
							if(T /= "0000000000000000")then
								pc <= pc + imme;
								led <= pc + imme;
							end if;
							state<=instruction_fetch;                
						when "01011"=>                       -------NOP
							led <= r1;
							state<=instruction_fetch;                
						when "01100"=>                       -------SLTU
							if(rx<ry)then
								alu_out <= "0000000000000001";
								led<="0000000000000001";
							else
								alu_out <= "0000000000000000";
								led<="0000000000000000";
							end if;
							state<=write_reg;
						when "01101"=>                       -------MOVE
							alu_out <= ry;
							led <= ry;
							state<=write_reg;
						when others=> 
							NULL;
					end case;
				when mem_control=>                          -------访存
					case instructions(15 downto 11)is
						when "00011"=>                       -------LW
								if(status="000")then
									ram_en <= '0';
									ram_oe <= '1';
									ram_we <= '1';
									ram_addr<="00" & alu_out;
									led <= alu_out;
									ram_data<="ZZZZZZZZZZZZZZZZ";
									status<="001";
								elsif(status="001")then                       
									ram_en <= '0';
									ram_oe <= '0';
									ram_we <= '1';
									status<="010";
								elsif(status="010")then
									data<=ram_data;
									led<=ram_data;
									status<="000";
									state<=write_reg;
								end if;			
						when "00100"=>                       -------SW
								if(status="000")then
									ram_addr<="00" & alu_out;
									led <= ry;
									status<="001";
								elsif(status="001")then
									ram_data<=ry; 
									status<="010";
								elsif(status="010")then     
									ram_oe<='1';
									ram_we<='0'; 
									ram_en<='0';
									status<="011";
								elsif(status="011")then     
									ram_oe<='1'; 
									ram_we<='1'; 
									ram_en<='0'; 
									status<="000";
									state<=write_reg;
								end if;
						when others=>
							NULL;
					end case;
				when write_reg=>                             -------写回
					case instructions(15 downto 11)is
						when "00001"=>                       -------LI
							case instructions(10 downto 8) is
                        when "000" => r0 <= alu_out;
								when "001" => r1 <= alu_out;
								when "010" => r2 <= alu_out;
								when "011" => r3 <= alu_out;
								when "100" => r4 <= alu_out;
								when "101" => r5 <= alu_out;
								when "110" => r6 <= alu_out;
								when others => null;
							end case;
						when "00010"=>                       -------SLL
							case instructions(10 downto 8) is
                        when "000" => r0 <= alu_out;
								when "001" => r1 <= alu_out;
								when "010" => r2 <= alu_out;
								when "011" => r3 <= alu_out;
								when "100" => r4 <= alu_out;
								when "101" => r5 <= alu_out;
								when "110" => r6 <= alu_out;
								when others => null;
							end case;
						when "00011"=>                       -------LW
							case instructions(7 downto 5) is
                        when "000" => r0 <= data;
								when "001" => r1 <= data;
								when "010" => r2 <= data;
								when "011" => r3 <= data;
								when "100" => r4 <= data;
								when "101" => r5 <= data;
								when "110" => r6 <= data;
								when others => null;
							end case;
							led <= data;
						when "00100"=>                       -------SW
							led <= ram_data;
						when "00101"=>                       -------ADDU
							case instructions(4 downto 2) is
                        when "000" => r0 <= alu_out;
								when "001" => r1 <= alu_out;
								when "010" => r2 <= alu_out;
								when "011" => r3 <= alu_out;
								when "100" => r4 <= alu_out;
								when "101" => r5 <= alu_out;
								when "110" => r6 <= alu_out;
								when others => null;
							end case;
						when "00110"=>                       -------ADDIU
							case instructions(10 downto 8) is
                        when "000" => r0 <= alu_out;
								when "001" => r1 <= alu_out;
								when "010" => r2 <= alu_out;
								when "011" => r3 <= alu_out;
								when "100" => r4 <= alu_out;
								when "101" => r5 <= alu_out;
								when "110" => r6 <= alu_out;
								when others => null;
							end case;
						when "01001"=>                       -------SLTUI
							T <= alu_out;
							led <= alu_out;
						when "01011"=>                       -------NOP
							NULL;
						when "01100"=>                       -------SLTU
							T <= alu_out;
							led <= alu_out;
						when "01101"=>                       -------MOVE
							case instructions(10 downto 8) is
                        when "000" => r0 <= alu_out;
								when "001" => r1 <= alu_out;
								when "010" => r2 <= alu_out;
								when "011" => r3 <= alu_out;
								when "100" => r4 <= alu_out;
								when "101" => r5 <= alu_out;
								when "110" => r6 <= alu_out;
								when others => null;
							end case;
						when others=>
							null;
						end case;
						state<=instruction_fetch;                 -------重新取指
			end case;
		end if;
end process;
end Behavioral;

