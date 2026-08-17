unit createplaylistform;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus, Cod.Forms;

type

  { TCreatePlaylist }

  TCreatePlaylist = class(TForm)
    Button2: TButton;
    Image1: TImage;
    Playlist_Description: TMemo;
    Playlist_Name: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Save_Button: TButton;
    Title: TLabel;
    procedure Button2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  CreatePlaylist: TCreatePlaylist;

implementation

{$R *.lfm}

{ TCreatePlaylist }

procedure TCreatePlaylist.Button2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Playlist_Name.Text = '' then
    begin
      MessageDlg('The playlist name cannot be empty', mtWarning, [mbOk], 0);
      Exit;
    end;

  ModalResult := mrOk;
end;

procedure TCreatePlaylist.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  CenterFormInForm(Self, Application.MainForm);
  {$ENDIF}
end;

end.

