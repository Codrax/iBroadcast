unit LoadingLibrary;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Cod.Forms;

type

  { TLoadLib }

  TLoadLib = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Status_Text: TLabel;
    ProgressBar1: TProgressBar;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  LoadLib: TLoadLib;

implementation

{$R *.lfm}

{ TLoadLib }

procedure TLoadLib.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if ModalResult = mrNone then
    CanClose := false;
end;

procedure TLoadLib.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  CenterFormInForm(Self, Application.MainForm);
  {$ENDIF}
end;

end.

