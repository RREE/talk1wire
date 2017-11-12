--                                                                    --
--  package                         Copyright (c)  Dmitry A. Kazakov  --
--     ODBC.API.Links                              Luebeck            --
--  Implementation                                 Autumn, 2012       --
--                                                                    --
--                                Last revision :  11:56 13 Oct 2012  --
--                                                                    --
--  This  library  is  free software; you can redistribute it and/or  --
--  modify it under the terms of the GNU General Public  License  as  --
--  published by the Free Software Foundation; either version  2  of  --
--  the License, or (at your option) any later version. This library  --
--  is distributed in the hope that it will be useful,  but  WITHOUT  --
--  ANY   WARRANTY;   without   even   the   implied   warranty   of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  --
--  General  Public  License  for  more  details.  You  should  have  --
--  received  a  copy  of  the GNU General Public License along with  --
--  this library; if not, write to  the  Free  Software  Foundation,  --
--  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.    --
--                                                                    --
--  As a special exception, if other files instantiate generics from  --
--  this unit, or you link this unit with other files to produce  an  --
--  executable, this unit does not by  itself  cause  the  resulting  --
--  executable to be covered by the GNU General Public License. This  --
--  exception  does not however invalidate any other reasons why the  --
--  executable file might be covered by the GNU Public License.       --
--____________________________________________________________________--

with Ada.Exceptions;      use Ada.Exceptions;
with Ada.IO_Exceptions;   use Ada.IO_Exceptions;
with ODBC.API.Keys.Edit;  use ODBC.API.Keys.Edit;

package body ODBC.API.Links is

   procedure Create_Table
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Data_Type  : String
             )  is
   begin
      if not Table_Exists (Command.Connection, Table_Name) then
         Execute
         (  Command,
            (  "CREATE TABLE "
            &  Table_Name
            &  " (dependant "
            &  Data_Type
            &  ", referent "
            &  Data_Type
            &  ")"
         )  );
      end if;
   exception
      when Error : others =>
         Raise_Exception
         (  Data_Error'Identity,
            Exception_Message (Error)
         );
   end Create_Table;

   procedure Delete
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Object     : Object_ID
             )  is
   begin
      Execute
      (  Command,
         (  "DELETE FROM "
         &  Table_Name
         &  " WHERE dependant ="
         &  Image (Object)
         &  " OR referent ="
         &  Image (Object)
      )  );
   exception
      when End_Error =>
         null;
      when Error : others =>
         Raise_Exception
         (  Data_Error'Identity,
            Exception_Message (Error)
         );
   end Delete;

   function Depends_On
            (  Command    : access ODBC_Command'Class;
               Table_Name : String;
               Dependant  : Object_ID;
               Referent   : Object_ID
            )  return Boolean is
   begin
      Execute
      (  Command.all,
         (  "SELECT dependant FROM "
         &  Table_Name
         &  " WHERE dependant ="
         &  Image (Dependant)
         &  " AND referent ="
         &  Image (Referent)
      )  );
      Fetch (Command.all);
      Close_Cursor (Command.all);
      return True;
   exception
      when End_Error =>
         Close_Cursor (Command.all);
         return False;
   end Depends_On;

   procedure Get_Set
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Key_Name   : String;
                Data_Name  : String;
                Key_Value  : Object_ID;
                Data_Set   : in out Keys.Sets.Set
             )  is
      Data_ID : aliased Object_ID;
   begin
      Prepare
      (  Command,
         (  "SELECT "
         &  Data_Name
         &  " FROM "
         &  Table_Name
         &  " WHERE "
         &  Key_Name
         &  " ="
         &  Image (Key_Value)
      )  );
      Bind_Result
      (  Command,
         1,
         Data_ID'Unchecked_Access
      );
      Execute (Command);
      loop
         Fetch (Command);
         if Key_Value /= Data_ID then
            Add (Data_Set, Data_ID);
         end if;
      end loop;
   exception
      when End_Error =>
         Close_Cursor (Command);
      when others =>
         Close_Cursor (Command);
         raise;
   end Get_Set;

   procedure Get_Dependants
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Referent   : Object_ID;
                Dependants : in out Keys.Sets.Set
             )  is
   begin
      Get_Set
      (  Command    => Command,
         Table_Name => Table_Name,
         Key_Name   => "referent",
         Data_Name  => "dependant",
         Key_Value  => Referent,
         Data_Set   => Dependants
      );
   end Get_Dependants;

   procedure Get_References
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Dependant  : Object_ID;
                Referents  : in out Keys.Sets.Set
             )  is
   begin
      Get_Set
      (  Command    => Command,
         Table_Name => Table_Name,
         Key_Name   => "dependant",
         Data_Name  => "referent",
         Key_Value  => Dependant,
         Data_Set   => Referents
      );
   end Get_References;

   procedure Get_References
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Dependant  : Object_ID;
                Referents  : in out Unbounded_Array;
                Pointer    : in out Integer
             )  is
      Data_ID : aliased Object_ID;
   begin
      Prepare
      (  Command,
         (  "SELECT referent FROM "
         &  Table_Name
         &  " WHERE dependant ="
         &  Image (Dependant)
      )  );
      Bind_Result
      (  Command,
         1,
         Data_ID'Unchecked_Access
      );
      Execute (Command);
      loop
         Fetch (Command);
         if Data_ID /= Dependant then
            Put (Referents, Pointer, Data_ID);
            Pointer := Pointer + 1;
         end if;
      end loop;
   exception
      when End_Error =>
         Close_Cursor (Command);
      when others =>
         Close_Cursor (Command);
         raise;
   end Get_References;

   function Has_Dependants
            (  Command    : access ODBC_Command'Class;
               Table_Name : String;
               Referent   : Object_ID
            )  return Boolean is
   begin
      Execute
      (  Command.all,
         (  "SELECT * FROM "
         &  Table_Name
         &  " WHERE referent ="
         &  Image (Referent)
      )  );
      loop
         Fetch (Command.all);
         if Referent /= Get_Data (Command, 1, Never) then
            Close_Cursor (Command.all);
            return True;
         end if;
      end loop;
   exception
      when End_Error =>
         Close_Cursor (Command.all);
         return False;
      when others =>
         Close_Cursor (Command.all);
         raise;
   end Has_Dependants;

   procedure Reference
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Dependant  : Object_ID;
                Referent   : Object_ID
             )  is
   begin
      if not Depends_On
             (  Command'Unchecked_Access,
                Table_Name,
                Dependant,
                Referent
             )
      then
         Execute
         (  Command,
            (  "INSERT INTO "
            &  Table_Name
            &  " VALUES ("
            &  Image (Dependant)
            &  ", "
            &  Image (Referent)
            &  ")"
         )  );
      end if;
   end Reference;

   procedure Unreference
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Dependant  : Object_ID;
                Referent   : Object_ID
             )  is
   begin
      Execute
      (  Command,
         (  "DELETE FROM "
         &  Table_Name
         &  " WHERE dependant ="
         &  Image (Dependant)
         &  " AND Referent = "
         &  Image (Referent)
      )  );
   end Unreference;

   procedure Unreference
             (  Command    : in out ODBC_Command'Class;
                Table_Name : String;
                Dependant  : Object_ID
             )  is
   begin
      Execute
      (  Command,
         (  "DELETE FROM "
         &  Table_Name
         &  " WHERE dependant ="
         &  Image (Dependant)
      )  );
   end Unreference;

end ODBC.API.Links;
