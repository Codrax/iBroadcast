unit shutdownform;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Cod.Dialogs;

type

  { Tshutdown }

  Tshutdown = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ProgressBar1: TProgressBar;
    Status_Text: TLabel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  shutdown: Tshutdown;

implementation

{$R *.lfm}

{ Tshutdown }

procedure Tshutdown.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  CenterFormInForm(Self, Application.MainForm);
  {$ENDIF}
end;

end.

