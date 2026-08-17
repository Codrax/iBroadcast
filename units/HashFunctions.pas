{$Q-}
{$R-}
{$H-}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

{$POINTERMATH on}

unit HashFunctions;
{$WARN 4110 off : Range check error while evaluating constants ($1 must be between $2 and $3)}
{$WARN 4104 off : Implicit string type conversion from "$1" to "$2"}
{$WARN 5057 off : Local variable "$1" does not seem to be initialized}
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
{$WARN 5093 off : Function result variable of a managed type does not seem to be initialized}
{$WARN 5091 off : Local variable "$1" of a managed type does not seem to be initialized}
interface

uses
  Classes, SysUtils;

type
  EHashException = class(Exception);

  THash = record
    class function DigestAsInteger(const ADigest: TBytes): Integer; static;
    class function DigestAsString(const ADigest: TBytes): string; static;
    class function DigestAsStringGUID(const ADigest: TBytes): string; static;
    class function GetRandomString(const ALen: Integer = 10): string; static;
    class function ToBigEndian(AValue: Cardinal): Cardinal; overload; static; inline;
    class function ToBigEndian(AValue: UInt64): UInt64; overload; static; inline;
  end;

  THashSHA2 = record
  public type
    TSHA2Version = (SHA224, SHA256, SHA384, SHA512, SHA512_224, SHA512_256);
  private const
    CBuffer32Length = 64;
    CBuffer64Length = 128;
  private
    FBuffer: array [0..127] of Byte;
    FBitLength: UInt64;
    FIndex: Cardinal;
    FFinalized: Boolean;

    procedure Initialize(AVersion: TSHA2Version);
    procedure CheckFinalized; inline;
    procedure Compress; inline;
    procedure Compress32;
    procedure Compress64;
    procedure Finalize; inline;
    procedure Finalize32;
    procedure Finalize64;

    function GetDigest: TBytes;
    procedure Update(const AData: PByte; ALength: Cardinal); overload;
  public
    class function Create(AHashVersion: TSHA2Version = TSHA2Version.SHA256): THashSHA2; static; inline;

    procedure Reset; inline;
    procedure Update(const AData; ALength: Cardinal); overload;
    procedure Update(const AData: TBytes; ALength: Cardinal = 0); overload; inline;
    procedure Update(const Input: string); overload; inline;

    function GetBlockSize: Integer; inline;
    function GetHashSize: Integer; inline;

    function HashAsBytes: TBytes; inline;
    function HashAsString: string; inline;

    class function GetHashBytes(const AData: string; AHashVersion: TSHA2Version = TSHA2Version.SHA256): TBytes; overload; static;
    class function GetHashString(const AString: string; AHashVersion: TSHA2Version = TSHA2Version.SHA256): string; overload; static; inline;

    class function GetHashBytes(const AStream: TStream; AHashVersion: TSHA2Version = TSHA2Version.SHA256): TBytes; overload; static;
    class function GetHashString(const AStream: TStream; AHashVersion: TSHA2Version = TSHA2Version.SHA256): string; overload; static; inline;

    class function GetHashBytesFromFile(const AFileName: TFileName; AHashVersion: TSHA2Version = TSHA2Version.SHA256): TBytes; static;
    class function GetHashStringFromFile(const AFileName: TFileName; AHashVersion: TSHA2Version = TSHA2Version.SHA256): string; static; inline;

    class function GetHMAC(const AData, AKey: string; AHashVersion: TSHA2Version = TSHA2Version.SHA256): string; static; inline;
    class function GetHMACAsBytes(const AData, AKey: string; AHashVersion: TSHA2Version = TSHA2Version.SHA256): TBytes; overload;  static;
    class function GetHMACAsBytes(const AData: string; const AKey: TBytes; AHashVersion: TSHA2Version = TSHA2Version.SHA256): TBytes; overload; static;
    class function GetHMACAsBytes(const AData: TBytes; const AKey: string; AHashVersion: TSHA2Version = TSHA2Version.SHA256): TBytes; overload; static;
    class function GetHMACAsBytes(const AData, AKey: TBytes; AHashVersion: TSHA2Version = TSHA2Version.SHA256): TBytes; overload; static;

  private
  case FVersion: TSHA2Version of
    TSHA2Version.SHA224,
    TSHA2Version.SHA256: (FHash: array[0..7] of Cardinal);
    TSHA2Version.SHA384,
    TSHA2Version.SHA512,
    TSHA2Version.SHA512_224,
    TSHA2Version.SHA512_256: (FHash64: array[0..7] of UInt64);
  end;

