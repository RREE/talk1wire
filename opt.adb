with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Text_IO;                  use Ada.Text_IO;
with GNAT.Command_Line;            use GNAT.Command_Line;
-- with GNAT.Exception_Traces;
with Ada.Text_IO;                  use Ada.Text_IO;
-- with Ada.Exceptions;               use Ada.Exceptions;
with Alog;                         use Alog;
with Alog.Policy_DB;               use Alog.Policy_DB;
with Logs;                         use Logs;

package body Opt is

   --  Config_File_Name : aliased String_Access := new String'(".talk1wire.cfg");
   --  Logfile_Name     : aliased String_Access := new String'("talk1wire.log");
   --  Port_Name        : aliased String_Access := new String'("com1");
   --  Baud             : aliased Natural := 19200;
   --  Walk_Device_Tree : aliased Boolean;

   --  subtype Verbosity_Level_Range is Natural range 0 .. 3;
   --  Quiet           : constant Verbosity_Level_Range := 0;
   --  Standard        : constant Verbosity_Level_Range := 1;
   --  Verbose         : constant Verbosity_Level_Range := 2;
   --  Debug           : constant Verbosity_Level_Range := 3;
   --  Verbosity_Level : aliased Verbosity_Level_Range  := Standard;

   Cfg : Command_Line_Configuration;

   procedure Set_Options
   is
   begin
      Define_Switch (Cfg, Config_File_Name'Access, "-c:",
                     Long_Switch => "--config=",
                     Argument    => "<filename>",
                     Help        => "filename of the config file (default: .talk1wire).");

      Define_Switch (Cfg, Logfile_Name'Access, "-l:",
                     Long_Switch => "--logfile=",
                     Argument    => "<filename>",
                     Help        => "filename of the logfile (default: stdout).");

      Define_Switch (Cfg, Port_Name'Access, "-p:",
                     Long_Switch => "--port=",
                     Argument    => "<serial port>",
                     Help        => "name of the serial port (default: com1).");

      Define_Switch (Cfg, Baud_Str'Access, "-b:",
                     Long_Switch => "--baud=",
                     Argument    => "<baud rate>",
                     Help        => "baud rate of the serial communication (default: 19200).");

      Define_Switch (Cfg, Device_Address'Access, "-d:",
                     Long_Switch => "--device=",
                     Argument    => "<1w-address>",
                     Help        => "1-wire address.");

      Define_Switch (Cfg, Get_Device_Tree'Access, "-w",
                     Long_Switch => "--walk",
                     Help        => "walk the full device tree.");

      Define_Switch (Cfg, Get_Temp'Access, "-t",
                     Long_Switch => "--get-temperature",
                     Help        => "read temperature from 1-wire address.");

      Define_Switch (Cfg, Get_All_Temps'Access, "-a",
                     Long_Switch => "--all",
                     Help        => "get temperature from all devices.");

      Define_Switch (Cfg, Get_Scratchpad'Access, "-s",
                     Long_Switch => "--scratchpad",
                     Help        => "show scratchpad of device.");

      Define_Switch (Cfg, Fahrenheit'Access, "-F",
                     Long_Switch => "--fahrenheit",
                     Help        => "print (or read) all temperatures in Fahrenheit.");

      Define_Switch (Cfg, Verbosity_Level'Access, "-v?",
                     Long_Switch => "--verbose?",
                     Initial     => 1,
                     Default     => 1,
                     Argument    => "INT",
                     Help        => "Verbosity level: 0: quiet, 1: normal, 2: verbose, 3: debug");

      Define_Switch (Cfg, Get_Device_Tree'Access, "-w",
                     Long_Switch => "--walk",
                     Help        => "walk the full device tree.");

      Define_Switch (Cfg, "-h", Long_Switch => "--help", Help => "show this text");
      Set_Usage (Cfg,
                 Usage => "[switches]",
                 Help  => "help text to be written.");

      Getopt (Cfg);


      --
      -- check valid option ranges and convert to the target type
      --

      case Verbosity_Level is
      when Integer'First .. -1 | 4 .. Integer'Last =>
         Display_Help (Cfg);
         raise Stop with "verbosity out of range";
      when 0 => Set_Default_Loglevel (Level => Error);      Set_Loglevel ("*", Level => Error);
      when 1 => Set_Default_Loglevel (Level => Notice);     Set_Loglevel ("*", Level => Notice);
      when 2 => Set_Default_Loglevel (Level => Info);       Set_Loglevel ("*", Level => Info);
      when 3 => Set_Default_Loglevel (Level => Alog.Debug); Set_Loglevel ("*", Level => Alog.Debug);
      end case;

      Get_Baud_Rate:
      declare
         use GNAT.Serial_Communications;
         B : constant String := "B" & Baud_Str.all;
      begin
         Baud := Data_Rate'Value (B);
      exception
         when Constraint_Error => Baud := B19200;
      end Get_Baud_Rate;

      L.Log_Message (Alog.Debug,
                     "options set to" & ASCII.LF &
                       "configfile  : " & Config_File_Name.all & ASCII.LF &
                       "logfile     : " & Logfile_Name.all & ASCII.LF &
                       "port        : " & Port_Name.all & ASCII.LF &
                       "baud        : " & Baud'Img & ASCII.LF &
                       "walk devs   : " & Get_Device_Tree'Img & ASCII.LF &
                       "verbosity   :" & Verbosity_Level'Img & ASCII.LF);
   exception
   when GNAT.Command_Line.Exit_From_Command_Line => null;
   when Error : GNAT.Command_Line.Invalid_Switch =>
      L.Log_Message (Alog.Error, "invalid switch");
      Ada.Text_IO.Put_Line (Standard_Error, "invalid switch");
      Display_Help (Cfg);
      Set_Exit_Status (Failure);
      raise Stop;
   end Set_Options;


   procedure Show_Greeting
   is
      use Ada.Text_IO;
   begin
      Put_Line ("talk1wire: simple program to talk to 1-wire temperature sensors.");
   end Show_Greeting;

end Opt;
