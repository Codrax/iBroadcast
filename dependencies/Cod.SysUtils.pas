{***********************************************************}
{                   Codruts System Utilities                }
{                                                           }
{                        version 0.7                        }
{                                                           }
{                                                           }
{              Developed by Petculescu Codrut               }
{            Copyright (c) 2025 Codrut Software.            }
{***********************************************************}

{$WARN SYMBOL_PLATFORM OFF}

{$SCOPEDENUMS ON}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

unit Cod.SysUtils;

interface
uses
  {$IFDEF MSWINDOWS}
  Registry, ShellApi, ActiveX, ComObj, shlobj
  {$IFNDEF FPC}, Vcl.Imaging.pngimage, Themes{$ENDIF}, Dialogs,
  Graphics, Windows, Controls, Forms, Messages,
  {$ENDIF}
  {$IFNDEF CONSOLE}
    {$IFDEF MSWINDOWS}
    Menus,
    {$ENDIF}
  {$ENDIF}
  SysUtils, Classes, Types, Variants, TypInfo, IniFiles
  {$IFDEF FPC}, Cod.Platform.Lazarus{$ELSE}, UITypes{$ENDIF};

type
  TMethodAccess = procedure of object;


// Controls
procedure OpenPopupUnderControl(Popup: TPopupMenu; Control: TControl);

{ Exceptions }
procedure AssertCon(Condition: boolean; Message: string);

{ Application }
///  <summary> Get parameter by index </summary>
function GetParameter(Index: integer): string; overload; // get parameter by index
///  <summary> Get all parameters as string </summary>
function GetParameters: string;
///  <summary>
///    Check for a Parameter, takes parameter as "value" without shell prefix, return index position
///  </summary>
function FindParameter(Value: string): integer; overload;
///  <summary>
///    Check for a Parameter, takes parameter as "value" without shell prefix
///  </summary>
function HasParameter(Value: string): boolean; overload;
///  <summary> Get value of the following param of the requested value </summary>
function GetParameterValue(Value: string): string; overload;
///  <summary>
///    Check for a single char parameter, return index position
///  </summary>
function FindParameter(Value: char): integer; overload;
///  <summary> Check for a single char Unix parameter </summary>
function HasParameter(Value: char): boolean; overload;
///  <summary> Get single char Unix parameter value </summary>
function GetParameterValue(Value: char): string; overload;
///  <summary>
///    Check for a Unix Parameter alternative, either string or singlechar, return index position
///  </summary>
function FindParameter(Value: string; AltChar: char): integer; overload;
///  <summary> Check for a Unix Parameter alternative, either string or singlechar </summary>
function HasParameter(Value: string; AltChar: char): boolean; overload;
///  <summary> Gets the unix parameter, than returns the value </summary>
function GetParameterValue(Value: string; AltChar: char): string; overload;

{ Process }
function GetCommandLine: string;
function GetExecutableDirectory: string;
procedure EradicateSelfExecutable;

{ Objects }
procedure CopyObject(ObjFrom, ObjTo: TObject);
procedure ResetPropertyValues(const AObject: TObject);
procedure SetProperty(const AObject: TObject; PropertyName, NewValue: string); overload;
procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: integer); overload;
procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: boolean); overload;
procedure SetStringProperty(const AObject: TObject; PropertyName, NewValue: string);
procedure SetIntegerProperty(const AObject: TObject; PropertyName: string; NewValue: integer);
procedure SetBooleanProperty(const AObject: TObject; PropertyName: string; NewValue: boolean);

{ Procedures }
/// Usage:
///  HookMethod(@TClass.ProcInitialFunc, @TClass.ProcNewFunc);
{$IFDEF MSWINDOWS}
procedure HookMethod(OldProc, NewProc: Pointer);
{$ENDIF}

{ Shell }
{$IFDEF MSWINDOWS}
function GetFullExecutablePath(const ExeName: string): string; // search the path for the module name
procedure ShellRun(Command: string; Show: boolean; Parameters: string = ''; Administrator: boolean = false; Directory: string = '');
procedure ShellExecuteFromExplorer(const FileName: string;
  const Parameters: string = ''; const Directory: string = '';
  const Operation: string = ''; ShowCmd: Integer = SW_SHOWNORMAL);

