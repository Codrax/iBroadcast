unit loginform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus, BroadcastAPI, Cod.Forms, Cod.SysUtils, IdHTTPServer, IdContext,
  IdGlobal, IdCustomHTTPServer, System.NetEncoding, Math,
  taskexecution;

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
    Label5: TLabel;
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
    procedure FormDestroy(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private
    Server: TIdHTTPServer;

    ACodeVerifier, ACodeChallenge: string;
    OAuth2State, OAuth2Code: string;

    ErrorMessage: string;

    // Util
    procedure DoSetError;

    procedure DoBeginLogin;

    // Events
    procedure DoHTTPServerCommandGet(
      AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
  public

  end;

var
  Login: TLogin;

implementation

uses
  MainUI;



function GetHashBytes(
  const AData: string
): TBytes;
const
  K256: array[0..63] of Cardinal = (
    $428A2F98, $71374491, $B5C0FBCF, $E9B5DBA5,
    $3956C25B, $59F111F1, $923F82A4, $AB1C5ED5,
    $D807AA98, $12835B01, $243185BE, $550C7DC3,
    $72BE5D74, $80DEB1FE, $9BDC06A7, $C19BF174,
    $E49B69C1, $EFBE4786, $0FC19DC6, $240CA1CC,
    $2DE92C6F, $4A7484AA, $5CB0A9DC, $76F988DA,
    $983E5152, $A831C66D, $B00327C8, $BF597FC7,
    $C6E00BF3, $D5A79147, $06CA6351, $14292967,
    $27B70A85, $2E1B2138, $4D2C6DFC, $53380D13,
    $650A7354, $766A0ABB, $81C2C92E, $92722C85,
    $A2BFE8A1, $A81A664B, $C24B8B70, $C76C51A3,
    $D192E819, $D6990624, $F40E3585, $106AA070,
    $19A4C116, $1E376C08, $2748774C, $34B0BCB5,
    $391C0CB3, $4ED8AA4A, $5B9CCA4F, $682E6FF3,
    $748F82EE, $78A5636F, $84C87814, $8CC70208,
    $90BEFFFA, $A4506CEB, $BEF9A3F7, $C67178F2
  );

  K512: array[0..79] of UInt64 = (
    $428A2F98D728AE22, $7137449123EF65CD,
    $B5C0FBCFEC4D3B2F, $E9B5DBA58189DBBC,
    $3956C25BF348B538, $59F111F1B605D019,
    $923F82A4AF194F9B, $AB1C5ED5DA6D8118,
    $D807AA98A3030242, $12835B0145706FBE,
    $243185B0145706B8, $550C7DC3D5FFB4E2,
    $72BE5D74F27B896F, $80DEB1FE3B1696B1,
    $9BDC06A725C71235, $C19BF174CF692694,
    $E49B69C19EF14AD2, $EFBE4786384F25E3,
    $0FC19DC68B8CD5B5, $240CA1CC77AC9C65,
    $2DE92C6F592B0275, $4A7484AA6EA6E483,
    $5CB0A9DCBD41FBD4, $76F988DA831153B5,
    $983E5152EE66DFAB, $A831C66D2DB43210,
    $B00327C898FB213F, $BF597FC7BEEF0EE4,
    $C6E00BF33DA88FC2, $D5A79147930AA725,
    $06CA6351E003826F, $142929670A0E6E70,
    $27B70A8546D22FFC, $2E1B21385C26C926,
    $4D2C6DFAC42AED, $53380D139D95B3DF,
    $650A73548BAF63DE, $766A0ABB3C77B2A8,
    $81C2C92E47EDAEE6, $92722C851482353B,
    $A2BFE8A14CF10364, $A81A664BBC423001,
    $C24B8B70D0F89791, $C76C51A30654BE30,
    $D192E819D6EF5218, $D69906245565A910,
    $F40E35855771202A, $106AA07032BB1B8,
    $19A4C116B8D2D0C8, $1E376C085141AB53,
    $2748774CDF8E99, $34B0BCB5E19B48A8,
    $391C0CB3C5C95A63, $4ED8AA4AE3418ACB,
    $5B9CCA4F7763E373, $682E6FF3D6B2B8A3,
    $748F82EE5DEFB2FC, $78A5636F43172F60,
    $84C87814A1F0AB72, $8CC702081A6439EC,
    $90BEFFFA23631E28, $A4506CEBDE82BDE9,
    $BEF9A3F7B2C67915, $C67178F2E372532B,
    $CA273ECEEA26619C, $D186B8C721C0C207,
    $EADA7DD6CDE0EB1E, $F57D4F7FEE6ED178,
    $06F067AA72176FBA, $0A637DC5A2C898A6,
    $113F9804BEF90DAE, $1B710B35131C471B,
    $28DB77F523047D84, $32CAAB7B40C72493,
    $3C9EBE0A15C9BEBC, $431D67C49C100D4C,
    $4CC5D4BECB3E42B6, $597F299CFC657E2A,
    $5FCB6FAB3AD6FAEC, $6C44198C4A475817
  );

  function ROR32(X: Cardinal; N: Cardinal): Cardinal; inline;
  begin
    Result := (X shr N) or (X shl (32 - N));
  end;

  function ROR64(X: UInt64; N: Cardinal): UInt64; inline;
  begin
    Result := (X shr N) or (X shl (64 - N));
  end;

  function Ch32(X, Y, Z: Cardinal): Cardinal; inline;
  begin
    Result := (X and Y) xor ((not X) and Z);
  end;

  function Maj32(X, Y, Z: Cardinal): Cardinal; inline;
  begin
    Result := (X and Y) xor (X and Z) xor (Y and Z);
  end;

  function Ch64(X, Y, Z: UInt64): UInt64; inline;
  begin
    Result := (X and Y) xor ((not X) and Z);
  end;

  function Maj64(X, Y, Z: UInt64): UInt64; inline;
  begin
    Result := (X and Y) xor (X and Z) xor (Y and Z);
  end;

  function BE32(X: Cardinal): Cardinal; inline;
  begin
    Result :=
      ((X and $000000FF) shl 24) or
      ((X and $0000FF00) shl 8) or
      ((X and $00FF0000) shr 8) or
      ((X and $FF000000) shr 24);
  end;

  function BE64(X: UInt64): UInt64; inline;
  begin
    Result :=
      ((X and UInt64($00000000000000FF)) shl 56) or
      ((X and UInt64($000000000000FF00)) shl 40) or
      ((X and UInt64($0000000000FF0000)) shl 24) or
      ((X and UInt64($00000000FF000000)) shl 8) or
      ((X and UInt64($000000FF00000000)) shr 8) or
      ((X and UInt64($0000FF0000000000)) shr 24) or
      ((X and UInt64($00FF000000000000)) shr 40) or
      ((X and UInt64($FF00000000000000)) shr 56);
  end;

var
  Data: TBytes;
  Padded: TBytes;
  Len: NativeUInt;
  BitLen: UInt64;
  Offset: NativeUInt;
  I, J: Integer;

  H32: array[0..7] of Cardinal;
  H64: array[0..7] of UInt64;

  W32: array[0..63] of Cardinal;
  W64: array[0..79] of UInt64;

  A, B, C, D, E, F, G, H: Cardinal;
  A64, B64, C64, D64, E64, F64, G64, H64v: UInt64;

  S0, S1, T1, T2: Cardinal;
  S064, S164, T164, T264: UInt64;

  BlockSize: Integer;
  DigestSize: Integer;
  Is32: Boolean;

begin
  Data := TEncoding.UTF8.GetBytes(AData);
  Len := Length(Data);

  BlockSize := 64;
  Is32 := True;


  H32[0] := $6A09E667;
  H32[1] := $BB67AE85;
  H32[2] := $3C6EF372;
  H32[3] := $A54FF53A;
  H32[4] := $510E527F;
  H32[5] := $9B05688C;
  H32[6] := $1F83D9AB;
  H32[7] := $5BE0CD19;
  DigestSize := 32;


  { Padding }

  BitLen := UInt64(Len) * 8;

  if Is32 then
  begin
    I := ((Len + 9 + 63) div 64) * 64;
    SetLength(Padded, I);

    if Len > 0 then
      Move(Data[0], Padded[0], Len);

    Padded[Len] := $80;

    PCardinal(@Padded[I - 8])^ := BE32(Cardinal(BitLen shr 32));
    PCardinal(@Padded[I - 4])^ := BE32(Cardinal(BitLen));

    Offset := 0;

    while Offset < NativeUInt(Length(Padded)) do
    begin
      for J := 0 to 15 do
        Move(Padded[Offset + J * 4], W32[J], 4);

      for J := 0 to 15 do
        W32[J] := BE32(W32[J]);

      for J := 16 to 63 do
      begin
        S0 :=
          ROR32(W32[J - 15], 7) xor
          ROR32(W32[J - 15], 18) xor
          (W32[J - 15] shr 3);

        S1 :=
          ROR32(W32[J - 2], 17) xor
          ROR32(W32[J - 2], 19) xor
          (W32[J - 2] shr 10);

        W32[J] := W32[J - 16] + S0 + W32[J - 7] + S1;
      end;

      A := H32[0];
      B := H32[1];
      C := H32[2];
      D := H32[3];
      E := H32[4];
      F := H32[5];
      G := H32[6];
      H := H32[7];

      for J := 0 to 63 do
      begin
        S0 :=
          ROR32(A, 2) xor
          ROR32(A, 13) xor
          ROR32(A, 22);

        T2 := S0 + Maj32(A, B, C);

        S1 :=
          ROR32(E, 6) xor
          ROR32(E, 11) xor
          ROR32(E, 25);

        T1 :=
          H + S1 + Ch32(E, F, G) + K256[J] + W32[J];

        H := G;
        G := F;
        F := E;
        E := D + T1;
        D := C;
        C := B;
        B := A;
        A := T1 + T2;
      end;

      H32[0] := H32[0] + A;
      H32[1] := H32[1] + B;
      H32[2] := H32[2] + C;
      H32[3] := H32[3] + D;
      H32[4] := H32[4] + E;
      H32[5] := H32[5] + F;
      H32[6] := H32[6] + G;
      H32[7] := H32[7] + H;

      Inc(Offset, 64);
    end;

    SetLength(Result, DigestSize);

    for J := 0 to (DigestSize div 4) - 1 do
    begin
      PCardinal(@Result[J * 4])^ := BE32(H32[J]);
    end;
  end
  else
  begin
    I := ((Len + 17 + 127) div 128) * 128;
    SetLength(Padded, I);

    if Len > 0 then
      Move(Data[0], Padded[0], Len);

    Padded[Len] := $80;

    { SHA-512 length field is 128 bits.
      Input here is limited to UInt64 length, so high 64 bits are zero. }

    PUInt64(@Padded[I - 16])^ := 0;
    PUInt64(@Padded[I - 8])^ := BE64(BitLen);

    Offset := 0;

    while Offset < NativeUInt(Length(Padded)) do
    begin
      for J := 0 to 15 do
        Move(Padded[Offset + J * 8], W64[J], 8);

      for J := 0 to 15 do
        W64[J] := BE64(W64[J]);

      for J := 16 to 79 do
      begin
        S064 :=
          ROR64(W64[J - 15], 1) xor
          ROR64(W64[J - 15], 8) xor
          (W64[J - 15] shr 7);

        S164 :=
          ROR64(W64[J - 2], 19) xor
          ROR64(W64[J - 2], 61) xor
          (W64[J - 2] shr 6);

        W64[J] :=
          W64[J - 16] + S064 +
          W64[J - 7] + S164;
      end;

      A64 := H64[0];
      B64 := H64[1];
      C64 := H64[2];
      D64 := H64[3];
      E64 := H64[4];
      F64 := H64[5];
      G64 := H64[6];
      H64v := H64[7];

      for J := 0 to 79 do
      begin
        S064 :=
          ROR64(A64, 28) xor
          ROR64(A64, 34) xor
          ROR64(A64, 39);

        T264 := S064 + Maj64(A64, B64, C64);

        S164 :=
          ROR64(E64, 14) xor
          ROR64(E64, 18) xor
          ROR64(E64, 41);

        T164 :=
          H64v + S164 +
          Ch64(E64, F64, G64) +
          K512[J] +
          W64[J];

        H64v := G64;
        G64 := F64;
        F64 := E64;
        E64 := D64 + T164;
        D64 := C64;
        C64 := B64;
        B64 := A64;
        A64 := T164 + T264;
      end;

      H64[0] := H64[0] + A64;
      H64[1] := H64[1] + B64;
      H64[2] := H64[2] + C64;
      H64[3] := H64[3] + D64;
      H64[4] := H64[4] + E64;
      H64[5] := H64[5] + F64;
      H64[6] := H64[6] + G64;
      H64[7] := H64[7] + H64v;

      Inc(Offset, 128);
    end;

    SetLength(Result, DigestSize);

    for J := 0 to 7 do
    begin
      if J * 8 >= DigestSize then
        Break;

      Move(
        BE64(H64[J]),
        Result[J * 8],
        Min(8, DigestSize - J * 8)
      );
    end;
  end;
end;

function Base64URLEncode(const AData: TBytes): string;
const
  CBase64URL: PChar =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
var
  I: Integer;
  J: Integer;
  L: Integer;
  A, B, C: Byte;
  P: PChar;
begin
  L := Length(AData);

  if L = 0 then
    Exit('');

  SetLength(Result, ((L + 2) div 3) * 4);

  P := PChar(Result);
  I := 0;
  J := 0;

  while I + 2 < L do
  begin
    A := AData[I];
    B := AData[I + 1];
    C := AData[I + 2];

    P[J]     := CBase64URL[A shr 2];
    P[J + 1] := CBase64URL[((A and $03) shl 4) or (B shr 4)];
    P[J + 2] := CBase64URL[((B and $0F) shl 2) or (C shr 6)];
    P[J + 3] := CBase64URL[C and $3F];

    Inc(I, 3);
    Inc(J, 4);
  end;

  case L - I of
    1:
      begin
        A := AData[I];

        P[J]     := CBase64URL[A shr 2];
        P[J + 1] := CBase64URL[(A and $03) shl 4];

        SetLength(Result, J + 2);
      end;

    2:
      begin
        A := AData[I];
        B := AData[I + 1];

        P[J]     := CBase64URL[A shr 2];
        P[J + 1] := CBase64URL[((A and $03) shl 4) or (B shr 4)];
        P[J + 2] := CBase64URL[(B and $0F) shl 2];

        SetLength(Result, J + 3);
      end;
  end;
end;

{$R *.lfm}

{ TLogin }

procedure TLogin.MenuItem2Click(Sender: TObject);
begin
  ShellRun(URL_HELP, true);
end;

procedure TLogin.DoSetError;
begin
  Login.Label5.Caption := Login.ErrorMessage;
  Login.Label5.Show;
end;

procedure TLogin.DoBeginLogin;
begin
  // Fetched a code
  if OAuth2Code = '' then
    Exit;

  with TDialogFetchingTokenCredentials.Create do
    begin
      OAuth2Code := Self.OAuth2Code;
      CodeVerifier := Self.ACodeVerifier;

      Start;
    end;
  OAuth2Code := '';

  // Wait for task
  if TaskExec.ShowModal = mrOk then
    begin
      // Success!! yay
      ModalResult:=mrOk;
    end
  else
    begin
      ErrorMessage:='Failed to fetch token credentials from server';
      DoSetError;
    end;
end;

procedure TLogin.DoHTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  OAuth2State_Fetched: string;
  OAuth2State_ErrorDesc: string;
begin
  if ARequestInfo.CommandType <> hcGET then
    Exit;

  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentType := 'text/plain';

  // Get
  OAuth2State_Fetched := ARequestInfo.Params.Values['state'];
  OAuth2State_ErrorDesc := ARequestInfo.Params.Values['error_description'];

  // Validate
  if OAuth2State_ErrorDesc <> '' then begin
    ErrorMessage := 'Server error: '+OAuth2State_ErrorDesc;
    TThread.Synchronize(TThread.CurrentThread, @DoSetError);

    AResponseInfo.ContentText := 'Server error: '+OAuth2State_ErrorDesc;
    Exit;
  end;
  if OAuth2State_Fetched <> OAuth2State then begin
    ErrorMessage := 'Error: Secure state check failed';
    TThread.Synchronize(TThread.CurrentThread, @DoSetError);

    AResponseInfo.ContentText := 'Secure code validation failed.';
    Exit;
  end;

  // Set
  WORK_STATUS := 'Reading code...';
  OAuth2Code := ARequestInfo.Params.Values['code'];

  // Success
  AResponseInfo.ContentText := 'Authorization successful. You can close this window.';

  // Start
  TThread.Synchronize(TThread.CurrentThread, @DoBeginLogin);
end;

procedure TLogin.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  CenterFormInForm(Self, Application.MainForm);
  {$ENDIF}

  Server := TIdHTTPServer.Create(nil);

  // Start server
  with Server.Bindings.Add do begin
    IP := '127.0.0.1';
    Port := OAUTH2_LISTEN_PORT;
  end;

  Server.OnCommandGet := @DoHTTPServerCommandGet;
end;

procedure TLogin.FormDestroy(Sender: TObject);
begin
  Server.Free;
end;

procedure TLogin.Label2Click(Sender: TObject);
begin

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
  if TButton(Sender).Tag = 0 then begin
    TButton(Sender).Tag := 1;
    TButton(Sender).Caption := 'Cancel';

    Server.Active := true;

    OAuth2Code:= '';

    // Challange
    ACodeVerifier := AnsiString(TNetEncoding.Base64.EncodeBytesToString(TEncoding.UTF8.GetBytes(UnicodeString(TGUID.NewGuid.ToString))));
    ACodeChallenge := Base64URLEncode(GetHashBytes(ACodeVerifier));

    // State
    OAuth2State := Random(100000).ToString;

    // URL
    ShellRun(
      V2_Login_AuthorizeURL(OAuth2State, ACodeChallenge),
      true
    );
  end else begin
    TButton(Sender).Tag := 0;
    TButton(Sender).Caption := 'Login';

    Server.Active := false;
  end;

  Label5.Hide;
end;

procedure TLogin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOk then
    ModalResult := mrClose;
end;

end.
