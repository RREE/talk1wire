with GNAT.Strings;                 use GNAT.Strings;
with GNAT.Serial_Communications;

package Opt is

   package Ser renames GNAT.Serial_Communications;

   Config_File_Name : aliased String_Access := new String'(".talk1wire.cfg");
   Logfile_Name     : aliased String_Access := new String'("talk1wire.log");
   Port_Name        : aliased String_Access := new String'("com1");
   Baud_Str         : aliased String_Access := new String'("19200");
   Baud             : Ser.Data_Rate := Ser.B19200;
   Device_Address   : aliased String_Access := new String'("");
   Get_Device_Tree  : aliased Boolean       := False;
   Get_Temp         : aliased Boolean       := False;
   Get_All_Temps    : aliased Boolean       := False;
   Get_Scratchpad   : aliased Boolean       := False;
   Fahrenheit       : aliased Boolean       := False;
   Set_Comment      : aliased String_Access := new String'("");


   subtype Verbosity_Level_Range is Natural range 0 .. 3;
   Quiet           : constant Verbosity_Level_Range := 0;
   Standard        : constant Verbosity_Level_Range := 1;
   Verbose         : constant Verbosity_Level_Range := 2;
   Debug           : constant Verbosity_Level_Range := 3;
   Verbosity_Level : aliased Integer := Standard;

   procedure Set_Options;
   procedure Show_Greeting;
end Opt;
