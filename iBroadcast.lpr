program iBroadcast;

{$mode objfpc}{$H+}
{$DEFINE UseCThreads}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  lazcontrols,
  {$ENDIF}{$ENDIF}
  LibDefine,
  Interfaces, // this includes the LCL widgetset
  Forms, mainui, dialogs, Cod.SysUtils,
  { you can add units after this }
  BroadcastAPI, SpectrumVis3D, uniqueinstanceraw, LoadingLibrary,
  taskexecution, iteminformation, ratingform, loginform, createplaylistform,
  HashFunctions;

{$R *.res}

var
  Param: string;
  I: integer;
begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;

  // Instance
  if InstanceRunning('iBroadcast-for-Linux') then
    begin
      ShowMessage('A instance of iBroadcast is already running!');
      Exit;
    end;

  // Params
  for I := 1 to ParamCount do
    begin
      Param := ParamStr(I);

      if Param = '--debug' then
        DebugMode := true;

      if Param = '--offline' then
        IsOffline := true;

      if Param = '--help' then
        ShellRun(URL_HELP);

      if Param = '--tray' then
        Application.ShowMainForm:= false;
    end;

  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.

