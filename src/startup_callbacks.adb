with Ada.Exceptions;
with Ada.Strings.Unbounded;   use Ada.Strings.Unbounded;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Characters.Latin_1;  use Ada.Characters.Latin_1;

with GNAT.Sockets;
with Glib; use Glib;

with Gtk.Main;

with Gtk.Label;        use Gtk.Label;
with Gtk.GEntry;       use Gtk.GEntry;
with Gtk.Window;       use Gtk.Window;
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

   procedure Setup_Socket (Receiver : in out GNAT.Sockets.Socket_Type;
                           Port : GNAT.Sockets.Port_Type;
                           Error : out Unbounded_String)
   is
   begin
      GNAT.Sockets.Create_Socket (Socket => Receiver);
      GNAT.Sockets.Set_Socket_Option
        (Socket => Receiver,
         Level  => GNAT.Sockets.Socket_Level,
         Option => (Name => GNAT.Sockets.Reuse_Address, Enabled => True));
      GNAT.Sockets.Bind_Socket
        (Socket  => Receiver,
         Address => (Family => GNAT.Sockets.Family_Inet,
                     Addr   => GNAT.Sockets.Inet_Addr ("127.0.0.1"),
                     Port   => Port));
      GNAT.Sockets.Listen_Socket (Socket => Receiver);
   exception
      when E : GNAT.Sockets.Socket_Error =>
         Error := To_Unbounded_String (Ada.Exceptions.Exception_Message (E));
   end Setup_Socket;

   procedure Attach_Dialog_Close (Self : access Gtk_Builder_Record'Class)
   is
   begin
      Dialog.Response (0);
   end Attach_Dialog_Close;

   procedure Start_Server (Self : access Gtk_Button_Record'Class)
   is
      pragma Unreferenced (Self);

      Startup_Window : constant Gtk_Window :=
        Gtk_Window (Get_Object (Builder.all, "startup_window"));
      Management_Window : constant Gtk_Window :=
        Gtk_Window (Get_Object (Builder.all, "server_management_window"));

      Post_Office_Selection : constant Gtk_File_Chooser_Button :=
        Gtk_File_Chooser_Button (Get_Object (Builder.all, "post_office"));

      Error_Message : Unbounded_String;

      SMTP_Check : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder.all, "smtp"));
      SMTP_Receiver : GNAT.Sockets.Socket_Type;

      IMAP_Check : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder.all, "imap"));
      IMAP_Receiver : GNAT.Sockets.Socket_Type;

      POP3_Check : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder.all, "pop3"));
      POP3_Receiver : GNAT.Sockets.Socket_Type;

      discard : Gtk_Response_Type;
   begin

      declare
         Error : Unbounded_String;
      begin
         Setup_Socket (SMTP_Receiver,
                       GNAT.Sockets.Port_Type'Value (SMTP_Check.Get_Text),
                       Error);
         if Error.Length > 0 then
            Error_Message := "[SMTP] " & Error & LF;
         end if;
      end;

      if IMAP_Check.Get_Text_Length > 0 then
         declare
            Error : Unbounded_String;
         begin
            Setup_Socket (IMAP_Receiver,
                          GNAT.Sockets.Port_Type'Value (IMAP_Check.Get_Text),
                          Error);
            if Error.Length > 0 then
               Error_Message := @ & "[IMAP] " & Error & LF;
            end if;
         end;
      end if;

      if POP3_Check.Get_Text_Length > 0 then
         declare
            Error : Unbounded_String;
         begin
            Setup_Socket (POP3_Receiver,
                          GNAT.Sockets.Port_Type'Value (POP3_Check.Get_Text),
                          Error);
            if Error.Length > 0 then
               Error_Message := @ & "[POP3] " & Error & LF;
            end if;
         end;
      end if;

      if Error_Message.Length > 0 then
         declare
            Error_Window : constant Gtk_Dialog :=
              Gtk_Dialog (Get_Object (Builder.all, "startup_dialog_error"));
            Error_Text : constant Gtk_Label :=
              Gtk_Label (Get_Object (Builder.all, "dialog_message"));
            Error_OK : constant Gtk_Button :=
              Gtk_Button (Get_Object (Builder.all, "dialog_ok"));

            procedure Error_Ok_Cb is new Attach_Dialog_Close (Error_Window);
         begin
            SMTP_Receiver.Close_Socket;
            IMAP_Receiver.Close_Socket;
            POP3_Receiver.Close_Socket;

            Error_OK.On_Clicked (Error_Ok_Cb'Access,
                                 After => True);
            Error_Text.Set_Text (To_String (Error_Message));
            discard := Error_Window.Run;
         end;
      end if;
   end Start_Server;

end Startup_Callbacks;