implementation

uses
  Types;

resourcestring
  { System.Hash }
  SHashCanNotUpdateSHA2 = 'SHA2: Cannot update a finalized hash';

{ THash }

class function THash.ToBigEndian(AValue: Cardinal): Cardinal;
begin
  Result :=
    ((AValue and $000000FF) shl 24) or
    ((AValue and $0000FF00) shl 8)  or
    ((AValue and $00FF0000) shr 8)  or
    ((AValue and $FF000000) shr 24);
end;

class function THash.ToBigEndian(AValue: UInt64): UInt64;
begin
  Result :=
    ((AValue and UInt64($00000000000000FF)) shl 56) or
    ((AValue and UInt64($000000000000FF00)) shl 40) or
    ((AValue and UInt64($0000000000FF0000)) shl 24) or
    ((AValue and UInt64($00000000FF000000)) shl 8)  or
    ((AValue and UInt64($000000FF00000000)) shr 8)  or
    ((AValue and UInt64($0000FF0000000000)) shr 24) or
    ((AValue and UInt64($00FF000000000000)) shr 40) or
    ((AValue and UInt64($FF00000000000000)) shr 56);
end;

class function THash.DigestAsInteger(const ADigest: TBytes): Integer;
begin
  if Length(ADigest) <> 4 then
    raise EHashException.Create('Digest size must be 4 to Generate a Integer');
  Result := PInteger(@ADigest[0])^;
end;

class function THash.DigestAsString(const ADigest: TBytes): string;
const
  XD: array[0..15] of char = ('0', '1', '2', '3', '4', '5', '6', '7',
                              '8', '9', 'a', 'b', 'c', 'd', 'e', 'f');
var
  I, L: Integer;
  PC: PChar;
  PB: PByte;
begin
  L := Length(ADigest);
  SetLength(Result{%H-}, L * 2);
  PC := Pointer(Result);
  PB := PByte(ADigest);
  for I := 0 to L - 1 do
  begin
    PC[0] := XD[(PB^ shr 4) and $0f];
    PC[1] := XD[PB^ and $0f];
    Inc(PC, 2);
    Inc(PB);
  end;
end;

class function THash.DigestAsStringGUID(const ADigest: TBytes): string;
var
  LGUID: TGUID;
begin
  LGUID := TGUID.Create(ADigest);
  LGUID.D1 := ToBigEndian(LGUID.D1);
  LGUID.D2 := Word((WordRec(LGUID.D2).Lo shl 8) or WordRec(LGUID.D2).Hi);
  LGUID.D3 := Word((WordRec(LGUID.D3).Lo shl 8) or WordRec(LGUID.D3).Hi);
  Result := LGUID.ToString;
end;

