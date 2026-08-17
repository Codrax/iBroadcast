{***********************************************************}
{                    Codruts JSON Parser                    }
{                                                           }
{                        version 1.0                        }
{                           BETA                            }
{                                                           }
{                                                           }
{              Developed by Petculescu Codrut               }
{            Copyright (c) 2025 Codrut Software.            }
{***********************************************************}

///  INFO
///  For typecasting, use the "AS" operator, because "AS" performs a interface
///  query, where as typecasting does not.
///  IJArray(Item)    -> WRONG
///  Item as IJArray  -> CORRECT


// Types
{$DEFINE LARGEJINT}
{$DEFINE LARGEJFLOAT}
{$SCOPEDENUMS ON}

// FPC
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

// Compatability
//{$DEFINE STRINGCOMPATABILITY}

unit Cod.JSON;

interface
uses
  SysUtils, Classes, {$IFDEF MSWINDOWS}Windows,{$ENDIF}
  Generics.Collections, Generics.Defaults, Dialogs
  {$IFDEF FPC}, Cod.Platform.Lazarus{$ELSE}, IOUtils{$ENDIF};

const
  DEFAULT_IDENT = 4;

type
  JNumber = {$IFDEF LARGEJINT}int64{$ELSE}integer{$ENDIF};
  JFloat = {$IFDEF LARGEJFLOAT}Extended{$ELSE}Double{$ENDIF};

  // [Interfaces]
  IJValue = interface;
  IJObject = interface;
  IJArray = interface;

  TIJObjectForEach = {$IFNDEF FPC}reference to{$ENDIF} procedure (Key: string; const Item: IJValue);
  TIJArrayForEach = {$IFNDEF FPC}reference to{$ENDIF} procedure (const Item: IJValue);

  IJValue = interface(IInterface)
    ['{b1327b67-c9aa-4d5a-8049-397b7634dd62}']
    function AsObject: IJObject;
    function AsArray: IJArray;
    function AsString: string;
    function AsInteger: JNumber;
    function AsBoolean: Boolean;
    function AsFloat: JFloat;

    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsString: Boolean;
    function IsInteger: Boolean;
    function IsFloat: Boolean;
    function IsBoolean: Boolean;

    function Copy: IJValue;
    function ToJSON: string;
    function Format(Indentation: Integer=DEFAULT_IDENT; BaseIdent: Integer=0): string;
  end;

  IJObject = interface(IJValue)
    ['{fbddbaa5-cc22-4b15-b9bd-3a92ce1aa016}']
    function GetSorted: boolean;
    procedure SetSorted(const Value: boolean);

    procedure Clear;

    procedure ForEach(Callback: TIJObjectForEach);
    procedure MemoryForEach(Callback: TIJObjectForEach);

    function GetItemKey(Index: Integer): string;
    function GetKeyIndex(Key: string): Integer;

    function KeyExists(Key: string): boolean; overload;
    function KeyExists(Key: string; out Value: IJValue): boolean; overload;

    function Get(Index: Integer): IJValue; overload;
    function Get(Key: string): IJValue; overload;
    function GetMemory(Index: Integer): IJValue; overload;
    function GetMemory(Key: string): IJValue; overload;
    procedure Put(Index: Integer; const Value: IJValue); overload;
      procedure Put(Index: Integer; Value: string); overload;
      procedure Put(Index: Integer; Value: Integer); overload;
      procedure Put(Index: Integer; Value: JFloat); overload;
      procedure Put(Index: Integer; Value: Boolean); overload;
    procedure Put(Key: string; const Value: IJValue); overload;
      procedure Put(Key: string; Value: string); overload;
      procedure Put(Key: string; Value: Integer); overload;
      procedure Put(Key: string; Value: JFloat); overload;
      procedure Put(Key: string; Value: Boolean); overload;
    procedure Remove(Index: Integer); overload;
    procedure Remove(Key: string); overload;
    procedure Rename(Key: string; NewName: string); overload;
    procedure Rename(Index: Integer; NewName: string); overload;
    procedure MoveBefore(KeyToMove, TargetKey: string); overload;
    procedure MoveBefore(IndexToMove, TargetIndex: integer); overload;
    procedure SwitchWith(Key1, Key2: string); overload;
    procedure SwitchWith(Index1, Index2: integer); overload;

    property Items[Key: string]: IJValue read Get write Put; default;
    property Memory[Key: string]: IJValue read GetMemory;

    function Count: Integer;

    procedure Sort;
    property Sorted: boolean read GetSorted write SetSorted;
  end;

  IJArray = interface(IJValue)
    ['{dfc7c578-7bda-4a9f-b5f0-503d34e0c20c}']
    procedure Clear;

    procedure ForEach(Callback: TIJArrayForEach);
    procedure MemoryForEach(Callback: TIJArrayForEach);

    function Get(Index: Integer): IJValue;
    function GetMemory(Index: Integer): IJValue;
    procedure Put(Index: Integer; const Value: IJValue);
    procedure Remove(Index: Integer);

    function Count: Integer;

    procedure Add(Value: IJValue); overload;
      procedure Add(Value: string); overload;
      procedure Add(Value: Integer); overload;
      procedure Add(Value: JFloat); overload;
      procedure Add(Value: Boolean); overload;
    procedure Insert(Index: Integer; Value: IJValue); overload;
      procedure Insert(Index: Integer; Value: string); overload;
      procedure Insert(Index: Integer; Value: Integer); overload;
      procedure Insert(Index: Integer; Value: JFloat); overload;
      procedure Insert(Index: Integer; Value: Boolean); overload;

    property Items[Index: Integer]: IJValue read Get write Put; default;
    property Memory[Key: Integer]: IJValue read GetMemory;
  end;

  // [Classes]
  // Values pre-define
  TJNull = class;
  TJObject = class;
  TJArray = class;
  TJString = class;
  TJInteger = class;
  TJFloat = class;
  TJBoolean = class;

  TJValueWriteToFileFlag = (FlushFileToDisk, PrettyPrint);
  TJValueWriteToFileFlags = set of TJValueWriteToFileFlag;

  // Main value
  TJValue = class(TInterfacedObject, IJValue) {By default, this represents the null class}
  public
    constructor Create;
    destructor Destroy; override;


    function AsObject: IJObject; virtual;
    function AsArray: IJArray; virtual;
    function AsString: string; virtual;
    function AsInteger: JNumber; virtual;
    function AsFloat: JFloat; virtual;
    function AsBoolean: Boolean; virtual;

    function IsObject: Boolean; virtual;
    function IsArray: Boolean; virtual;
    function IsString: Boolean; virtual;
    function IsInteger: Boolean; virtual;
    function IsFloat: Boolean; virtual;
    function IsBoolean: Boolean; virtual;

    function IsNull: Boolean;

    function Copy: IJValue; virtual;
    function ToJSON: string; virtual;
    function Format(Indentation: Integer=DEFAULT_IDENT; BaseIdent: Integer=0): string; virtual;

    class procedure SaveToFile(Value: IJValue; FilePath: string; Flags: TJValueWriteToFileFlags=[]); static;
    class function LoadFromFile(FilePath: string): IJValue; static;

    // Constructor 2
    class function CreateNew: IJValue; overload; static; // null
    class function CreateNew(Value: string): IJValue; overload; static;
    class function CreateNew(Value: Integer): IJValue; overload; static;
    class function CreateNew(Value: JFloat): IJValue; overload; static;
    class function CreateNew(Value: Boolean): IJValue; overload; static;

    class function ParseJson(Source: string): IJValue; static;
  end;

  // V*Null
  TJNull = class(TJValue);

  // V*Object
  TJObject = class(TJValue, IJObject)
  private
    type TPair = record
        Key: string;
        Item: IJValue;
      end;
    var
    FList: TList<TPair>;
    FSortedKeys: boolean;

  protected
    procedure _addKey(Key: string; const Value: IJValue);

  public
    constructor Create;
    destructor Destroy; override;

    function GetSorted: boolean;
    procedure SetSorted(const Value: boolean);

    procedure Clear;

    procedure ForEach(Callback: TIJObjectForEach);
    procedure MemoryForEach(Callback: TIJObjectForEach);

    // Value
    function AsObject: IJObject; override;
    function IsObject: Boolean; override;

    function Copy: IJValue; override;
    function ToJSON: string; override;
    function Format(Indentation: Integer=DEFAULT_IDENT; BaseIdent: integer=0): string; override;

    // List
    function GetItemKey(Index: Integer): string;
    function GetKeyIndex(Key: string): Integer;

    function KeyExists(Key: string): boolean; overload;
    function KeyExists(Key: string; out Value: IJValue): boolean; overload;

    function Get(Index: Integer): IJValue; overload;
    function Get(Key: string): IJValue; overload;
    function GetMemory(Index: Integer): IJValue; overload;
    function GetMemory(Key: string): IJValue; overload;
    procedure Put(Index: Integer; const Value: IJValue); overload;
      procedure Put(Index: Integer; Value: string); overload;
      procedure Put(Index: Integer; Value: Integer); overload;
      procedure Put(Index: Integer; Value: JFloat); overload;
      procedure Put(Index: Integer; Value: Boolean); overload;
    procedure Put(Key: string; const Value: IJValue); overload;
      procedure Put(Key: string; Value: string); overload;
      procedure Put(Key: string; Value: Integer); overload;
      procedure Put(Key: string; Value: JFloat); overload;
      procedure Put(Key: string; Value: Boolean); overload;
    procedure Remove(Index: Integer); overload;
    procedure Remove(Key: string); overload;
    procedure Rename(Key: string; NewName: string); overload;
    procedure Rename(Index: Integer; NewName: string); overload;
    procedure MoveBefore(KeyToMove, TargetKey: string);  overload;
    procedure MoveBefore(IndexToMove, TargetIndex: integer); overload;
    procedure SwitchWith(Key1, Key2: string); overload;
    procedure SwitchWith(Index1, Index2: integer); overload;

    property Items[Key: string]: IJValue read Get write Put; default;
    property Memory[Key: string]: IJValue read GetMemory;

    function Count: Integer;

    procedure Sort;
    property Sorted: boolean read GetSorted write SetSorted;

    // Constructor 2
    class function CreateNew: IJObject; static;
  end;

  // V*Array
  TJArray = class(TJValue, IJArray)
  private
    FList: TList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    procedure ForEach(Callback: TIJArrayForEach);
    procedure MemoryForEach(Callback: TIJArrayForEach);

    // Value
    function AsArray: IJArray; override;
    function IsArray: Boolean; override;

    function Copy: IJValue; override;
    function ToJSON: string; override;
    function Format(Indentation: Integer=DEFAULT_IDENT; BaseIdent: integer=0): string; override;

    // List
    function Get(Index: Integer): IJValue;
    function GetMemory(Index: Integer): IJValue;
    procedure Put(Index: Integer; const Value: IJValue);
    procedure Remove(Index: Integer);

    function Count: Integer;

    procedure Add(Value: IJValue); overload;
      procedure Add(Value: string); overload;
      procedure Add(Value: Integer); overload;
      procedure Add(Value: JFloat); overload;
      procedure Add(Value: Boolean); overload;
    procedure Insert(Index: Integer; Value: IJValue); overload;
      procedure Insert(Index: Integer; Value: string); overload;
      procedure Insert(Index: Integer; Value: Integer); overload;
      procedure Insert(Index: Integer; Value: JFloat); overload;
      procedure Insert(Index: Integer; Value: Boolean); overload;

    property Items[Index: Integer]: IJValue read Get write Put; default;
    property Memory[Key: Integer]: IJValue read GetMemory;

    // Constructor 2
    class function CreateNew: IJArray; static;
  end;

  // V*String
  TJString = class(TJValue)
  private
    FValue: string;
  public
    constructor Create(Value: string);

    function AsString: string; override;
    function IsString: Boolean; override;

    function Copy: IJValue; override;
    function ToJSON: string; override;

    // Constructor 2
    class function CreateNew(Value: string): TJString; static;
  end;

  // V*Integer / Int64
  TJInteger = class(TJValue)
  private
    FValue: JNumber;
  public
    constructor Create(Value: JNumber);

    {$IFDEF STRINGCOMPATABILITY}
    function AsString: string; override;
    {$ENDIF}

    function AsInteger: JNumber; override;
    function IsInteger: Boolean; override;

    // Also is float
    function AsFloat: JFloat; override;
    function IsFloat: Boolean; override;

    function Copy: IJValue; override;
    function ToJSON: string; override;

    // Constructor 2
    class function CreateNew(Value: string): TJInteger; static;
  end;

  // V*Float
  TJFloat = class(TJValue)
  private
    FValue: JFloat;
  public
    constructor Create(Value: JFloat);

    {$IFDEF STRINGCOMPATABILITY}
    function AsString: string; override;
    {$ENDIF}

    function AsFloat: JFloat; override;
    function IsFloat: Boolean; override;

    function Copy: IJValue; override;
    function ToJSON: string; override;

    // Constructor 2
    class function CreateNew(Value: string): TJFloat; static;
  end;

  // V*Boolean
  TJBoolean = class(TJValue)
  private
    FValue: Boolean;
  public
    constructor Create(Value: Boolean);

    {$IFDEF STRINGCOMPATABILITY}
    function AsString: string; override;
    {$ENDIF}

    function AsBoolean: Boolean; override;
    function IsBoolean: Boolean; override;

    function Copy: IJValue; override;
    function ToJSON: string; override;

    // Constructor 2
    class function CreateNew(Value: string): TJBoolean; static;
  end;

