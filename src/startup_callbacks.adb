with Ada.Text_IO;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Characters.Latin_1;  use Ada.Characters.Latin_1;

with Glib; use Glib;

with Gtk.Main;

with Gtk.GEntry;       use Gtk.GEntry;
with Gtk.Check_Button; use Gtk.Check_Button;

package body Startup_Callbacks is

   procedure Quit (Self   : access Gtk_Container_Record'Class;
                   Object : not null access Gtk_Widget_Record'Class)
   is
      pragma Unreferenced (Object, Self);
   begin
      Gtk.Main.Main_Quit;
   end Quit;

   SMTP_Set, MTP_Set, PO_Set : Boolean;

   procedure Ensure_OK_To_Start
   is
      Start_Server_Button : constant Gtk_Button :=
        Gtk_Button (Get_Object (Builder.all, "start_server"));
   begin
      Start_Server_Button.Set_Sensitive (SMTP_Set and MTP_Set and PO_Set);
   end Ensure_OK_To_Start;

   procedure Force_Digits (Text : in out String)
   is
   begin
      for I in Text'Range loop
         if not Is_Digit (Text (I)) then
            Text (I) := NUL;
         end if;
      end loop;
   end Force_Digits;

   procedure SMTP_Change (Self  : access Gtk_Widget_Record'Class;
                          State : Gtk.Enums.Gtk_State_Type)
   is
      pragma Unreferenced (State);

      GEntry    : constant Gtk_Entry := Gtk_Entry (Self);
      Rewritten : String := GEntry.Get_Text;

      TLS_Check : constant Gtk_Check_Button :=
        Gtk_Check_Button (Get_Object (Builder.all, "smtp_tls"));
   begin
      Force_Digits (Rewritten);
      GEntry.Set_Text (Rewritten);
      SMTP_Set := GEntry.Get_Text_Length > 0;
      TLS_Check.Set_Sensitive (SMTP_Set);
      if not SMTP_Set then
         TLS_Check.Set_Active (False);
      end if;
      Ensure_OK_To_Start;
   end SMTP_Change;

   procedure IMAP_Change (Self  : access Gtk_Widget_Record'Class;
                          State : Gtk.Enums.Gtk_State_Type)
   is
      pragma Unreferenced (State);

      GEntry    : constant Gtk_Entry := Gtk_Entry (Self);
      Rewritten : String := GEntry.Get_Text;

      POP3_Check : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder.all, "pop3"));
      TLS_Check : constant Gtk_Check_Button :=
        Gtk_Check_Button (Get_Object (Builder.all, "imap_tls"));
   begin
      Force_Digits (Rewritten);
      GEntry.Set_Text (Rewritten);
      declare
         Local_OK : constant Boolean := GEntry.Get_Text_Length > 0;
      begin
         MTP_Set :=
           Local_OK or else
           POP3_Check.Get_Text_Length > 0;
         TLS_Check.Set_Sensitive (Local_OK);
         if not Local_OK then
            TLS_Check.Set_Active (False);
         end if;
      end;
      Ensure_OK_To_Start;
   end IMAP_Change;

   --  Look into using generics

   procedure POP3_Change (Self  : access Gtk_Widget_Record'Class;
                          State : Gtk.Enums.Gtk_State_Type)
   is
      pragma Unreferenced (State);

      GEntry    : constant Gtk_Entry := Gtk_Entry (Self);
      Rewritten : String := GEntry.Get_Text;

      IMAP_Check : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder.all, "imap"));
      TLS_Check : constant Gtk_Check_Button :=
        Gtk_Check_Button (Get_Object (Builder.all, "pop3_tls"));
   begin
      Force_Digits (Rewritten);
      GEntry.Set_Text (Rewritten);
      declare
         Local_OK : constant Boolean := GEntry.Get_Text_Length > 0;
      begin
         MTP_Set :=
           Local_OK or else
           IMAP_Check.Get_Text_Length > 0;
         TLS_Check.Set_Sensitive (Local_OK);
         if not Local_OK then
            TLS_Check.Set_Active (False);
         end if;
      end;
      Ensure_OK_To_Start;
   end POP3_Change;

   procedure Post_Office (Self  : access Gtk_File_Chooser_Button_Record'Class)
   is
   begin
      PO_Set := Self.Get_Filename'Length > 0;
      Ensure_OK_To_Start;
   end Post_Office;

   procedure Start_Server (Self : access Gtk_Button_Record'Class)
   is
      pragma Unreferenced (Self);

      Post_Office_Selection : constant Gtk_File_Chooser_Button :=
        Gtk_File_Chooser_Button (Get_Object (Builder.all, "post_office"));
   begin
      Ada.Text_IO.Put_Line (Post_Office_Selection.Get_Filename);
   end Start_Server;

end Startup_Callbacks;
