with Logs;                         use Logs;
with Opt;
-- with Alog;                         use Alog;
-- with Ada.Streams;                  use Ada.Streams;
with Ada.Text_IO;
with GNAT.Serial_Communications;

package body Commands is

   Port_Full : aliased GNAT.Serial_Communications.Serial_Port;
   Port      : access GNAT.Serial_Communications.Serial_Port := Port_Full'Access;

   procedure Send (Arg : String)
   is
   begin
      String'Write(Port, Arg & ASCII.LF);
      Log_Info ("sent '"&Arg&''');
   end Send;

   procedure Send (Arg : String; Arg2 : String)
   is
      Args : constant String := Arg & ' ' & Arg2;
   begin
      String'Write(Port, Args & ASCII.LF);
      Log_Info ("sent '"&Args&''');
   end Send;

   procedure Send (Arg : String; Arg2 : String; Arg3 : String)
   is
      Args : constant String := Arg & ' ' & Arg2 & ' ' & Arg3;
   begin
      String'Write(Port, Args & ASCII.LF);
      Log_Info ("sent '"&Args&''');
   end Send;


   OK : constant String := "$> ";


   function Get_Line return String is
      NL : constant Character := ASCII.LF;
      C : Character;
      Buf : String (1..100);
      L  : Natural := 0;
      Cv : Natural;
   begin
      loop
         Character'Read (Port, C);
         if C = NL then return Buf(1..L);
         elsif L <= Buf'Last then
            L := L+1;
            Buf(L) := C;
            Cv := Character'Pos(C);
            -- Log_Debug (C & " " & L'Img & " " & Buf (1..L));
            exit when Buf (1..3) = OK;
         end if;
      end loop;
      return OK;
   end Get_Line;


   procedure Wait_For_Prompt is
   begin
      loop
         declare
            S : constant String := Get_Line;
         begin
            Log_Debug (S);
            exit when S = OK;
         end;
      end loop;
   end Wait_For_Prompt;


   procedure Open_Port is
      use GNAT.Serial_Communications;
   begin
      Open (Port_Full, Port_Name(Opt.Port_Name.all));
      Set (Port_Full, Opt.Baud);
      Log_Info ("opened port '"&Opt.Port_Name.all&"' at "&Opt.Baud'Img&".");
      Wait_For_Prompt;
   exception
   when Serial_Error =>
      Log_Error ("cannot open serial port " & Opt.Port_Name.all);
      raise;
   end Open_Port;


   procedure Act
   is
      Walk_Cmd    : constant String := "ow list s";
      Get_All_Cmd : constant String := "ow get *";
   begin
      Open_Port;
      if Opt.Get_Device_Tree then
         Send (Walk_Cmd);
         loop
            declare
               Resp : constant String := Get_Line;
            begin
               if Resp = Walk_Cmd then
                  null; -- ignore repeated command
               elsif Resp = OK then
                  exit;
               else
                  Ada.Text_IO.Put_Line (Resp);
               end if;
            end;
         end loop;
      elsif Opt.Get_All_Temps then
         Send (Walk_Cmd);
         Wait_For_Prompt;
         Send (Get_All_Cmd);
         loop
            declare
               Resp : constant String := Get_Line;
            begin
               if Resp = Get_All_Cmd then
                  null; -- ignore repeated command
               elsif Resp = OK then
                  exit;
               else
                  Ada.Text_IO.Put_Line (Resp);
               end if;
            end;
         end loop;
      elsif Opt.Get_Temp and then Opt.Device_Address.all /= "" then
         -- Send ("conv", Opt.Device_Address.all);
         -- delay 0.760;
         Send ("ow get", Opt.Device_Address.all);
         if Opt.Verbosity_Level > Opt.Verbose then
            Send ("ow read scratchpad", Opt.Device_Address.all);
         end if;
         null;
      end if;
   end Act;

end Commands;