// Functions
function StringToJValue(Json: string): IJValue;

type
  TEJIncorrectJValueType = type Exception;
  TEJInvalidJsonFormat = type Exception;
  TEJObjectKeyDoesNotExists = type Exception;
  TEJKeyAlreadyExists = type Exception;

  // Parser
  TEJParserInvalidJSONString = type Exception;
  TEJParserInvalidEscapeSequence = type Exception;
  TEJParserInvalidCharacter = type Exception;
  TEJParserUnknownEscapeSequence = type Exception;

implementation

function StringToJValue(Json: string): IJValue;
begin
  Result := TJValue.ParseJson(JSON);
end;

function CreateIdent(Count: integer): string;
var
   I: integer;
begin
  Result := '';
  for I := 1 to Count do
    Result := Result + ' ';
end;

function StringValueToJSONString(const Value: string): string;
var
  P, PEnd: PChar;
  UnicodeValue: Integer;
  Buff: array [0 .. 5] of Char;
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('"'); // Open quote

    P := PChar(Value);
    PEnd := P + Length(Value);

    while P < PEnd do
    begin
      case P^ of
        '"': SB.Append('\"');
        '\': SB.Append('\\');
        '/': SB.Append('\/');
        #$8: SB.Append('\b');
        #$9: SB.Append('\t');
        #$a: SB.Append('\n');
        #$c: SB.Append('\f');
        #$d: SB.Append('\r');
        #0 .. #7, #$b, #$e .. #31, #$80 .. High(Char):
          begin
            UnicodeValue := Ord(P^);
            Buff[0] := '\';
            Buff[1] := 'u';
            Buff[2] := IntToHex((UnicodeValue shr 12) and $F, 1)[1];
            Buff[3] := IntToHex((UnicodeValue shr 8) and $F, 1)[1];
            Buff[4] := IntToHex((UnicodeValue shr 4) and $F, 1)[1];
            Buff[5] := IntToHex(UnicodeValue and $F, 1)[1];
            SB.Append(Buff);
          end;
      else
        SB.Append(P^);
      end;
      Inc(P);
    end;

    SB.Append('"'); // Close quote
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function JSONStringToStringValue(const JSONStr: string): string;
var
  I, Len: Integer;
  Ch: Char;
  SB: TStringBuilder;
  UnicodeHex: string;
  UnicodeVal: Integer;
