with Gtk.Builder; use Gtk.Builder;
with Gtk.Widget;  use Gtk.Widget;
with Gtk.Enums;

with Gtk.Container;           use Gtk.Container;
with Gtk.Button;              use Gtk.Button;
with Gtk.File_Chooser_Button; use Gtk.File_Chooser_Button;

package Startup_Callbacks is

   Builder : access Gtk_Builder;

   procedure Quit (Self   : access Gtk_Container_Record'Class;
                   Object : not null access Gtk_Widget_Record'Class);

   procedure SMTP_Change (Self  : access Gtk_Widget_Record'Class;
                          State : Gtk.Enums.Gtk_State_Type);
   procedure IMAP_Change (Self  : access Gtk_Widget_Record'Class;
                          State : Gtk.Enums.Gtk_State_Type);
   procedure POP3_Change (Self  : access Gtk_Widget_Record'Class;
                          State : Gtk.Enums.Gtk_State_Type);

   procedure Post_Office (Self  : access Gtk_File_Chooser_Button_Record'Class);

   procedure Start_Server (Self : access Gtk_Button_Record'Class);

end Startup_Callbacks;
