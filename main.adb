--
-- Talk 1-wire
--
-- PC program for talking to 1-wire clients on a serial line
--

with Opt;
with Commands;

procedure Main is
begin
   Opt.Set_Options;
   if not (Opt.Verbosity_Level = Opt.Quiet) then
      Opt.Show_Greeting;
   end if;
   Commands.Act;
end Main;