begin
  if (JSONStr = '') or (JSONStr[1] <> '"') or (JSONStr[Length(JSONStr)] <> '"') then
    raise TEJParserInvalidJSONString.Create('Invalid JSON string.');

  SB := TStringBuilder.Create;
  try
    I := 2; // Skip initial quote
    Len := Length(JSONStr);

    while I < Len do
    begin
      Ch := JSONStr[I];

      if Ch = '\' then
      begin
        Inc(I);
        if I >= Len then
          raise TEJParserInvalidEscapeSequence.Create('Invalid escape sequence in JSON string.');

        case JSONStr[I] of
          '"': SB.Append('"');
          '\': SB.Append('\');
          '/': SB.Append('/');
          'b': SB.Append(#8);
          'f': SB.Append(#12);
          'n': SB.Append(#10);
          'r': SB.Append(#13);
          't': SB.Append(#9);
          'u':
            begin
              if I + 4 >= Len then
                raise TEJParserInvalidCharacter.Create('Incomplete \u escape in JSON string');

              UnicodeHex := Copy(JSONStr, I + 1, 4);
              if not TryStrToInt('$' + UnicodeHex, UnicodeVal) then
                raise TEJParserInvalidCharacter.Create('Invalid \uXXXX escape in JSON string');

              SB.Append(Char(UnicodeVal));
              Inc(I, 4); // skip the next 4 digits
            end;
        else
          raise TEJParserUnknownEscapeSequence.CreateFmt('Unknown escape sequence: \%s', [JSONStr[I]]);
        end;
      end
      else
        SB.Append(Ch);

      Inc(I);
    end;

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

{ TJValue }

function TJValue.AsArray: IJArray;
begin
  Result := nil;
  raise TEJIncorrectJValueType.Create('JValue is not of [ARRAY] type.');
end;

function TJValue.AsBoolean: Boolean;
begin           
  Result := false;
  raise TEJIncorrectJValueType.Create('JValue is not of [BOOLEAN] type.');
end;

function TJValue.AsFloat: JFloat;
begin          
  Result := 0;
  raise TEJIncorrectJValueType.Create('JValue is not of [FLOAT] type.');
end;

function TJValue.AsInteger: JNumber;
begin       
  Result := 0;
  raise TEJIncorrectJValueType.Create('JValue is not of [INTEGER] type.');
end;

function TJValue.AsObject: IJObject;
begin     
  Result := nil;
  raise TEJIncorrectJValueType.Create('JValue is not of [OBJECT] type.');
end;

function TJValue.AsString: string;
begin
  {$IFDEF STRINGCOMPATABILITY}
  Exit('null');
  {$ELSE}
  Result := '';
  raise TEJIncorrectJValueType.Create('JValue is not of [STRING] type.');
  {$ENDIF}
end;

function TJValue.Copy: IJValue;
begin
  Result := TJValue.Create;
end;

constructor TJValue.Create;
begin
  inherited Create;
end;

class function TJValue.CreateNew(Value: string): IJValue;
begin
  Result := TJString.Create(Value);
end;

class function TJValue.CreateNew(Value: Integer): IJValue;
begin
  Result := TJInteger.Create(Value);
end;

class function TJValue.CreateNew(Value: JFloat): IJValue;
begin
  Result := TJFloat.Create(Value);
end;

class function TJValue.CreateNew(Value: Boolean): IJValue;
begin
  Result := TJBoolean.Create(Value);
end;

class function TJValue.CreateNew: IJValue;
begin
  Result := TJValue.Create;
end;

destructor TJValue.Destroy;
begin
  inherited;
end;

function TJValue.Format(Indentation: Integer; BaseIdent: Integer): string;
begin
  Result := ToJSON;
end;

function TJValue.IsArray: Boolean;
begin
  Result := false;
end;

function TJValue.IsBoolean: Boolean;
begin
  Result := false;
end;

function TJValue.IsFloat: Boolean;
begin
  Result := false;
end;

function TJValue.IsInteger: Boolean;
begin
  Result := false;
end;

function TJValue.IsNull: Boolean;
begin
  Result := not (IsObject or IsArray or IsString or IsInteger or IsFloat or IsBoolean);
end;

function TJValue.IsObject: Boolean;
begin
  Result := false;
end;

function TJValue.IsString: Boolean;
begin
  Result := false;
end;

class function TJValue.LoadFromFile(FilePath: string): IJValue;
begin
  Result := TJValue.ParseJson(TFile.ReadAllText(FilePath{$IFNDEF FPC}, TEncoding.UTF8{$ENDIF}));
end;

class procedure TJValue.SaveToFile(Value: IJValue; FilePath: string; Flags: TJValueWriteToFileFlags);
var
  Contents: string;
  {$IFDEF MSWINDOWS}
  LFileStream: TFileStream;
  Buff: TBytes;
  {$ENDIF}
begin
  if TJValueWriteToFileFlag.PrettyPrint in Flags then
    Contents := Value.Format()
  else
    Contents := Value.ToJSON;
  {$IFDEF MSWINDOWS}
  LFileStream := nil;
  try
    LFileStream := TFile.Create(FilePath);
    // Write BOM encoding prefix
      Buff := TEncoding.UTF8.GetPreamble;
      LFileStream.WriteBuffer(Buff, Length(Buff));
    //
    Buff := TEncoding.UTF8.GetBytes( {$IFDEF FPC}UnicodeString(Contents){$ELSE}Contents{$ENDIF} );
    LFileStream.WriteBuffer(Buff, Length(Buff));

    if TJValueWriteToFileFlag.FlushFileToDisk in Flags then begin
      // Force OS flush to disk
      if not FlushFileBuffers(LFileStream.Handle) then
        RaiseLastOSError;
    end;
  finally
    LFileStream.Free;
  end;
{$ELSE}
TFile.WriteAllText(FilePath, Contents, TEncoding.UTF8);
{$ENDIF}
end;

class function TJValue.ParseJson(Source: string): IJValue;
var
  S: string;

  I: integer;
  F: JFloat;
  Fmt: TFormatSettings;

  Obj: TJObject;
  Arr: TJArray;
  Content: string;

  //
  var Key, ValueStr: string;
  var InString, InEscape, InValueString: Boolean;
  var Braces, Brackets: Integer;
  var StartPos, SepPos: Integer;

  var C: char;
begin
  S := Trim(Source);

  // String
  if (Length(S) >= 2) and (S[1] = '"') and (S[Length(S)] = '"') then
    Exit(TJString.Create( JSONStringToStringValue(S) ));

  // Boolean
  if SameText(S, 'true') then
    Exit(TJBoolean.Create(True));
  if SameText(S, 'false') then
    Exit(TJBoolean.Create(False));

  // Null
  if SameText(S, 'null') then
    Exit(TJNull.Create);

  // Object
  if (Length(S) >= 2) and (S[1] = '{') and (S[Length(S)] = '}') then begin
    Obj := TJObject.Create;
    Content := Trim(System.Copy(S, 2, Length(S)-2));
    if Content <> '' then
    begin
        I := 1;
        while I <= Length(Content) do
        begin
            // Find key
            while (I <= Length(Content)) and (Content[I] <= ' ') do Inc(I);
            if (I > Length(Content)) or (Content[I] <> '"') then
                raise TEJInvalidJsonFormat.Create('Expected string key at position ' + I.ToString);
            InString := True; InEscape := False; StartPos := I;
            Inc(I);
            while (I <= Length(Content)) and InString do
            begin
                if InEscape then
                    InEscape := False
                else if Content[I] = '\' then
                    InEscape := True
                else if Content[I] = '"' then
                    InString := False;
                Inc(I);
            end;

            // Convert JSON string (of KeyName) to string
            Key := JSONStringToStringValue(System.Copy(Content, StartPos, I-StartPos));

            // Find colon
            while (I <= Length(Content)) and (Content[I] <= ' ') do Inc(I);
            if (I > Length(Content)) or (Content[I] <> ':') then
                raise TEJInvalidJsonFormat.Create('Expected ":" after key at position ' + I.ToString);
            Inc(I);

            // Find value
            while (I <= Length(Content)) and (Content[I] <= ' ') do Inc(I);
            StartPos := I;
            Braces := 0; Brackets := 0; InValueString := False; InEscape := False;
            while I <= Length(Content) do
            begin
                C := Content[I];
                if InValueString then
                begin
                    if InEscape then
                        InEscape := False
                    else if C = '\' then
                        InEscape := True
                    else if C = '"' then
                        InValueString := False;
                end
                else
                begin
                    if C = '"' then
                        InValueString := True
                    else if C = '{' then
                        Inc(Braces)
                    else if C = '}' then
                    begin
                        if Braces = 0 then Break;
                        Dec(Braces);
                    end
                    else if C = '[' then
                        Inc(Brackets)
                    else if C = ']' then
                        Dec(Brackets)
                    else if (C = ',') and (Braces = 0) and (Brackets = 0) then
                        Break;
                end;
                Inc(I);
            end;
            SepPos := I;
            ValueStr := Trim(System.Copy(Content, StartPos, SepPos-StartPos));

            Obj.Put(Key, TJValue.ParseJson(ValueStr));
            // Skip comma
            while (I <= Length(Content)) and ((Content[I] = ',') or (Content[I] <= ' ')) do Inc(I);
        end;
    end;
    Exit(Obj);
  end;

  // Array
  if (Length(S) >= 2) and (S[1] = '[') and (S[Length(S)] = ']') then
  begin
    Arr := TJArray.Create;
    Content := Trim(System.Copy(S, 2, Length(S)-2));
    if Content <> '' then
    begin
        I := 1;
        while I <= Length(Content) do
        begin
            // Skip whitespace
            while (I <= Length(Content)) and (Content[I] <= ' ') do Inc(I);
            if I > Length(Content) then Break;
            StartPos := I;
            Braces := 0; Brackets := 0; InString := False; InEscape := False;
            while I <= Length(Content) do
            begin
                C := Content[I];
                if InString then
                begin
                    if InEscape then
                        InEscape := False
                    else if C = '\' then
                        InEscape := True
                    else if C = '"' then
                        InString := False;
                end
                else
                begin
                    if C = '"' then
                        InString := True
                    else if C = '{' then
                        Inc(Braces)
                    else if C = '}' then
                        Dec(Braces)
                    else if C = '[' then
                        Inc(Brackets)
                    else if C = ']' then
                        Dec(Brackets)
                    else if (C = ',') and (Braces = 0) and (Brackets = 0) then
                        Break;
                end;
                Inc(I);
            end;
            ValueStr := Trim(System.Copy(Content, StartPos, I-StartPos));
            if ValueStr <> '' then
                Arr.Add(TJValue.ParseJson(ValueStr));
            // Skip comma
            while (I <= Length(Content)) and ((Content[I] = ',') or (Content[I] <= ' ')) do Inc(I);
        end;
    end;
    Exit(Arr);
  end;

  // Integer
  if TryStrToInt(S, I) then
    Exit(TJInteger.Create(I));

  // Float
  Fmt.ThousandSeparator := char(0);
  Fmt.DecimalSeparator := '.';
  if TryStrToFloat(S, F, Fmt) then
    Exit(TJFloat.Create(F));

  raise TEJInvalidJsonFormat.Create('Invalid Json format provided.');
end;

function TJValue.ToJSON: string;
begin
  Result := 'null';
end;

function TJObject.AsObject: IJObject;
begin
  Result := Self;
end;

procedure TJObject.Clear;
var
  I: Integer;
begin
  // Free list records
  for I := 0 to Count-1 do begin
    FList[I].Item._Release; // release reference
    //FList.List[I].Item := nil;
  end;

  FList.Clear;
end;

function TJObject.Copy: IJValue;
var
  I: integer;
begin
  Result := TJObject.CreateNew;

  IJObject(Result).Sorted := Self.Sorted;
  for I := 0 to Count-1 do begin
    IJObject(Result).Put(FList[I].Key, FList[I].Item); // created copy automatically
  end;
end;

function TJObject.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TJObject.Create;
begin
  inherited Create;

  FList := TList<TPair>.Create(
    {$IFNDEF FPC}TComparer<TPair>.Construct(
      function(const Left, Right: TPair): Integer
      begin
        Result := TComparer<string>.Default.Compare(Left.Key, Right.Key);
      end)
    {$ENDIF});
end;

class function TJObject.CreateNew: IJObject;
begin
  Result := TJObject.Create;
end;

destructor TJObject.Destroy;
begin
  // Free items
  Clear;

  // Free list
  FreeAndNil(FList);

  inherited;
end;

procedure TJObject.ForEach(Callback: TIJObjectForEach);
var
  I: integer;
begin
  for I := 0 to FList.Count-1 do
    Callback(FList[I].Key, FList[I].Item.Copy);
end;

function TJObject.Format(Indentation: Integer; BaseIdent: integer): string;
var
  Items: TArray<string>;
  I: Integer;
  Content: string;
begin
  Items := [];
  SetLength(Items, Count);
  for I := 0 to Count-1 do
    Items[I] := CreateIdent(BaseIdent+Indentation)
      +StringValueToJSONString(FList[I].Key)+': '+FList[I].Item.Format(Indentation, BaseIdent+Indentation);

  Content := '';
  if Length(Items) > 0 then
    Content := #13+string.Join(','#13, Items)+#13;
  Result := (*CreateIdent(BaseIdent)+*)'{'
    +Content
    +CreateIdent(BaseIdent)+'}';
end;

function TJObject.Get(Index: Integer): IJValue;
begin
  Result := FList[Index].Item.Copy;
end;

function TJObject.Get(Key: string): IJValue;
var
  Index: integer;
begin
  Index := GetKeyIndex(Key);
  if Index < 0 then raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [Key]);
  Result := FList[Index].Item.Copy;
end;

function TJObject.GetItemKey(Index: Integer): string;
begin
  Result := FList[Index].Key;
end;

function TJObject.GetKeyIndex(Key: string): Integer;
var
  L, H, M, Cmp: Integer;
begin
  if FSortedKeys then begin
    // Binary search
    L := 0;
    H := Count - 1;
    while L <= H do
    begin
      M := (L + H) div 2;
      Cmp := CompareStr(FList[M].Key, Key);
      if Cmp = 0 then
        Exit(M)
      else if Cmp < 0 then
        L := M + 1
      else
        H := M - 1;
    end;
    Exit(-1); // not found
  end else begin
    // Linear search
    for Result := 0 to Count - 1 do
      if FList[Result].Key = Key then
        Exit;
    Result := -1;
  end;
end;

function TJObject.GetMemory(Key: string): IJValue;
var
   Index: integer;
begin
  Index := GetKeyIndex(Key);
  if Index < 0 then raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [Key]);
  Result := GetMemory(Index);
end;

function TJObject.GetMemory(Index: Integer): IJValue;
begin
  Result := FList[Index].Item;
end;

function TJObject.GetSorted: boolean;
begin
  Result := FSortedKeys;
end;

function TJObject.IsObject: Boolean;
begin
  Result := true;
end;

function TJObject.KeyExists(Key: string; out Value: IJValue): boolean;
var
  Index: integer;
begin
  Index := GetKeyIndex(Key);
  if Index <> -1 then begin
    Result := true;
    Value := FList[Index].Item.Copy;
  end else
    Result := false;
end;

procedure TJObject.MemoryForEach(Callback: TIJObjectForEach);
var
  I: integer;
begin
  for I := 0 to FList.Count-1 do
    Callback(FList[I].Key, FList[I].Item);
end;

procedure TJObject.MoveBefore(IndexToMove, TargetIndex: integer);
begin
  FList.Move(IndexToMove, TargetIndex);

  // Sorted
  FSortedKeys := false;
end;

procedure TJObject.MoveBefore(KeyToMove, TargetKey: string);
var
  IndexMove, IndexTarget: integer;
begin
  IndexMove := GetKeyIndex(KeyToMove);
  if IndexMove < 0 then raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [KeyToMove]);
  IndexTarget := GetKeyIndex(TargetKey);
  if IndexTarget < 0 then raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [TargetKey]);

  FList.Move(IndexMove, IndexTarget);

  // Sorted
  FSortedKeys := false;
end;

function TJObject.KeyExists(Key: string): boolean;
begin
  Result := GetKeyIndex(Key) <> -1;
end;

procedure TJObject.Put(Key: string; const Value: IJValue);
var
  Index: integer;
begin
  Index := GetKeyIndex(Key);
  if Index = -1 then
    _addKey(Key, Value)
  else
    Put( Index, Value);
end;

procedure TJObject.Put(Index: Integer; const Value: IJValue);
var
  NewCopy: IJValue;
  Rec: TPair;
begin
  FList[Index].Item._Release; // release reference
  NewCopy := Value.Copy; NewCopy._AddRef; // create reference

  Rec.Key:= FList[Index].Key;
  Rec.Item := NewCopy;;

  FList.Delete(Index);
  FList.Insert(Index, Rec);
end;

procedure TJObject.Remove(Key: string);
var
  Index: integer;
begin
  Index := GetKeyIndex(Key);
  if Index < 0 then raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [Key]);
  Remove( Index );
