{$SCOPEDENUMS ON}

unit Cod.Forms;

interface
uses
  {$IFDEF MSWINDOWS}
  Windows, Messages, DwmApi,
  {$IFNDEF FPC}UxTheme,{$ENDIF}
  {$ENDIF}
  Classes, Graphics, Types, Menus, Forms, SysUtils, Controls,
  Cod.StringUtils, IniFiles
  {$IFDEF FPC}, Cod.Platform.Lazarus{$ELSE}, IOUtils{$ENDIF};

type
  {$IFDEF MSWINDOWS}
  // Dwm api
  AccentPolicy = packed record
    AccentState: Integer;
    AccentFlags: Integer;
    GradientColor: Integer;
    AnimationId: Integer;
  end;
  WindowCompositionAttributeData = packed record
    Attribute: Cardinal;
    Data: Pointer;
    SizeOfData: Integer;
  end;
  {$ENDIF}

// Positions
function IsWindowSnapped(Form: TForm): boolean; overload;
function IsWindowSnapped(Form: TForm; var BoundsRect: TRect): boolean; overload;

// Positions on screen
procedure SaveFormPositions(Form: TForm; FilePath: string);
procedure LoadFormPositions(Form: TForm; FilePath: string);
procedure DeleteFormPositions(Form: TForm; FilePath: string);

// Positions
procedure CenterFormInForm(form, primaryform: TForm; alsoopen: boolean = false);
procedure CenterFormOnScreen(form: TForm);
procedure ChangeMainForm(NewForm: TForm);
function MouseAboveForm(form: TForm): boolean;
{$IFDEF MSWINDOWS}
function GetHoveredControl: TControl; // works for any form

// Display
{$IFNDEF FPC}
procedure PrepareCustomTitleBar(var TitleBar: TForm; const Background: TColor; Foreground: TColor);
{$ENDIF}

// Menus
procedure OpenFormSystemMenu(Form: TForm; Position: TPoint); overload;
procedure OpenFormSystemMenu(Form: TForm); overload;

// Flags
procedure SetFormAllowClose(Form: TForm; Allow: boolean);
{$ENDIF}

implementation

function IsWindowSnapped(Form: TForm): boolean;
var
  BoundsRect: TRect;
begin
  Result := IsWindowSnapped(Form, BoundsRect);
end;

function IsWindowSnapped(Form: TForm; var BoundsRect: TRect): boolean;
var
  P: TWindowPlacement;
  NormalRect: TRect;
  Monitor: TMonitor;
begin
  Result := False;

  if not Form.HandleAllocated or not IsWindow(Form.Handle) then
    Exit;

  GetWindowRect(Form.Handle, BoundsRect);

  P.Length := SizeOf(P);
  if not GetWindowPlacement(Form.Handle, @P) then
    Exit;

  // rcNormalPosition is relative to the monitor's work area.
  Monitor := Screen.MonitorFromWindow(Form.Handle);

  NormalRect := P.rcNormalPosition;
  OffsetRect(
    NormalRect,
    Monitor.WorkareaRect.Left,
    Monitor.WorkareaRect.Top);

  Result :=
    (Form.WindowState <> wsNormal) or
    not EqualRect(NormalRect, BoundsRect);
end;

procedure SaveFormPositions(Form: TForm; FilePath: string);
var
  Category: string;
  WindowRect: TRect;
  RestoreData: boolean;
begin
  if Form = nil then
    Exit;

  // Name
  Category := Form.Name;

  with TIniFile.Create(FilePath) do
    try
      WindowRect := Form.BoundsRect;
      RestoreData := false;

      {$IFDEF MSWINDOWS}
      // Window is snapped by user (via Windows snapping)
      if IsWindowSnapped(Form) then // is set: WindowRect := P.rcNormalPosition;
        RestoreData := true;
      {$ENDIF}

      WriteInteger(Category, 'State', integer(Form.WindowState));
      WriteInteger(Category, 'Left', WindowRect.Left);
      WriteInteger(Category, 'Top', WindowRect.Top);
      WriteInteger(Category, 'Width', WindowRect.Width);
      WriteInteger(Category, 'Height', WindowRect.Height);
      {$IFNDEF FPC}
      WriteFloat(Category, 'Scale', Form.ScaleFactor);
      {$ENDIF}
      WriteBool(Category, 'Restore data', RestoreData);
    finally
      Free;
    end;
end;

procedure LoadFormPositions(Form: TForm; FilePath: string);
var
  Category: string;
  WindowRect: TRect;
  {$IFDEF MSWINDOWS}
  P: TWindowPlacement;
  {$ENDIF}
  ScaleMultiplier: single;
  WindowState: TWindowState;
  Client: TRect;
  RestoreData: boolean;
