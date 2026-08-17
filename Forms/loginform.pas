unit loginform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus, BroadcastAPI, Cod.Forms, Cod.SysUtils;

type

  { TLogin }

  TLogin = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Popup_Extra: TPopupMenu;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Separator1: TMenuItem;
    procedure Button1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private

  public

  end;

var
  Login: TLogin;

implementation

uses
  MainUI;

{$R *.lfm}

{ TLogin }

procedure TLogin.MenuItem2Click(Sender: TObject);
begin
  ShellRun(URL_HELP, true);
end;

procedure TLogin.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  CenterFormInForm(Self, Application.MainForm);
  {$ENDIF}
end;

procedure TLogin.MenuItem1Click(Sender: TObject);
begin
  ShellRun('https://media.ibroadcast.com/', true);
end;

procedure TLogin.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  with TButton(Sender) do
    begin
      P := Point(0, Height);
      P := ClientToScreen(P);
    end;

  Popup_Extra.PopUp(P.X, P.Y);
end;

procedure TLogin.Button2Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TLogin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOk then
    ModalResult := mrClose;
end;

end.