end;

procedure TJObject.Rename(Index: Integer; NewName: string);
var
  DestIndex: Integer;
  Rec: TPair;
begin
  if KeyExists(NewName) then
    raise TEJKeyAlreadyExists.CreateFmt(
      'A key with the name "%s" already exists.', [NewName]);

  // Store renamed key
  Rec := FList[Index];
  Rec.Key:= NewName;

  FList.Delete(Index);
  DestIndex := Index;

  if FSortedKeys then begin
    DestIndex := FList.Count;

    // Move down
    while (DestIndex > 0) and (FList[DestIndex - 1].Key > NewName) do
      Dec(DestIndex);
  end;
  FList.Insert(DestIndex, Rec);
end;

procedure TJObject.Rename(Key, NewName: string);
var
  SourceIndex: integer;
begin
  if Key = NewName then
    Exit;

  // Get key
  SourceIndex := GetKeyIndex(Key);
  if SourceIndex = -1 then
    raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [Key]);
  Rename(SourceIndex, NewName);
end;

procedure TJObject.SetSorted(const Value: boolean);
begin
  if FSortedKeys = Value then
    Exit;
  if Value then
    Sort;
  FSortedKeys := Value;
end;

procedure TJObject.Sort;
begin
  // Sort using the provided IComparer
  FList.Sort;
