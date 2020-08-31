library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity RWMEM is
  generic(
      file_path: string;
      file_path_init: string;
      Data_size : natural := 32;
      Instr_size: natural := 32;
      RAM_DEPTH:  natural := 128
    );
  port (
      CLK             : in std_logic;
      RST             : in std_logic;
      ADDR            : in std_logic_vector(Instr_size - 1 downto 0);
      ENABLE          : in std_logic;
      READNOTWRITE    : in std_logic;
      DATA_IN         : in std_logic_vector(Data_size-1 downto 0);
      DATA_READY      : out std_logic;
      DATA_OUT        : out std_logic_vector(Data_size-1 downto 0)
    );
end RWMEM;

architecture behavioral of RWMEM is
  type DRAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(instr_size - 1 downto 0);
  signal DRAM_mem : DRAMtype;
  signal tmp_data: std_logic_vector(Data_size - 1 downto 0);
  signal int_data_ready, mem_ready: std_logic;

  procedure rewrite_contenent(data: in DRAMtype; file_path: string) is
    variable index: natural range 0 to RAM_DEPTH;
    file wr_file: text;
    variable line_in: line;
  begin
    index:=0;
    file_open(wr_file, file_path, WRITE_MODE);
    while index < RAM_DEPTH loop
      hwrite(line_in, data(index));
      writeline(wr_file, line_in);
      index := index + 1;
    end loop;
  end rewrite_contenent;

begin  -- behavioral

  --write_process
  WR_PROCESS:
  process (CLK, RST, READNOTWRITE)
    file mem_fp: text;
    variable index: integer range 0 to RAM_DEPTH;
    variable file_line : line;
    variable tmp_data_u : std_logic_vector(INSTR_SIZE-1 downto 0);
  begin  -- process
    if RST = '0' then    -- asynchronous reset (active low)
      file_open(
        mem_fp,
        file_path_init,
        READ_MODE
      );

      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        DRAM_mem(index) <= tmp_data_u;
        index := index + 1;
        if (index = RAM_DEPTH) then
          exit;
        end if;
      end loop;

      file_close(mem_fp);

      int_data_ready <= '0';
      mem_ready <= '0';
    elsif CLK'event and CLK = '0' then  -- rising clock edge
      if(ENABLE = '1') then
        if (READNOTWRITE = '0') then -- write
            DRAM_Mem(to_integer(unsigned(ADDR))) <= DATA_IN(Instr_size - 1 downto 0);
            MEM_READY <= '1';
        else -- read
            TMP_DATA <= DRAM_mem(to_integer(unsigned(ADDR)));
            int_data_ready <= '1';
        end if;
      else
        mem_ready <= '0';
        int_data_ready <= '0';
      end if;
    end if;
  end process;

  rewrite_contenent(DRAM_mem, file_path); -- refresh the file
  -- DATA_OUT <= tmp_data; --when int_data_ready = '1' else (others=>'Z'); -- to cache
  DATA_OUT <= tmp_data when int_data_ready = '1' else (others=>'Z');
  DATA_READY <= int_data_ready or mem_ready;

end behavioral;
