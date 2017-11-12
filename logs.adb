with Alog;                         use Alog;
-- with Alog.Facilities;
with Alog.Logger;                  use Alog.Logger;

package body Logs is
--   Nr_Fac : constant Natural := L.Facility_Count;
--   F : constant Facilities.Class := Dfdf;

   procedure Log_Debug  (Msg : String; Source : String := "")
   is begin
      Log_Message (L, Debug, Msg, Source);
   end Log_Debug;

   procedure Log_Info   (Msg : String; Source : String := "")
   is begin
      Log_Message (L, Info, Msg, Source);
   end Log_Info;

   procedure Log_Notice (Msg : String; Source : String := "")
   is begin
      Log_Message (L, Notice, Msg, Source);
   end Log_Notice;

   procedure Log_Error  (Msg : String; Source : String := "")
   is begin
      Log_Message (L, Warning, Msg, Source);
   end Log_Error;

begin
   --   F.Toggle_Write_Loglevel (State => True);
   null;
end Logs;