end;

procedure TJObject.SwitchWith(Index1, Index2: integer);
begin
  FList.Exchange(Index1, Index2);

  // Sorted
  FSortedKeys := false;
end;

procedure TJObject.SwitchWith(Key1, Key2: string);
var
  Index1, Index2: integer;
begin
  Index1 := GetKeyIndex(Key1);
  if Index1 < 0 then raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [Key1]);
  Index2 := GetKeyIndex(Key2);
  if Index2 < 0 then raise TEJObjectKeyDoesNotExists.CreateFmt('There is no key with the name "%s".', [Key2]);

  SwitchWith(Index1, Index2);
end;

procedure TJObject.Remove(Index: integer);
begin
  if (Index >= 0) and (Index < FList.Count) then begin
    FList[Index].Item._Release; // release reference
    //FList.List[Index].Item := nil;
  end;

  // Delete
  FList.Delete( Index );
end;

function TJObject.ToJSON: string;
var
  Items: TArray<string>;
  I: Integer;
begin       
  Items := [];
  SetLength(Items, Count);
  for I := 0 to Count-1 do
    Items[I] := StringValueToJSONString(FList[I].Key)+':'+FList[I].Item.ToJSON;
  Result := '{'+string.Join(',', Items)+'}';
end;

procedure TJObject._addKey(Key: string; const Value: IJValue);
var
  Rec: TPair;
  NewCopy: IJValue;
  InsertIndex: integer;