procedure PowerShellRun(Command: string; ShowConsole: boolean; Administrator: boolean = false; Directory: string = '');
function PowerShellGetOutput(Command: string; ShowConsole: boolean; WaitFor: boolean = false; WantOutput: boolean = true): TStringList;
procedure WaitForProgramExecution(CommandLine: string);
function ExecAndWait(const CommandLine: string) : Boolean;
{$ENDIF}
///  <summary>
///  Split command into parameter array as in the UNIX string literal standard.
///  </summary>
function ParameterSplitting(Command: string): TArray<string>;

{$IFNDEF CONSOLE}
function GetFormMonitorIndex(Form: TForm): integer;
{$ENDIF}

{ Dialogs }
{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
procedure FixDelphiXDialogs;
{$ENDIF}
{$ENDIF}

{ Misc }
{$IFDEF MSWINDOWS}
///  <summary>
///    Check if the UI components are running in the IDE form
///  </summary>
{$IFNDEF FPC}
function IsInIDE: boolean;
{$ENDIF}
{$ENDIF}

const
  PARAM_PREFIX = '--';
  PARAM_PREFIX_CHAR = '-';

implementation

procedure OpenPopupUnderControl(Popup: TPopupMenu; Control: TControl);
var
  P: TPoint;
begin
  P := Point(0, Control.Height);
  P := Control.ClientToScreen(P);
  Popup.Popup(P.X, P.Y);
end;

procedure AssertCon(Condition: boolean; Message: string);
begin
  if not Condition then
    raise Exception.Create(Message);
end;

{$IFDEF MSWINDOWS}
procedure HookMethod(OldProc, NewProc: Pointer);
const
  JMP_REL32 = $E9;
var
  dwOldProtect: DWORD;
  Offset: Integer;
begin
  // Allow write access to memory
  VirtualProtect(OldProc, 5, PAGE_EXECUTE_READWRITE, @dwOldProtect);

  // Calculate the relative jump offset
  Offset := NativeInt(NewProc) - NativeInt(OldProc) - 5;

  // Write JMP instruction
  PByte(OldProc)^ := JMP_REL32;
  PInteger(Pointer(NativeInt(OldProc) + 1))^ := Offset;

  // Restore memory protection
  VirtualProtect(OldProc, 5, dwOldProtect, @dwOldProtect);
end;
{$ENDIF}

{$IFNDEF CONSOLE}
function GetFormMonitorIndex(Form: TForm): integer;
var
  I: Integer;
  CenterPosition: TPoint;
begin
  // Default
  Result := Screen.PrimaryMonitor.MonitorNum;

  // Position
  CenterPosition := Point(Form.Left + Form.Width div 2, Form.Top + Form.Height div 2);

  // Scan Monitors
  for I := 0 to Screen.MonitorCount -1 do
    if Screen.Monitors[I].BoundsRect.Contains( CenterPosition ) then
      Exit( Screen.Monitors[I].MonitorNum );
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
function GetFullExecutablePath(const ExeName: string): string;
var
  PathEnv, Dir, WinDir: string;
begin
  if FileExists(ExeName) then
    Exit(ExeName);

  PathEnv := GetEnvironmentVariable('PATH');
  for Dir in PathEnv.Split([';']) do begin
    if FileExists(IncludeTrailingPathDelimiter(Dir) + ExeName) then
      Exit(IncludeTrailingPathDelimiter(Dir) + ExeName);
    if FileExists(IncludeTrailingPathDelimiter(Dir) + ExeName + '.exe') then
      Exit(IncludeTrailingPathDelimiter(Dir) + ExeName  + '.exe');
  end;

  // fallback: Windows folder
  WinDir := GetEnvironmentVariable('WINDIR');
  if FileExists(IncludeTrailingPathDelimiter(WinDir) + ExeName) then
    Exit(IncludeTrailingPathDelimiter(WinDir) + ExeName);
  if FileExists(IncludeTrailingPathDelimiter(WinDir) + ExeName + '.exe') then
    Exit(IncludeTrailingPathDelimiter(WinDir) + ExeName + '.exe');

  Result := ExeName; // do not change
end;

procedure ShellRun(Command: string; Show: boolean; Parameters: string;
  Administrator: boolean; Directory: string);
var
  OperationType: string;
  Parameter: integer;
begin
  if Administrator then
    OperationType := 'runas'
  else
    OperationType := 'open';

  if Show then
    Parameter := SW_NORMAL
  else
    Parameter := SW_HIDE;

  ShellExecute(0, PChar(OperationType), PChar(Command), PChar(Parameters), PChar(Directory), Parameter);
end;

procedure ShellExecuteFromExplorer(const FileName: string;
  const Parameters: string = ''; const Directory: string = '';
  const Operation: string = ''; ShowCmd: Integer = SW_SHOWNORMAL);
var
  ShellDispatch: OLEVariant;
begin        CoInitialize(nil);
  // Get the running Explorer instance
  ShellDispatch := GetActiveOleObject('Shell.Application');

  // Call ShellExecute through Explorer
  ShellDispatch.ShellExecute(
    FileName,
    Parameters,
    Directory,
    Operation,
    ShowCmd
  );
end;


procedure PowerShellRun(Command: string; ShowConsole: boolean; Administrator: boolean; Directory: string);
var
  Parameter: integer;
  OperationType: string;

  ShellParams: string;
begin
  // Settings
  if Administrator then
    OperationType := 'runas'
  else
    OperationType := 'open';

  if ShowConsole then
    Parameter := SW_NORMAL
  else
    Parameter := SW_HIDE;

  // Replace quote mark
  Command := Command.Replace('"', #$27);

  // As Param
  ShellParams := '-c "' + Command + '"';

  ShellExecute(0, PChar(OperationType), 'powershell', PChar(ShellParams), PChar(Directory), Parameter);
end;

function PowerShellGetOutput(Command: string; ShowConsole, WaitFor, WantOutput: boolean): TStringList;
const
    READ_BUFFER_SIZE = 2400;
var
    Security: TSecurityAttributes;
    readableEndOfPipe, writeableEndOfPipe: THandle;
    start: TStartUpInfo;
    ProcessInfo: TProcessInformation;
    Buffer: PAnsiChar;
    BytesRead: DWORD;
    AppRunning: DWORD;
    DosApp: string;
begin
    Security.nLength := SizeOf(TSecurityAttributes);
    Security.bInheritHandle := True;
    Security.lpSecurityDescriptor := nil;

    // Prepare Executable
    DosApp := 'powershell -c "' + Command.Replace('"', #$27) + '"';

    // Output
    Result := TStringList.Create;

    if CreatePipe({var}readableEndOfPipe, {var}writeableEndOfPipe, @Security, 0) then
    begin
        Buffer := AllocMem(READ_BUFFER_SIZE+1);
        FillChar(Start, Sizeof(Start), #0);
        start.cb := SizeOf(start);

        // Set up members of the STARTUPINFO structure.
        // This structure specifies the STDIN and STDOUT handles for redirection.
        // - Redirect the output and error to the writeable end of our pipe.
        // - We must still supply a valid StdInput handle (because we used STARTF_USESTDHANDLES to swear that all three handles will be valid)
        start.dwFlags := start.dwFlags or STARTF_USESTDHANDLES;
        start.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //we're not redirecting stdInput; but we still have to give it a valid handle
        if WantOutput then
          start.hStdOutput := writeableEndOfPipe; //we give the writeable end of the pipe to the child process; we read from the readable end
        start.hStdError := writeableEndOfPipe;

        //We can also choose to say that the wShowWindow member contains a value.
        //In our case we want to force the console window to be hidden.
        start.dwFlags := start.dwFlags + STARTF_USESHOWWINDOW;
        if ShowConsole then
          start.wShowWindow := SW_NORMAL
        else
          start.wShowWindow := SW_HIDE;  // SW_HIDE makes the wait process stuck in a loop!

        // Don't forget to set up members of the PROCESS_INFORMATION structure.
        ProcessInfo := Default(TProcessInformation);

        //WARNING: The unicode version of CreateProcess (CreateProcessW) can modify the command-line "DosApp" string.
        //Therefore "DosApp" cannot be a pointer to read-only memory, or an ACCESS_VIOLATION will occur.
        //We can ensure it's not read-only with the RTL function: UniqueString
        UniqueString({var}DosApp);

        if CreateProcess(nil, PChar(DosApp), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, {var}ProcessInfo) then
        begin
            //Wait for the application to terminate, as it writes it's output to the pipe.
            //WARNING: If the console app outputs more than 2400 bytes (ReadBuffer),
            //it will block on writing to the pipe and *never* close.
            repeat
                Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);

                if not WaitFor then
                  Application.ProcessMessages;
            until (Apprunning <> WAIT_TIMEOUT);

            //Read the contents of the pipe out of the readable end
            //WARNING: if the console app never writes anything to the StdOutput, then ReadFile will block and never return
            // If you just want to wait for a process to finish, set WantOutput to false
            if WantOutput then
              repeat
                BytesRead := 0;
                ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, {var}BytesRead, nil);
                Buffer[BytesRead]:= #0;
                OemToAnsi(Buffer,Buffer);
                Result.Text := Result.text + String(Buffer);
              until (BytesRead < READ_BUFFER_SIZE);
        end;
        FreeMem(Buffer);
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(readableEndOfPipe);
        CloseHandle(writeableEndOfPipe);
    end;
end;

procedure WaitForProgramExecution(CommandLine: string);
const
    READ_BUFFER_SIZE = 2400;
var
    Security: TSecurityAttributes;
    readableEndOfPipe, writeableEndOfPipe: THandle;
    start: TStartUpInfo;
    ProcessInfo: TProcessInformation;
    Buffer: PAnsiChar;
    AppRunning: DWORD;
begin
    Security.nLength := SizeOf(TSecurityAttributes);
    Security.bInheritHandle := True;
    Security.lpSecurityDescriptor := nil;

    if CreatePipe({var}readableEndOfPipe, {var}writeableEndOfPipe, @Security, 0) then
    begin
        Buffer := AllocMem(READ_BUFFER_SIZE+1);
        FillChar(Start, Sizeof(Start), #0);
        start.cb := SizeOf(start);

        // Set up members of the STARTUPINFO structure.
        // This structure specifies the STDIN and STDOUT handles for redirection.
        // - Redirect the output and error to the writeable end of our pipe.
        // - We must still supply a valid StdInput handle (because we used STARTF_USESTDHANDLES to swear that all three handles will be valid)
        start.dwFlags := start.dwFlags or STARTF_USESTDHANDLES;
        start.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //we're not redirecting stdInput; but we still have to give it a valid handle
        start.hStdOutput := writeableEndOfPipe; //we give the writeable end of the pipe to the child process; we read from the readable end
        start.hStdError := writeableEndOfPipe;

        start.dwFlags := start.dwFlags + STARTF_USESHOWWINDOW;
        start.wShowWindow := SW_HIDE;

        ProcessInfo := Default(TProcessInformation);

        UniqueString({var}CommandLine);

        if CreateProcess(nil, PChar(CommandLine), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, {var}ProcessInfo) then
        begin
            //Wait for the application to terminate, as it writes it's output to the pipe.
            //WARNING: If the console app outputs more than 2400 bytes (ReadBuffer),
            //it will block on writing to the pipe and *never* close.
            repeat
                Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
            until (Apprunning <> WAIT_TIMEOUT);
        end;
        FreeMem(Buffer);
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(readableEndOfPipe);
        CloseHandle(writeableEndOfPipe);
    end;
end;

function ExecAndWait(const CommandLine: string) : Boolean;
var
  StartupInfo: TStartupInfo;        // start-up info passed to process
  ProcessInfo: TProcessInformation; // info about the process
  ProcessExitCode: DWord;           // process's exit code
begin
  // Set default error result
  Result := False;
  // Initialise startup info structure to 0, and record length
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb := SizeOf(StartupInfo);
  // Execute application commandline
  if CreateProcess(nil, PChar(CommandLine),
    nil, nil, False, 0, nil, nil,
    StartupInfo, ProcessInfo) then
  begin
    try
      // Now wait for application to complete
      if WaitForSingleObject(ProcessInfo.hProcess, INFINITE)
        = WAIT_OBJECT_0 then
        // It's completed - get its exit code
        if GetExitCodeProcess(ProcessInfo.hProcess,
          ProcessExitCode) then
          // Check exit code is zero => successful completion
          if ProcessExitCode = 0 then
            Result := True;
    finally
      // Tidy up
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
  end;
end;
{$ENDIF}

function ParameterSplitting(Command: string): TArray<string>;
var
  P: integer;
  Position: integer;

  LayerDoubleType: boolean;
  TrimSize: integer;

procedure Cut;
var
   Index: integer;
begin
  // New entry
  if Position > 0 then begin
    Index := Length(Result);
    SetLength(Result, Index+1);
    Result[Index] := Command.Substring(TrimSize, Position-TrimSize);

    if LayerDoubleType then
      Result[Index] := Result[Index].Replace('\"', '"');
  end;

  // Remove
  Command := Command.Substring(Position+1); // exclude char

  // Move
  Position := 0;
end;
function CalculateLiteral(Character: char): boolean;
var
  Finalised: boolean;
begin
  Result := false;
  if Command.Chars[0] = Character then begin
    P := 0;
    repeat
      P := Command.IndexOf(Character, P+1);
      Finalised := (P=-1) or (Character = #39) or (Command.Chars[P-1] <> '\');
    until Finalised;

    // Found suited
    if P <> -1 then begin
      LayerDoubleType := Character = '"';

      Position := P;
      TrimSize := 1;
      Result := true;
    end;
  end;
end;
begin
  Result := [];
  repeat
    TrimSize := 0;
    LayerDoubleType := false;

    // Get next space
    Position := Command.IndexOf(' ');
    if Position = -1 then
      Position := Command.Length;

    // Calculate if is string literal
    if not CalculateLiteral('"') then
      CalculateLiteral(#39);

    // Cut data
    Cut;
  until Command = '';
end;

function GetParameter(Index: integer): string;
begin
  Result := ParamStr(Index);

  {$IFDEF MSWINDOWS}
  // Fix WinNT
  if (Length(Result)>0) and (Result[1] = '/') then
    Result[1] := '-';
  {$ENDIF}
end;

function GetParameters: string;
var
  I: Integer;
  Parameter: string;
  ACount: integer;
begin
  ACount := ParamCount;
  for I := 1 to ParamCount do
    begin
      Parameter := GetParameter(I);

      if Parameter.IndexOf(' ') <> -1 then
        Parameter := Format('"%S"', [Parameter]);

      Result := Result + Parameter;
      if I <> ACount then
        Result := Result + ' ';
    end;
end;

function FindParameter(Value: string): integer;
var
  S: string;
  I: integer;
begin
  Result := -1;
  for I := 1 to ParamCount do
    begin
      S := GetParameter(I);
      if (Length(S) < Length(PARAM_PREFIX)+1) or (Copy(S, 1, Length(PARAM_PREFIX)) <> PARAM_PREFIX) then
        Continue;

      // Remove prefix
      S := S.Remove(0, Length(PARAM_PREFIX));
      {$IFDEF MSWINDOWS}
      // Ignore casing
      S := Lowercase(S);
      {$ENDIF}

      // Check for equalitry
      if S = Value then
        Exit( I );
    end;
end;

function HasParameter(Value: string): boolean; overload;
begin
  Result := FindParameter( Value ) <> -1;
end;

function GetParameterValue(Value: string): string; overload;
var
  Index: integer;
begin
  Index := FindParameter( Value );
  Result := GetParameter(Index+1);
end;

function FindParameter(Value: char): integer;
var
  S: string;
  I: integer;
begin
  Result := -1;
  for I := 1 to ParamCount do
    begin
      S := GetParameter(I);
      if (Length(S) < Length(PARAM_PREFIX_CHAR)+1)
        or (Copy(S, 1, Length(PARAM_PREFIX_CHAR)) <> PARAM_PREFIX_CHAR)
        {$IFNDEF MSWINDOWS}or (Copy(S, 1, Length(PARAM_PREFIX)) = PARAM_PREFIX){$ENDIF} then
        Continue;

      // Remove prefix
      S := S.Remove(0, Length(PARAM_PREFIX_CHAR));

      // Check for char in list of chars
      if S.IndexOf( Value ) <> -1 then
        Exit( I );
    end;
end;

function HasParameter(Value: char): boolean; overload;
begin
  Result := FindParameter( Value ) <> -1;
end;

function GetParameterValue(Value: char): string; overload;
var
  Index: integer;
begin
  Index := FindParameter( Value );
  Result := GetParameter(Index+1);
end;

function FindParameter(Value: string; AltChar: char): integer;
begin
  Result := FindParameter( Value );
  if Result <> -1 then
    Exit;
  Result := FindParameter( AltChar );
end;

function HasParameter(Value: string; AltChar: char): boolean; overload;
begin
  Result := FindParameter( Value, AltChar ) <> -1;
end;

function GetParameterValue(Value: string; AltChar: char): string; overload;
var
  Index: integer;
begin
  Index := FindParameter( Value, AltChar );
  Result := GetParameter(Index+1);
end;

function GetCommandLine: string;
{$IFNDEF MSWINDOWS}
var
  I: Integer;
  S: string;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  Result := Windows.GetCommandLine;
  {$ELSE}
  Result := '';
  for I := 0 to ParamCount do
  begin
    S := ParamStr(I);
    if S.Contains(' ') or S.Contains('"') then
      S := '"' + StringReplace(S, '"', '\"', [rfReplaceAll]) + '"';
    Result := Result + S + ' ';
  end;
  Result := TrimRight(Result);
  {$ENDIF}
end;

function GetExecutableDirectory: string;
begin
  Result := ExtractFileDir(ParamStr(0));
end;

procedure EradicateSelfExecutable;
{$IFDEF MSWINDOWS}
var
  ExePath, Cmd: string;
begin
  ExePath := ParamStr(0);
  // /f = force, /q = quiet
  Cmd := Format('/c ping -n 3 127.0.0.1 > nul && del /f /q "%s"', [ExePath]);
  ShellExecute(0, 'open', 'cmd.exe', PChar(Cmd), nil, SW_HIDE);
  Halt;
end;
{$ELSE}
begin
  TFile.Delete(ParamStr(0)); // risky if running; not 100% guaranteed to work
  Halt;
end;
{$ENDIF}

procedure CopyObject(ObjFrom, ObjTo: TObject);
  var
PropInfos: PPropList;
PropInfo: PPropInfo;
Count, Loop: Integer;
OrdVal: Longint;
StrVal: String;
FloatVal: Extended;
MethodVal: TMethod;
begin
//{ Iterate thru all published fields and properties of source }
//{ copying them to target }

//{ Find out how many properties we'll be considering }
Count := GetPropList(ObjFrom.ClassInfo, tkAny, nil);
//{ Allocate memory to hold their RTTI data }
GetMem(PropInfos, Count * SizeOf(PPropInfo));
try
//{ Get hold of the property list in our new buffer }
GetPropList(ObjFrom.ClassInfo, tkAny, PropInfos);
//{ Loop through all the selected properties }
for Loop := 0 to Count - 1 do
begin
  PropInfo := GetPropInfo(ObjTo.ClassInfo, String(PropInfos^[Loop]^.Name));
 // { Check the general type of the property }
  //{ and read/write it in an appropriate way }
  case PropInfos^[Loop]^.PropType^.Kind of
    tkInteger, tkChar, tkEnumeration,
    tkSet, tkClass{$ifdef Win32}, tkWChar{$endif}:
    begin
      OrdVal := GetOrdProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetOrdProp(ObjTo, PropInfo, OrdVal);
    end;
    tkFloat:
    begin
      FloatVal := GetFloatProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetFloatProp(ObjTo, PropInfo, FloatVal);
    end;
    {$ifndef DelphiLessThan3}
    tkWString,
    {$endif}
    {$ifdef Win32}
    tkLString,
    {$endif}
    tkString:
    begin
      { Avoid copying 'Name' - components must have unique names }
      if UpperCase(String(PropInfos^[Loop]^.Name)) = 'NAME' then
        Continue;
      StrVal := GetStrProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetStrProp(ObjTo, PropInfo, StrVal);
    end;
    tkMethod:
    begin
      MethodVal := GetMethodProp(ObjFrom, PropInfos^[Loop]);
      if Assigned(PropInfo) then
        SetMethodProp(ObjTo, PropInfo, MethodVal);
    end
  end
end
finally
  FreeMem(PropInfos, Count * SizeOf(PPropInfo));
end;
end;

procedure ResetPropertyValues(const AObject: TObject);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
const
  TypeKinds: TTypeKinds = [tkEnumeration, tkString, tkLString, tkWString,
    tkUString];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Set
      if Assigned(PropInfo^.SetProc) then
      case PropInfo^.PropType^.Kind of
        tkString, tkLString, tkUString, tkWString:
          SetStrProp(AObject, PropInfo, '');
        tkEnumeration:
          if GetTypeData(PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF})^.BaseType{$IFNDEF FPC}^{$ENDIF} = TypeInfo(Boolean) then
            SetOrdProp(AObject, PropInfo, 0);

      end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure SetProperty(const AObject: TObject; PropertyName, NewValue: string); overload;
begin
  if AObject <> nil then
    SetStringProperty( AObject, PropertyName, NewValue);
end;

procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: integer); overload;
begin
  if AObject <> nil then
    SetIntegerProperty( AObject, PropertyName, NewValue);
end;

procedure SetProperty(const AObject: TObject; PropertyName: string; NewValue: boolean); overload;
begin
  if AObject <> nil then
    SetBooleanProperty( AObject, PropertyName, NewValue);
end;

procedure SetStringProperty(const AObject: TObject; PropertyName, NewValue: string);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropRest: string;
  PropDot: Integer;
const
  TypeKinds: TTypeKinds = [tkString, tkLString, tkWString, tkUString, tkClass];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Multi Class
      if Pos('.', PropertyName) <> 0 then
        begin
          PropDot := Pos('.', PropertyName);
          PropRest := Copy( PropertyName, PropDot + 1, length(Propertyname) );
          PropertyName := Copy( PropertyName, 0, PropDot - 1 );
        end;

      // Set
      if AnsiLowerCase(string(PropInfo.Name)) = AnsiLowerCase(PropertyName) then
        if Assigned(PropInfo^.SetProc) then
        case PropInfo^.PropType^.Kind of
          tkString, tkLString, tkUString, tkWString:
            SetStrProp(AObject, PropInfo, NewValue);
          tkClass: SetStringProperty( GetObjectProp(AObject, PropInfo), PropRest, NewValue );
        end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure SetIntegerProperty(const AObject: TObject; PropertyName: string; NewValue: integer);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropRest: string;
  PropDot: Integer;
const
  TypeKinds: TTypeKinds = [tkInteger, tkEnumeration, tkClass];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Multi Class
      if Pos('.', PropertyName) <> 0 then
        begin
          PropDot := Pos('.', PropertyName);
          PropRest := Copy( PropertyName, PropDot + 1, length(Propertyname) );
          PropertyName := Copy( PropertyName, 0, PropDot - 1 );
        end;

      // Set
      if AnsiLowerCase(string(PropInfo.Name)) = AnsiLowerCase(PropertyName) then
        if Assigned(PropInfo^.SetProc) then
        case PropInfo^.PropType^.Kind of
          tkEnumeration, tkInteger:
            SetOrdProp(AObject, PropInfo, NewValue);
          tkClass: SetIntegerProperty( GetObjectProp(AObject, PropInfo), PropRest, NewValue );
        end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure SetBooleanProperty(const AObject: TObject; PropertyName: string; NewValue: boolean);
var
  PropIndex: Integer;
  PropCount: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
  PropRest: string;
  PropDot: Integer;
const
  TypeKinds: TTypeKinds = [tkEnumeration, tkClass];
begin
  PropCount := GetPropList(AObject.ClassInfo, TypeKinds, nil);
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  try
    GetPropList(AObject.ClassInfo, TypeKinds, PropList);
    for PropIndex := 0 to PropCount - 1 do
    begin
      PropInfo := PropList^[PropIndex];

      // Multi Class
      if Pos('.', PropertyName) <> 0 then
        begin
          PropDot := Pos('.', PropertyName);
          PropRest := Copy( PropertyName, PropDot + 1, length(Propertyname) );
          PropertyName := Copy( PropertyName, 0, PropDot - 1 );
        end;

      // Set
      if AnsiLowerCase(string(PropInfo.Name)) = AnsiLowerCase(PropertyName) then
        if Assigned(PropInfo^.SetProc) then
        case PropInfo^.PropType^.Kind of
          tkEnumeration, tkInteger:
            SetOrdProp(AObject, PropInfo, integer(NewValue));
          tkClass: SetBooleanProperty( GetObjectProp(AObject, PropInfo), PropRest, NewValue );
        end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
function IsInIDE: boolean;
begin
  if TStyleManager.ActiveStyle.Name = 'Mountain_Mist' then
    Result := true
  else
    Result := false;
end;
{$ENDIF}
{$ENDIF}

{$IFDEF MSWINDOWS}
{$IFNDEF FPC}
procedure FixDelphiXDialogs;
begin
  MsgDlgIcons[TMsgDlgType.mtInformation] := TMsgDlgIcon.mdiInformation;
end;
{$ENDIF}
{$ENDIF}

end.
