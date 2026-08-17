unit taskexecution;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Cod.Forms;

type

  { TTaskExec }

  TTaskExec = class(TForm)
    Title: TLabel;
    Label3: TLabel;
    Progress: TProgressBar;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  TaskExec: TTaskExec;

implementation

{$R *.lfm}

{ TTaskExec }

procedure TTaskExec.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  CenterFormInForm(Self, Application.MainForm);
  {$ENDIF}
end;

end.