begin
  NewCopy := Value.Copy; NewCopy._AddRef; // create reference

  Rec.Key := Key;
  Rec.Item := NewCopy;

  try
    if FSortedKeys then begin
      // Get insert index
      InsertIndex := FList.Count;
      while (InsertIndex > 0)
        and (Rec.Key < FList[InsertIndex-1].Key) do
          Dec(InsertIndex);

      // Insert object
      FList.Insert(InsertIndex, Rec);
    end else
      FList.Add(Rec);
  finally
    Rec.Item := nil;
  end;
end;

constructor TJArray.Create;
begin
  inherited Create;

  FList := TList.Create;
end;

class function TJArray.CreateNew: IJArray;
begin
  Result := TJArray.Create;
end;

destructor TJArray.Destroy;
begin
  // Free items
  Clear;

  // Free list
  FreeAndNil(FList);

  inherited;
end;

procedure TJArray.ForEach(Callback: TIJArrayForEach);
var
  I: integer;
begin
  for I := 0 to FList.Count-1 do
    Callback(IJValue(FList[I]).Copy);
end;

function TJArray.Format(Indentation, BaseIdent: integer): string;
var
  Items: TArray<string>;
  I: Integer;
  Content: string;
begin  
  Items := [];
  SetLength(Items, Count);
  for I := 0 to Count-1 do
    Items[I] := CreateIdent(BaseIdent+Indentation)
      +IJValue(FList[I]).Format(Indentation, BaseIdent+Indentation);

  Content := '';
  if Length(Items) > 0 then
    Content := #13+string.Join(','#13, Items)+#13;
  Result := (*CreateIdent(BaseIdent)+*)'['
    +Content
    +CreateIdent(BaseIdent)+']';