begin
  if Form = nil then
    Exit;

  // Default - center in screen
  if not TFile.Exists(FilePath) then
    Exit; // use the default Form.Position setting

  // Name
  Category := Form.Name;

  with TIniFile.Create(FilePath) do
    try
      // Force poDesigned for form without triggering SetPosition()
      if (Form.Position <> poDesigned) then
        (PCardinal(@(Form.Position)))^ := Cardinal(poDesigned);

      // Load scales
      {$IFNDEF FPC}
      ScaleMultiplier := Form.ScaleFactor / ReadFloat(Category, 'Scale', 1);
      {$ELSE}
      ScaleMultiplier := 1;
      {$ENDIF}

      // Get rect
      WindowRect := TRect.Create(
        Point(round(ReadInteger(Category, 'Left', Form.Left)*ScaleMultiplier), round(ReadInteger(Category, 'Top', Form.Top)*ScaleMultiplier)),
        round(ReadInteger(Category, 'Width', Form.Width)*ScaleMultiplier), round(ReadInteger(Category, 'Height', Form.Height)*ScaleMultiplier));
      WindowState := TWindowState(ReadInteger(Category, 'State', integer(Form.WindowState)));

      // Fix bounds
      Client := Screen.WorkAreaRect;
      if WindowRect.Left < Client.Left then
        WindowRect.Offset( Client.Left - WindowRect.Left, 0 );
      if WindowRect.Right > Client.Right then
        WindowRect.Offset( Client.Right - WindowRect.Right, 0 );
      if WindowRect.Top < Client.Top then
        WindowRect.Offset( 0, Client.Top - WindowRect.Top );
      if WindowRect.Bottom > Client.Bottom then
        WindowRect.Offset( 0, Client.Bottom - WindowRect.Bottom );

      // Align
      case WindowState of
        TWindowState.wsMaximized: begin
          RestoreData := ReadBool(Category, 'Restore data', false);

          {$IFDEF MSWINDOWS}
          // If window was snapped, re-load the previous snap restore values
          if RestoreData and Form.HandleAllocated and IsWindow(Form.Handle) and GetWindowPlacement(Form.Handle, P) then begin
            P.showCmd := SW_SHOWMAXIMIZED;
            P.rcNormalPosition := WindowRect;
            SetWindowPlacement(Form.Handle, P);
          end else begin
            if RestoreData then
              Form.SetBounds(WindowRect.Left, WindowRect.Top, WindowRect.Width, WindowRect.Height); // this backup mode is Windows Only
          {$ENDIF}
            Form.WindowState := TWindowState.wsMaximized;
          {$IFDEF MSWINDOWS}
          end;
          {$ENDIF}
        end;

        TWindowState.wsMinimized,
        TWindowState.wsNormal: begin
          Form.WindowState := TWindowState.wsNormal;
          Form.SetBounds(WindowRect.Left, WindowRect.Top, WindowRect.Width, WindowRect.Height);
        end;
      end;
    finally
      Free;
    end;
end;

procedure DeleteFormPositions(Form: TForm; FilePath: string);
var
  Category: string;
begin
  if Form = nil then
    Exit;

  // Name
  Category := Form.Name;

  with TIniFile.Create(FilePath) do
    try
      DeleteKey(Category, 'State');
      DeleteKey(Category, 'Left');
      DeleteKey(Category, 'Top');
      DeleteKey(Category, 'Width');
      DeleteKey(Category, 'Height');
      DeleteKey(Category, 'Scale');
      DeleteKey(Category, 'Restore data');
    finally
      Free;
    end;
end;

procedure CenterFormInForm(form, primaryform: TForm; alsoopen: boolean);
begin
  if form.Position <> poDesigned then
    form.Position := poDesigned;

  form.Left := primaryform.Left + primaryform.Width div 2 -form.Width div 2;
  form.Top := primaryform.Top + primaryform.Height div 2 -form.Height div 2;

  if alsoopen then
    form.Show;
end;

procedure CenterFormOnScreen(form: TForm);
begin
  form.Left := Screen.Width div 2 - form.Width div 2;
  form.Top := Screen.Height div 2 - form.Height div 2;
end;

procedure ChangeMainForm(NewForm: TForm);
begin
  Pointer((@Application.MainForm)^) := NewForm;
end;

function MouseAboveForm(form: TForm): boolean;
begin
  Result := false;

  if (mouse.CursorPos.X > form.Left)
    and (mouse.CursorPos.Y > form.Top)
    and (mouse.CursorPos.X < form.Left + form.Width)
    and (mouse.CursorPos.Y < form.Top + form.Height) then
      Result := true;
