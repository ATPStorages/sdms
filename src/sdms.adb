pragma Ada_2022;

with Gtk;            use Gtk;
with Gtk.Main;
with Gtk.Widget;     use Gtk.Widget;
with Gtk.Builder;    use Gtk.Builder;

with Gtk.Window;              use Gtk.Window;
with Gtk.Button;              use Gtk.Button;
with Gtk.GEntry;              use Gtk.GEntry;
with Gtk.File_Chooser_Button; use Gtk.File_Chooser_Button;

with Startup_Callbacks;

procedure Sdms is
   Builder : aliased Gtk_Builder;

   discard : Boolean;
begin
   Gtk.Main.Init;

   Gtk.Builder.Gtk_New_From_File (Builder, "sdms_setup.glade");

   declare
      Startup_Window : constant Gtk_Window :=
        Gtk_Window (Get_Object (Builder, "startup_window"));

      SMTP_Entry : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder, "smtp"));
      IMAP_Entry : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder, "imap"));
      POP3_Entry : constant Gtk_Entry :=
        Gtk_Entry (Get_Object (Builder, "pop3"));

      Post_Office_Entry : constant Gtk_File_Chooser_Button :=
        Gtk_File_Chooser_Button (Get_Object (Builder, "post_office"));

      Start_Server_Button : constant Gtk_Button :=
        Gtk_Button (Get_Object (Builder, "start_server"));
   begin
      Startup_Callbacks.Builder := Builder'Access;

      Startup_Window.On_Remove (Startup_Callbacks.Quit'Access,
                                After => True);

      SMTP_Entry.On_State_Changed (Startup_Callbacks.SMTP_Change'Access,
                                   After => False);
      IMAP_Entry.On_State_Changed (Startup_Callbacks.IMAP_Change'Access,
                                   After => False);
      POP3_Entry.On_State_Changed (Startup_Callbacks.POP3_Change'Access,
                                   After => False);

      Post_Office_Entry.On_File_Set (Startup_Callbacks.Post_Office'Access,
                                     After => False);

      Start_Server_Button.On_Clicked (Startup_Callbacks.Start_Server'Access,
                                      After => True);

      Gtk.Widget.Show_All (Gtk_Widget (Startup_Window));
   end;

   Gtk.Main.Main;
   Unref (Builder);

end Sdms;

--  procedure Sdms is
--     Receiver   : GNAT.Sockets.Socket_Type;
--
--     type Socket_Access is access all GNAT.Sockets.Socket_Type;
--
--     task type Client_Connection (Channel    : GNAT.Sockets.Stream_Access;
--                                  Connection : Socket_Access);
--
--     type Task_Access is access Client_Connection;
--
--     task body Client_Connection
--     is
--     begin
--        --
--        GNAT.Sockets.Close_Socket (Connection.all);
--     end Client_Connection;
--  begin
--     GNAT.Sockets.Create_Socket (Socket => Receiver);
--     GNAT.Sockets.Set_Socket_Option
--       (Socket => Receiver,
--        Level  => GNAT.Sockets.Socket_Level,
--        Option => (Name    => GNAT.Sockets.Reuse_Address, Enabled => True));
--     GNAT.Sockets.Bind_Socket
--       (Socket  => Receiver,
--        Address => (Family => GNAT.Sockets.Family_Inet,
--                    Addr   => GNAT.Sockets.Inet_Addr ("127.0.0.1"),
--                    Port   => 25565));
--     GNAT.Sockets.Listen_Socket (Socket => Receiver);
--     loop
--        declare
--           discard : Task_Access;
--
--           Channel    : GNAT.Sockets.Stream_Access;
--           Connection : aliased GNAT.Sockets.Socket_Type;
--           Client     : GNAT.Sockets.Sock_Addr_Type;
--        begin
--           GNAT.Sockets.Accept_Socket
--             (Server  => Receiver,
--              Socket  => Connection,
--              Address => Client);
--           Ada.Text_IO.Put_Line
--             ("Client connected from " & GNAT.Sockets.Image (Client));
--           Channel := GNAT.Sockets.Stream (Connection);
--           discard := new Client_Connection (Channel,
--                                             Connection'Unchecked_Access);
--        end;
--     end loop;
--  end Sdms;