end;

function TJArray.Get(Index: Integer): IJValue;
begin
  Result := IJValue(FList[Index]).Copy;
end;

function TJArray.GetMemory(Index: Integer): IJValue;
begin
  Result := IJValue(FList[Index]);
end;

procedure TJArray.Add(Value: IJValue);
var
  NewCopy: IJValue;
begin
  NewCopy := Value.Copy; NewCopy._AddRef; // create reference

  FList.Add( NewCopy );
end;

procedure TJArray.Add(Value: Boolean);
var
  NewCopy: IJValue;
begin
  NewCopy := TJValue.CreateNew(Value); NewCopy._AddRef; // create reference
  FList.Add( NewCopy );
end;

procedure TJArray.Add(Value: JFloat);
var
   NewCopy: IJValue;
begin
  NewCopy := TJValue.CreateNew(Value); NewCopy._AddRef; // create reference
  FList.Add( NewCopy );
end;

procedure TJArray.Add(Value: Integer);
var
  NewCopy: IJValue;
begin
  NewCopy := TJValue.CreateNew(Value); NewCopy._AddRef; // create reference
  FList.Add( NewCopy );
end;

procedure TJArray.Add(Value: string);
var
  NewCopy: IJValue;
begin
  NewCopy := TJValue.CreateNew(Value); NewCopy._AddRef; // create reference
  FList.Add( NewCopy );
end;

function TJArray.AsArray: IJArray;
begin
  Result := Self;
end;

procedure TJArray.Insert(Index: integer; Value: IJValue);
var
  NewCopy: IJValue;
begin
  NewCopy := Value.Copy; NewCopy._AddRef; // create reference

  FList.Insert( Index, NewCopy );
end;

procedure TJArray.Insert(Index: Integer; Value: Boolean);
begin Insert( Index, TJValue.CreateNew(Value) ); end;

procedure TJArray.Insert(Index: Integer; Value: JFloat);
begin Insert( Index, TJValue.CreateNew(Value) ); end;

procedure TJArray.Insert(Index, Value: Integer);
begin Insert( Index, TJValue.CreateNew(Value) ); end;

procedure TJArray.Insert(Index: Integer; Value: string);
begin Insert( Index, TJValue.CreateNew(Value) ); end;

function TJArray.IsArray: Boolean;
begin
  Result := true;
end;

procedure TJArray.MemoryForEach(Callback: TIJArrayForEach);
var
  I: integer;
begin
  for I := 0 to FList.Count-1 do
    Callback(IJValue(FList[I]));
end;

procedure TJArray.Put(Index: integer; const Value: IJValue);   
var
  NewCopy: IJValue;
