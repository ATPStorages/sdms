pragma Ada_2022;

with Gtk;            use Gtk;
with Gtk.Main;
with Gtk.Widget;     use Gtk.Widget;
with Gtk.Builder;    use Gtk.Builder;

with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;

with Startup_Callbacks;

procedure Sdms is

   Builder : Gtk_Builder;
begin
   Gtk.Main.Init;

   Gtk.Builder.Gtk_New_From_File (Builder, "sdms_setup.glade");

   declare
      Startup_Window : constant Gtk_Window :=
        Gtk_Window (Get_Object (Builder, "startup_window"));
      Start_Server_Button : constant Gtk_Button :=
        Gtk_Button (Get_Object (Builder, "start_server"));
   begin
      Startup_Window.On_Remove (Startup_Callbacks.Quit'Access,
                                After => True);
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
