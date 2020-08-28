package functions is
  function log2(i : natural)
    return integer;

    function pow2(i : natural)
      return integer;
end functions;
--------------------------------------------------------------------------------
package body functions is
  ------------------------------------------------------------------------------
  function log2(i : natural) return integer is
    variable temp    : integer := i;
    variable ret_val : integer := 1; --log2 of 0 should equal 1 because you still need 1 bit to represent 0

  begin

    if i = 0 then

      return ret_val;

    else

      while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
      end loop;

      return ret_val - 1;
    end if;

  end function;
  ------------------------------------------------------------------------------
  function pow2(i : natural) return integer is
    variable temp    : integer := 0;
    variable ret_val : integer := 1;

  begin

    while temp < i loop
      temp    := temp + 1;
      ret_val := ret_val * 2;
    end loop;

    return ret_val;

  end function;
  ------------------------------------------------------------------------------
end functions;