begin
  IJValue(FList[Index])._Release; // release reference
  NewCopy := Value.Copy; NewCopy._AddRef; // create reference

  FList[Index] := NewCopy;
end;

procedure TJArray.Clear;
var
  I: integer;
begin
  // release reference(s)
  for I := 0 to FList.Count-1 do
    IJValue(FList[I])._Release;

  // Clear list
  FList.Clear;
end;

procedure TJArray.Remove(Index: integer);
begin
  IJValue(FList[Index])._Release; // release reference

  FList.Delete(Index);
end;

function TJArray.Copy: IJValue;
var
  I: integer;
begin
  Result := TJArray.CreateNew;

  for I := 0 to Count-1 do
    IJArray(Result).Add( IJValue(FList[I]) ); // created copy automatically
end;

function TJArray.ToJSON: string;
var
  Items: TArray<string>;
  I: Integer;
begin    
  Items := [];
  SetLength(Items, Count);
  for I := 0 to Count-1 do
    Items[I] := IJValue(FList[I]).ToJSON;
  Result := '[' + string.Join(',', Items) + ']';
end;

function TJArray.Count: Integer;
begin
  Result := FList.Count;
end;


{ TJString }

function TJString.AsString: string;
begin
  Result := FValue;
end;

function TJString.Copy: IJValue;
begin
  Result := TJString.Create(FValue);
end;

constructor TJString.Create(Value: string);
begin
  FValue := Value;
  inherited Create;
end;

class function TJString.CreateNew(Value: string): TJString;
begin
  Result := TJValue.CreateNew(Value) as TJString;
end;

function TJString.IsString: Boolean;
begin
  Result := true;
end;

function TJString.ToJSON: string;
begin
  Result := StringValueToJSONString(FValue);
end;

{ TJInteger }

function TJInteger.AsFloat: JFloat;
begin
  Result := FValue;
end;

function TJInteger.AsInteger: JNumber;
begin
  Result := FValue;
end;

{$IFDEF STRINGCOMPATABILITY}
function TJInteger.AsString: string;
begin
  Result := FValue.ToString;
end;
{$ENDIF}

function TJInteger.Copy: IJValue;
begin
  Result := TJInteger.Create(FValue);
end;

constructor TJInteger.Create(Value: JNumber);
begin
  FValue := Value;
  inherited Create;
end;

class function TJInteger.CreateNew(Value: string): TJInteger;
begin
  Result := TJValue.CreateNew(Value) as TJInteger;
end;

function TJInteger.IsFloat: Boolean;
begin
  Result := true;
end;

function TJInteger.IsInteger: Boolean;
begin
  Result := true;
end;

function TJInteger.ToJSON: string;
begin
  Result := FValue.ToString;
end;

{ TJFloat }

function TJFloat.AsFloat: JFloat;
begin
  Result := FValue;
end;

{$IFDEF STRINGCOMPATABILITY}
function TJFloat.AsString: string;
var
  Fmt: TFormatSettings;
begin
  Fmt.ThousandSeparator := char(0);
  Fmt.DecimalSeparator := '.';
  Result := FValue.ToString(Fmt);
end;
{$ENDIF}

function TJFloat.Copy: IJValue;
begin
  Result := TJFloat.Create(FValue);
end;

constructor TJFloat.Create(Value: JFloat);
begin
  FValue := Value;
  inherited Create;
end;

class function TJFloat.CreateNew(Value: string): TJFloat;
begin
  Result := TJValue.CreateNew(Value) as TJFloat;
end;

function TJFloat.IsFloat: Boolean;
begin
  Result := true;
end;

function TJFloat.ToJSON: string;
var
  Fmt: TFormatSettings;
begin
  Fmt.ThousandSeparator := char(0);
  Fmt.DecimalSeparator := '.';
  Result := FValue.ToString(Fmt);
end;

{ TJBoolean }

function TJBoolean.AsBoolean: Boolean;
begin
  Result := FValue;
end;

{$IFDEF STRINGCOMPATABILITY}
function TJBoolean.AsString: string;
begin
  if FValue then
    Exit('true')
  else
    Exit('false');
end;
{$ENDIF}

function TJBoolean.Copy: IJValue;
begin
  Result := TJBoolean.Create(FValue);
end;

constructor TJBoolean.Create(Value: Boolean);
begin
  FValue := Value;
  inherited Create;
end;

class function TJBoolean.CreateNew(Value: string): TJBoolean;
begin
  Result := TJValue.CreateNew(Value) as TJBoolean;
end;

function TJBoolean.IsBoolean: Boolean;
begin
  Result := true;
end;

function TJBoolean.ToJSON: string;
begin
  if FValue then Exit('true') else Exit('false');
end;

{ TJObject.TPair }

procedure TJObject.Put(Index: Integer; Value: Boolean);
begin Put( Index, TJValue.CreateNew(Value) ); end;

procedure TJObject.Put(Index: Integer; Value: JFloat);
begin Put( Index, TJValue.CreateNew(Value) ); end;

procedure TJObject.Put(Index, Value: Integer);
begin Put( Index, TJValue.CreateNew(Value) ); end;

procedure TJObject.Put(Index: Integer; Value: string);
begin Put( Index, TJValue.CreateNew(Value) ); end;

procedure TJObject.Put(Key: string; Value: Boolean);
begin Put( Key, TJValue.CreateNew(Value) ); end;

procedure TJObject.Put(Key: string; Value: JFloat);
begin Put( Key, TJValue.CreateNew(Value) ); end;

procedure TJObject.Put(Key: string; Value: Integer);
begin Put( Key, TJValue.CreateNew(Value) ); end;

procedure TJObject.Put(Key, Value: string);
begin Put( Key, TJValue.CreateNew(Value) ); end;

end.
