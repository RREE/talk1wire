with Alog;                         use Alog;
with Alog.Logger;

package Logs with Elaborate_Body is

   L : Logger.Instance (Init => True);

   procedure Log_Debug  (Msg : String; Source : String := "");
   procedure Log_Info   (Msg : String; Source : String := "");
   procedure Log_Notice (Msg : String; Source : String := "");
   procedure Log_Error  (Msg : String; Source : String := "");
end Logs;