end;

{$IFDEF MSWINDOWS}
function GetHoveredControl: TControl;
var
  P: TPoint;
  Handle: HWND;
begin
  GetCursorPos(P);
  Handle := WindowFromPoint(P);
  Result := FindControl(Handle);

  //
  if (Result <> nil) and (not Result.InheritsFrom(TControl)) then
    Result := nil;
end;

{$IFNDEF FPC}
procedure PrepareCustomTitleBar(var TitleBar: TForm; const Background: TColor; Foreground: TColor);
var
  CB, CF, SCB, SCF: integer;
begin
  if BackGround.GetLightValue < 100 then
    CB := 30
  else
    CB := -30;

  if Foreground.GetLightValue < 100 then
    CF := 30
  else
    CF := -30;

  SCF := CF div 2;
  SCB := CF div 2;

  with TitleBar.CustomTitleBar do
    begin
      BackgroundColor := BackGround;
      InactiveBackgroundColor := BackGround.ChangeSaturation(CB);
      ButtonBackgroundColor := BackGround;
      ButtonHoverBackgroundColor := BackGround.ChangeSaturation(SCB);
      ButtonInactiveBackgroundColor := BackGround.ChangeSaturation(CB);
      ButtonPressedBackgroundColor := BackGround.ChangeSaturation(CB);

      ForegroundColor := Foreground;
      ButtonForegroundColor := Foreground;
      ButtonHoverForegroundColor := ForeGround.ChangeSaturation(SCF);
      InactiveForegroundColor := Foreground.ChangeSaturation(CF);
      ButtonInactiveForegroundColor := Foreground.ChangeSaturation(CF);
      ButtonPressedForegroundColor := Foreground.ChangeSaturation(CF);
    end;
end;
{$ENDIF}

procedure OpenFormSystemMenu(Form: TForm; Position: TPoint);
var
  Handle: HMENU;
  cmd: integer;
function EnableBool(Value: boolean): UINT;
begin
  if Value then
    Result := MF_BYCOMMAND or MF_ENABLED
  else
    Result := MF_BYCOMMAND or MF_GRAYED;
end;
begin
  // Get the handle to the system menu
  Handle := GetSystemMenu(Form.Handle, False);

  // Enable / disable the items
  EnableMenuItem(Handle, SC_RESTORE,
    EnableBool((Form.WindowState = TWindowState.wsMaximized) and (biMaximize in Form.BorderIcons))
    );
  EnableMenuItem(Handle, SC_MOVE, EnableBool(Form.WindowState <> TWindowState.wsMaximized));
  EnableMenuItem(Handle, SC_SIZE,
    EnableBool((Form.WindowState <> TWindowState.wsMaximized) and (Form.BorderStyle in [bsSizeable, bsSizeToolWin]))
    );

  EnableMenuItem(Handle, SC_MAXIMIZE,
    EnableBool((Form.WindowState <> TWindowState.wsMaximized) and (biMaximize in Form.BorderIcons) and (Form.BorderStyle in [bsSizeable, bsSingle]))
  );
  EnableMenuItem(Handle, SC_MINIMIZE,
    EnableBool((Form.WindowState <> TWindowState.wsMinimized) and (biMinimize in Form.BorderIcons) and (Form.BorderStyle in [bsSizeable, bsSingle, bsDialog]))
  );

  // Get CMD
  cmd := Integer(
    TrackPopupMenu(Handle, TPM_RETURNCMD or TPM_LEFTALIGN or TPM_TOPALIGN, Position.X, Position.Y, 0,
      Form.Handle, nil)
    );

  // If a valid command is selected, send it to the system for default processing
  if cmd <> 0 then
    SendMessage(Form.Handle, WM_SYSCOMMAND, cmd, 0);
end;

procedure OpenFormSystemMenu(Form: TForm);
begin
  OpenFormSystemMenu(Form, Mouse.CursorPos);
end;

procedure SetFormAllowClose(Form: TForm; Allow: boolean);
var
  Handle: HMENU;
function EnableBool(Value: boolean): UINT;
begin
  if Value then
    Result := MF_BYCOMMAND or MF_ENABLED
  else
    Result := MF_BYCOMMAND or MF_GRAYED;
end;
begin
  // Get the handle to the system menu
  Handle := GetSystemMenu(Form.Handle, False);

  // Set
  EnableMenuItem(Handle, SC_CLOSE, EnableBool(Allow) );
end;
{$ENDIF}

end.