class function THash.GetRandomString(const ALen: Integer): string;
const
  ValidChars: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+-/*_';
var
  I, L: Integer;
  PC, PV: PChar;
begin
  L := Length(ValidChars);
  SetLength(Result{%H-}, ALen);
  PC := Pointer(Result);
  PV := Pointer(ValidChars);
  for I := 1 to ALen do
  begin
    PC^ := PV[Random(L)];
    Inc(PC);
  end;
end;

{ THashSHA2 }

class function THashSHA2.Create(AHashVersion: TSHA2Version): THashSHA2;
begin
  Result.Initialize(AHashVersion);
end;

procedure THashSHA2.CheckFinalized;
begin

end;

function THashSHA2.HashAsBytes: TBytes;
begin
  Result := GetDigest;
end;

function THashSHA2.HashAsString: string;
begin
  Result := THash.DigestAsString(GetDigest);
end;

procedure THashSHA2.Reset;
begin
  Initialize(FVersion);
end;

procedure THashSHA2.Update(const AData; ALength: Cardinal);
begin
  Update(PByte(@AData), ALength);
end;

procedure THashSHA2.Update(const AData: TBytes; ALength: Cardinal = 0);
var
  Len: Integer;
begin
  if ALength = 0 then
    Len := Length(AData)
  else
    Len := ALength;
  Update(PByte(AData), Len);
end;

procedure THashSHA2.Update(const Input: string);
begin
  Update(TEncoding.UTF8.GetBytes(Input));
end;

procedure THashSHA2.Compress;
begin
  case FVersion of
    THashSHA2.TSHA2Version.SHA224,
    THashSHA2.TSHA2Version.SHA256: Compress32;
    THashSHA2.TSHA2Version.SHA384,
    THashSHA2.TSHA2Version.SHA512,
    THashSHA2.TSHA2Version.SHA512_224,
    THashSHA2.TSHA2Version.SHA512_256: Compress64;
  end;
end;

procedure THashSHA2.Compress32;
const
  K_256: array[0..63] of Cardinal = (
   $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5, $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
   $d807aa98, $12835b01, $243185be, $550c7dc3, $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
   $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc, $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
   $983e5152, $a831c66d, $b00327c8, $bf597fc7, $c6e00bf3, $d5a79147, $06ca6351, $14292967,
   $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13, $650a7354, $766a0abb, $81c2c92e, $92722c85,
   $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3, $d192e819, $d6990624, $f40e3585, $106aa070,
   $19a4c116, $1e376c08, $2748774c, $34b0bcb5, $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
   $748f82ee, $78a5636f, $84c87814, $8cc70208, $90befffa, $a4506ceb, $bef9a3f7, $c67178f2);

  function Ch_(X, Y, Z: Cardinal): Cardinal; inline;
  begin
    Result := (X and Y) xor ((not X) and Z);
  end;
  function Maj(X, Y, Z: Cardinal): Cardinal; inline;
  begin
    Result := (X and Y) xor (X and Z) xor (Y and Z);
  end;
  function ROR(x: Cardinal; n: Byte): Cardinal; inline;
  begin
    Result := (x shr n) or (x shl (32 - n));
  end;

var
  I: Integer;
  s0, s1, t1, t2: Cardinal;
  W: array[0..63] of Cardinal;
  a, b, c, d, e, f, g, h: Cardinal;
begin
  a := FHash[0];
  b := FHash[1];
  c := FHash[2];
  d := FHash[3];
  e := FHash[4];
  f := FHash[5];
  g := FHash[6];
  h := FHash[7];

  Move(FBuffer, W, CBuffer32Length);
  //
  for I := 0 to 15 do
    W[I] := THash.ToBigEndian(W[I]);

  for I := 16 to 63 do
  begin
    s0   := ROR(W[I - 15],  7) xor ROR(W[I - 15], 18) xor (W[I - 15] shr  3);
    s1   := ROR(W[I -  2], 17) xor ROR(W[I -  2], 19) xor (W[I -  2] shr 10);
    W[I] := W[I - 16] + s0 + W[I - 7] + s1;
  end;

  //
  for I := 0 to 63 do
  begin
    s0 := ROR(a, 2) xor ROR(a, 13) xor ROR(a, 22);
    t2 := s0 + Maj(a, b, c);
    s1 := ROR(e, 6) xor ROR(e, 11) xor ROR(e, 25);

    t1 := h + s1 + Ch_(e, f, g) + K_256[I] + W[I];
    h := g;
    g := f;
    f := e;
    e := d + t1;
    d := c;
    c := b;
    b := a;
    a := t1 + t2;
  end;

  //
  FHash[0] := FHash[0] + a;
  FHash[1] := FHash[1] + b;
  FHash[2] := FHash[2] + c;
  FHash[3] := FHash[3] + d;
  FHash[4] := FHash[4] + e;
  FHash[5] := FHash[5] + f;
  FHash[6] := FHash[6] + g;
  FHash[7] := FHash[7] + h;
end;

procedure THashSHA2.Compress64;
const
  K_512: array[0..79] of UInt64 = (
      $428a2f98d728ae22, $7137449123ef65cd, $b5c0fbcfec4d3b2f, $e9b5dba58189dbbc,
      $3956c25bf348b538, $59f111f1b605d019, $923f82a4af194f9b, $ab1c5ed5da6d8118,
      $d807aa98a3030242, $12835b0145706fbe, $243185be4ee4b28c, $550c7dc3d5ffb4e2,
      $72be5d74f27b896f, $80deb1fe3b1696b1, $9bdc06a725c71235, $c19bf174cf692694,
      $e49b69c19ef14ad2, $efbe4786384f25e3, $0fc19dc68b8cd5b5, $240ca1cc77ac9c65,
      $2de92c6f592b0275, $4a7484aa6ea6e483, $5cb0a9dcbd41fbd4, $76f988da831153b5,
      $983e5152ee66dfab, $a831c66d2db43210, $b00327c898fb213f, $bf597fc7beef0ee4,
      $c6e00bf33da88fc2, $d5a79147930aa725, $06ca6351e003826f, $142929670a0e6e70,
      $27b70a8546d22ffc, $2e1b21385c26c926, $4d2c6dfc5ac42aed, $53380d139d95b3df,
      $650a73548baf63de, $766a0abb3c77b2a8, $81c2c92e47edaee6, $92722c851482353b,
      $a2bfe8a14cf10364, $a81a664bbc423001, $c24b8b70d0f89791, $c76c51a30654be30,
      $d192e819d6ef5218, $d69906245565a910, $f40e35855771202a, $106aa07032bbd1b8,
      $19a4c116b8d2d0c8, $1e376c085141ab53, $2748774cdf8eeb99, $34b0bcb5e19b48a8,
      $391c0cb3c5c95a63, $4ed8aa4ae3418acb, $5b9cca4f7763e373, $682e6ff3d6b2b8a3,
      $748f82ee5defb2fc, $78a5636f43172f60, $84c87814a1f0ab72, $8cc702081a6439ec,
      $90befffa23631e28, $a4506cebde82bde9, $bef9a3f7b2c67915, $c67178f2e372532b,
      $ca273eceea26619c, $d186b8c721c0c207, $eada7dd6cde0eb1e, $f57d4f7fee6ed178,
      $06f067aa72176fba, $0a637dc5a2c898a6, $113f9804bef90dae, $1b710b35131c471b,
      $28db77f523047d84, $32caab7b40c72493, $3c9ebe0a15c9bebc, $431d67c49c100d4c,
      $4cc5d4becb3e42b6, $597f299cfc657e2a, $5fcb6fab3ad6faec, $6c44198c4a475817);

  function Ch_(X, Y, Z: UInt64): UInt64; inline;
  begin
    Result := (X and Y) xor ((not X) and Z);
  end;
  function Maj(X, Y, Z: UInt64): UInt64; inline;
  begin
    Result := (X and Y) xor (X and Z) xor (Y and Z);
  end;
  function ROR(x: UInt64; n: Byte): UInt64; inline;
  begin
    Result := (x shr n) or (x shl (64 - n));
  end;

var
  I: Integer;
  s0, s1, t1, t2: UInt64;
  W: array[0..79] of UInt64;
  a, b, c, d, e, f, g, h: UInt64;
begin
  a := FHash64[0];
  b := FHash64[1];
  c := FHash64[2];
  d := FHash64[3];
  e := FHash64[4];
  f := FHash64[5];
  g := FHash64[6];
  h := FHash64[7];

  Move(FBuffer, W, CBuffer64Length);
  for I := 0 to 15 do
    W[I] := THash.ToBigEndian(W[I]);

  for I := 16 to 79 do
  begin
    s0   := ROR(W[I - 15],  1) xor ROR(W[I - 15],  8) xor (W[I - 15] shr 7);
    s1   := ROR(W[I -  2], 19) xor ROR(W[I -  2], 61) xor (W[I -  2] shr 6);
    W[I] := W[I - 16] + s0 + W[I - 7] + s1;
  end;

  for I := 0 to 79 do
  begin
    s0 := ROR(a, 28) xor ROR(a, 34) xor ROR(a, 39);
    t2 := s0 + Maj(a, b, c);
    s1 := ROR(e, 14) xor ROR(e, 18) xor ROR(e, 41);

    t1 := h + s1 + Ch_(e, f, g) + K_512[I] + W[I];
    h := g;
    g := f;
    f := e;
    e := d + t1;
    d := c;
    c := b;
    b := a;
    a := t1 + t2;
  end;

  FHash64[0] := FHash64[0] + a;
  FHash64[1] := FHash64[1] + b;
  FHash64[2] := FHash64[2] + c;
  FHash64[3] := FHash64[3] + d;
  FHash64[4] := FHash64[4] + e;
  FHash64[5] := FHash64[5] + f;
  FHash64[6] := FHash64[6] + g;
  FHash64[7] := FHash64[7] + h;
end;

class function THashSHA2.GetHashBytes(const AData: string; AHashVersion: TSHA2Version): TBytes;
var
  LSHA2: THashSHA2;
begin
  LSHA2 := THashSHA2.Create(AHashVersion);
  LSHA2.Update(AData);
  Result := LSHA2.GetDigest;
end;

function THashSHA2.GetHashSize: Integer;
begin
  case FVersion of
    TSHA2Version.SHA224: Result := 28;
    TSHA2Version.SHA256: Result := 32;
    TSHA2Version.SHA384: Result := 48;
    TSHA2Version.SHA512: Result := 64;
    TSHA2Version.SHA512_224: Result := 28;
    TSHA2Version.SHA512_256: Result := 32;
  else
    Result := 0;
  end;
end;

class function THashSHA2.GetHashString(const AString: string; AHashVersion: TSHA2Version): string;
var
  LSHA2: THashSHA2;
begin
  LSHA2 := THashSHA2.Create(AHashVersion);
  LSHA2.Update(AString);
  Result := LSHA2.HashAsString;
end;

class function THashSHA2.GetHMAC(const AData, AKey: string; AHashVersion: TSHA2Version): string;
begin
  Result := THash.DigestAsString(GetHMACAsBytes(AData, AKey, AHashVersion));
end;

class function THashSHA2.GetHMACAsBytes(const AData: string; const AKey: TBytes; AHashVersion: TSHA2Version): TBytes;
begin
  Result := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), AKey, AHashVersion);
end;

class function THashSHA2.GetHMACAsBytes(const AData, AKey: string; AHashVersion: TSHA2Version): TBytes;
begin
  Result := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), TEncoding.UTF8.GetBytes(AKey), AHashVersion);
end;

class function THashSHA2.GetHMACAsBytes(const AData: TBytes; const AKey: string; AHashVersion: TSHA2Version): TBytes;
begin
  Result := GetHMACAsBytes(AData, TEncoding.UTF8.GetBytes(AKey), AHashVersion);
end;

class function THashSHA2.GetHMACAsBytes(const AData, AKey: TBytes; AHashVersion: TSHA2Version): TBytes;
const
  CInnerPad : Byte = $36;
  COuterPad : Byte = $5C;
var
  TempBuffer1: TBytes;
  TempBuffer2: TBytes;
  FKey: TBytes;
  LKey: TBytes;
  I: Integer;
  FHash: THashSHA2;
  LBuffer: TBytes;
  LHashSize: Integer;
  LBlockSize: Integer;
begin
  FHash := THashSHA2.Create(AHashVersion);
  LBlockSize := FHash.GetBlockSize;

  LBuffer := AData;

  FKey := AKey;
  if Length(FKey) > LBlockSize then
  begin
    FHash.Update(FKey);
    FKey := Copy(FHash.GetDigest);
  end;

  LKey := Copy(FKey, 0, MaxInt);
  SetLength(LKey, LBlockSize);
  SetLength(TempBuffer1, LBlockSize + Length(LBuffer));
  for I := Low(LKey) to High(LKey) do
    TempBuffer1[I] := LKey[I] xor CInnerPad;

  if Length(LBuffer) > 0 then
    Move(LBuffer[0], TempBuffer1[Length(LKey)], Length(LBuffer));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  TempBuffer2 := FHash.GetDigest;

  LHashSize := Length(TempBuffer2);

  SetLength(TempBuffer1, LBlockSize + LHashSize);
  for I := Low(LKey) to High(LKey) do
    TempBuffer1[I] := LKey[I] xor COuterPad;

  Move(TempBuffer2[0], TempBuffer1[Length(LKey)], Length(TempBuffer2));

  FHash.Reset;
  FHash.Update(TempBuffer1);
  Result := FHash.GetDigest;
end;

class function THashSHA2.GetHashBytes(const AStream: TStream; AHashVersion: TSHA2Version): TBytes;
const
  BUFFERSIZE = 4 * 1024;
var
  LSHA2: THashSHA2;
  LBuffer: TBytes;
  LBytesRead: Longint;
begin
  LSHA2 := THashSHA2.Create(AHashVersion);
  SetLength(LBuffer, BUFFERSIZE);
  while True do
  begin
    LBytesRead := AStream.Read(LBuffer, BUFFERSIZE);
    if LBytesRead = 0 then
      Break;
    LSHA2.Update(LBuffer, LBytesRead);
  end;
  Result := LSHA2.GetDigest;
end;

class function THashSHA2.GetHashString(const AStream: TStream; AHashVersion: TSHA2Version): string;
begin
  Result := THash.DigestAsString(GetHashBytes(AStream, AHashVersion));
end;

procedure THashSHA2.Finalize;
begin
  CheckFinalized;
  case FVersion of
    THashSHA2.TSHA2Version.SHA224,
    THashSHA2.TSHA2Version.SHA256: Finalize32;
    THashSHA2.TSHA2Version.SHA384,
    THashSHA2.TSHA2Version.SHA512,
    THashSHA2.TSHA2Version.SHA512_224,
    THashSHA2.TSHA2Version.SHA512_256: Finalize64;
  end;
  FFinalized := True;
end;

procedure THashSHA2.Finalize32;
var
  I: Integer;
begin
  FBuffer[FIndex] := $80;
  if FIndex >= 56 then
  begin
    for I := FIndex + 1 to CBuffer32Length - 1 do
      FBuffer[I] := $00;
    Compress;
    FIndex := 0;
  end
  else
    Inc(FIndex);

  // No need to clean the bytes used for the BitLength
  FillChar(FBuffer[FIndex], (CBuffer32Length - 8) - FIndex, 0);

  PCardinal(@FBuffer[56])^ := THash.ToBigEndian(Cardinal(FBitLength shr 32));
  PCardinal(@FBuffer[60])^ := THash.ToBigEndian(Cardinal(FBitLength));
  Compress;
  FHash[0] := THash.ToBigEndian(FHash[0]);
  FHash[1] := THash.ToBigEndian(FHash[1]);
  FHash[2] := THash.ToBigEndian(FHash[2]);
  FHash[3] := THash.ToBigEndian(FHash[3]);
  FHash[4] := THash.ToBigEndian(FHash[4]);
  FHash[5] := THash.ToBigEndian(FHash[5]);
  FHash[6] := THash.ToBigEndian(FHash[6]);
  FHash[7] := THash.ToBigEndian(FHash[7]);
end;

procedure THashSHA2.Finalize64;
var
  I: Integer;
begin
  FBuffer[FIndex] := $80;
  if FIndex >= 112 then
  begin
    for I := FIndex + 1 to CBuffer64Length - 1 do
      FBuffer[I] := $00;
    Compress;
    FIndex := 0;
  end
  else
    Inc(FIndex);

  //
  FillChar(FBuffer[FIndex], (CBuffer64Length - 16) - FIndex, 0);


  PCardinal(@FBuffer[112])^ := 0;
  PCardinal(@FBuffer[116])^ := 0;
  PCardinal(@FBuffer[120])^ := THash.ToBigEndian(Cardinal(FBitLength shr 32));
  PCardinal(@FBuffer[124])^ := THash.ToBigEndian(Cardinal(FBitLength));
  Compress;
  FHash64[0] := THash.ToBigEndian(FHash64[0]);
  FHash64[1] := THash.ToBigEndian(FHash64[1]);
  FHash64[2] := THash.ToBigEndian(FHash64[2]);
  FHash64[3] := THash.ToBigEndian(FHash64[3]);
  FHash64[4] := THash.ToBigEndian(FHash64[4]);
  FHash64[5] := THash.ToBigEndian(FHash64[5]);
  FHash64[6] := THash.ToBigEndian(FHash64[6]);
  FHash64[7] := THash.ToBigEndian(FHash64[7]);
end;

function THashSHA2.GetBlockSize: Integer;
begin
  case FVersion of
    THashSHA2.TSHA2Version.SHA224,
    THashSHA2.TSHA2Version.SHA256: Result := 64;
    THashSHA2.TSHA2Version.SHA384,
    THashSHA2.TSHA2Version.SHA512,
    THashSHA2.TSHA2Version.SHA512_224,
    THashSHA2.TSHA2Version.SHA512_256: Result := 128;
  else
    Result := 0;
  end;
end;

function THashSHA2.GetDigest: TBytes;
var
  LHashSize: Integer;
begin
  if not FFinalized then
    Finalize;

  LHashSize := GetHashSize;
  SetLength(Result, LHashSize);

  case FVersion of
    TSHA2Version.SHA224,
    TSHA2Version.SHA256:
      Move(FHash[0], Result[0], LHashSize);

    TSHA2Version.SHA384,
    TSHA2Version.SHA512,
    TSHA2Version.SHA512_224,
    TSHA2Version.SHA512_256:
      Move(FHash64[0], Result[0], LHashSize);
  end;
end;

class function THashSHA2.GetHashBytesFromFile(const AFileName: TFileName; AHashVersion: TSHA2Version): TBytes;
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(AFileName, fmShareDenyNone or fmOpenRead);
  try
    Result := GetHashBytes(LFile, AHashVersion);
  finally
    LFile.Free;
  end;
end;

class function THashSHA2.GetHashStringFromFile(const AFileName: TFileName; AHashVersion: TSHA2Version): string;
begin
  Result := THash.DigestAsString(GetHashBytesFromFile(AFileName, AHashVersion));
end;

procedure THashSHA2.Initialize(AVersion: TSHA2Version);
begin
  FillChar(Self, SizeOf(Self), 0);
  FVersion := AVersion;
  case FVersion of
    TSHA2Version.SHA224:
    begin
      FHash[0]:= $c1059ed8;
      FHash[1]:= $367cd507;
      FHash[2]:= $3070dd17;
      FHash[3]:= $f70e5939;
      FHash[4]:= $ffc00b31;
      FHash[5]:= $68581511;
      FHash[6]:= $64f98fa7;
      FHash[7]:= $befa4fa4;
    end;

    TSHA2Version.SHA256:
    begin
      FHash[0]:= $6a09e667;
      FHash[1]:= $bb67ae85;
      FHash[2]:= $3c6ef372;
      FHash[3]:= $a54ff53a;
      FHash[4]:= $510e527f;
      FHash[5]:= $9b05688c;
      FHash[6]:= $1f83d9ab;
      FHash[7]:= $5be0cd19;
    end;

    TSHA2Version.SHA384:
    begin
      FHash64[0]:= $cbbb9d5dc1059ed8;
      FHash64[1]:= $629a292a367cd507;
      FHash64[2]:= $9159015a3070dd17;
      FHash64[3]:= $152fecd8f70e5939;
      FHash64[4]:= $67332667ffc00b31;
      FHash64[5]:= $8eb44a8768581511;
      FHash64[6]:= $db0c2e0d64f98fa7;
      FHash64[7]:= $47b5481dbefa4fa4;
    end;

    TSHA2Version.SHA512:
    begin
      FHash64[0]:= $6a09e667f3bcc908;
      FHash64[1]:= $bb67ae8584caa73b;
      FHash64[2]:= $3c6ef372fe94f82b;
      FHash64[3]:= $a54ff53a5f1d36f1;
      FHash64[4]:= $510e527fade682d1;
      FHash64[5]:= $9b05688c2b3e6c1f;
      FHash64[6]:= $1f83d9abfb41bd6b;
      FHash64[7]:= $5be0cd19137e2179;
    end;

    TSHA2Version.SHA512_224:
    begin
      FHash64[0]:= $8C3D37C819544DA2;
      FHash64[1]:= $73E1996689DCD4D6;
      FHash64[2]:= $1DFAB7AE32FF9C82;
      FHash64[3]:= $679DD514582F9FCF;
      FHash64[4]:= $0F6D2B697BD44DA8;
      FHash64[5]:= $77E36F7304C48942;
      FHash64[6]:= $3F9D85A86A1D36C8;
      FHash64[7]:= $1112E6AD91D692A1;
    end;

    TSHA2Version.SHA512_256:
    begin
      FHash64[0]:= $22312194FC2BF72C;
      FHash64[1]:= $9F555FA3C84C64C2;
      FHash64[2]:= $2393B86B6F53B151;
      FHash64[3]:= $963877195940EABD;
      FHash64[4]:= $96283EE2A88EFFE3;
      FHash64[5]:= $BE5E1E2553863992;
      FHash64[6]:= $2B0199FC2C85B8AA;
      FHash64[7]:= $0EB72DDC81C52CA2;
    end;
  end;
end;

procedure THashSHA2.Update(const AData: PByte; ALength: Cardinal);
var
  PBuffer: PByte;
  I: Integer;
  Count: Integer;
  LBufLen: Cardinal;
  LRest: Integer;
begin
  CheckFinalized;
  PBuffer := AData;
  LBufLen := GetBlockSize;


  Inc(FBitLength, UInt64(ALength) * 8);

  // Code Option A
  Count := (ALength + FIndex) div LBufLen;
  if Count > 0  then
  begin
    LRest := LBufLen - FIndex;
    Move(PBuffer^, FBuffer[FIndex], LRest);
    Inc(PBuffer, LRest);
    Dec(ALength, LRest);
    Compress;
    for I := 1 to Count - 1 do
    begin
      Move(PBuffer^, FBuffer[0], LBufLen);
      Inc(PBuffer, LBufLen);
      Dec(ALength, LBufLen);
      Compress;
    end;
    FIndex := 0;
  end;
  Move(PBuffer^, FBuffer[FIndex], ALength);
  Inc(FIndex, ALength);
end;


end.
