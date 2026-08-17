{***********************************************************}
{                     Codruts Math Library                  }
{                                                           }
{                        version 1.0                        }
{                                                           }
{             Copyright (c) 2025 Petculescu Codrut          }
{                   All Rights Reserved.                    }
{                                                           }
{***********************************************************}

{$SCOPEDENUMS ON}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

unit Cod.Math;

interface
  uses
  {$IFDEF MSWINDOWS}Windows,{$ENDIF}
  SysUtils, Classes, Math, Cod.ArrayHelpers, Types,
  Cod.StringUtils, Cod.Types
  {$IFDEF FPC}, Cod.Platform.Lazarus{$ENDIF};

  // This function gets a string and automaticly calculates any
  // indics such as =time =eq = cell
  function GetParanthStart(from: integer; InText: string;
    paranthtype: char = '('): integer;
  // Get the first paranthes
  function GetParanthEnd(parastart: integer; InText: string;
    FindOnEmpty: boolean = true; p1type: char = '('; p2type: char = ')'): integer;
  // This function gets the end of a praranth. Ex: "=cell( =eq( cell(1,2) ), 4)"
  // to get the one assigned to the first one

  function GetLocalePeriod: string;
  // This function finds out if the computer uses , or . for periods

  function StringToFloat(str: string): Extended;
  // Better string to float conversion

  // Factorial
  function Factorial(N: Integer): Int64;
  // Uses base 10 starting from 0
  function GetNthPermutation(Base: Integer; X: Integer): TArray<Integer>;

  // Number Sequences
  // Fisher-Yates shuffle algorithm
  function GenerateRandomSequence(count: Integer): TArray<Integer>;

  // Basic Mathematical Function
  function Sign(Value: integer): integer;
  function EqualApprox(number1, number2: int64; span: real = 1): boolean; overload;
  function EqualApprox(number1, number2: real; span: real = 1): boolean; overload;
  function PercOf(number: int64; percentage: integer): integer;
  function PercOfR(number: Real; percentage: int64): real;
  function GetNumberRelation(Primary, Secondary: int64): TValueRelationship; overload;
  function GetNumberRelation(Primary, Secondary: real): TValueRelationship; overload;
  {$IFDEF WIN32}
  procedure ConstraintASM(var Number: integer; Min: integer; Max: integer);
  {$ENDIF}
  procedure Constraint(var Number: integer; Min: integer = integer.MinValue; Max: integer = integer.MaxValue); overload;
  procedure Constraint(var Number: int64; Min: int64 = int64.MinValue; Max: int64 = int64.MaxValue); overload;
  procedure Constraint(var Number: Real; Min: Real = int64.MinValue; Max: Real = int64.MaxValue); overload;

const
    num_digit: TArray<char> = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    num_content: TArray<char> = [',', '.','1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    add_indic: TArray<char> = ['+', '-'];
    multp_indic: TArray<char> = ['*', '/'];
    oper_indic: TArray<char> = ['+', '-', '*', '/'];

implementation

function GetLocalePeriod: string;
var
  fs: TFormatSettings;
begin
  {$IFDEF MSWINDOWS}
  {$WARN SYMBOL_PLATFORM OFF}
  fs := TFormatSettings.Create(GetThreadLocale());
  {$WARN SYMBOL_PLATFORM ON}
  {$ELSE}
  fs := TFormatSettings.Create;
  {$ENDIF}
  Result := fs.DecimalSeparator;
end;

function GenerateRandomSequence(count: Integer): TArray<Integer>;
var
  i, j, temp: Integer;
begin
  // create an array to hold the sequence
  SetLength(Result, count);

  // fill the array with sequential numbers
  for i := 0 to count - 1 do
    Result[i] := i + 1;

  // shuffle the sequence using Fisher-Yates algorithm
  for i := count - 1 downto 1 do
  begin
    j := Random(i + 1); // generate a random index between 0 and i
    temp := Result[j];
    Result[j] := Result[i];
    Result[i] := temp;
  end;
end;

function Sign(Value: integer): integer;
begin
  Result := Value div abs(Value);
end;

function EqualApprox(number1, number2: int64; span: real): boolean;
begin
  if (number1 <= number2 + span) and (number1 >= number2 - span) then
    Result := true
  else
    Result := false;
end;

function EqualApprox(number1, number2: real; span: real): boolean;
begin
  if (number1 <= number2 + span) and (number1 >= number2 - span) then
    Result := true
  else
    Result := false;
end;

function PercOf(number: int64; percentage: integer): integer;
begin
  Result := trunc(percentage / 100 * number);
end;

function PercOfR(number: Real; percentage: int64): real;
begin
  Result := percentage / 100 * number;
end;

function GetNumberRelation(Primary, Secondary: int64): TValueRelationship;
begin
  Result := GetNumberRelation( real(Primary), real(Secondary) );
end;

function GetNumberRelation(Primary, Secondary: real): TValueRelationship;
begin
  if Primary = Secondary then
    Result := TValueRelationship.Equal
      else
        if Primary > Secondary then
          Result := TValueRelationship.Greater
            else
              Result := TValueRelationship.Less;
end;

{$IFDEF WIN32}
procedure ConstraintASM(var Number: integer; Min: integer; Max: integer);
label
  min_succeed, min_analise, max_begin, max_succeed, write_value, exit_comp;
asm
    // Load values
    mov ebx, Min
    mov ecx, Max

    // Load registry location
    lea edx, [Number]

    // Load value
    mov eax, [edx]

    // Min
    cmp eax, ebx
    jle min_analise

    jmp max_begin

  min_analise:
    je exit_comp
    mov eax, ebx
    jmp write_value

    // Max
  max_begin:
    cmp eax, ecx
    jle exit_comp

    mov eax, ecx

    // Write
  write_value:
    mov [edx], eax

    // Exit
  exit_comp:
end;
{$ENDIF}

procedure Constraint(var Number: integer; Min: integer; Max: integer);
begin
  if Number < Min then
    Number := Min;

  if Number > Max then
    Number := Max;
end;

procedure Constraint(var Number: int64; Min: int64; Max: int64);
begin
  if Number < Min then
    Number := Min;

  if Number > Max then
    Number := Max;
end;

procedure Constraint(var Number: Real; Min: Real; Max: Real);
begin
  if Number < Min then
    Number := Min;

  if Number > Max then
    Number := Max;
end;

function StringToFloat(str: string): Extended;
var
  I: Integer;
  il: string;
begin
  il := '';
  for I := 1 to length(str) do
    if TArrayUtils<char>.Contains(str[I], add_indic) then
      il := il + str[I]
    else
      begin
        if length(il) > 1 then
          begin
            il := il.Replace('+', '');

            if length(il) mod 2 = 1 then
              str := StrReplZone(str, 0, I-1, '-')
            else
              str := StrRemove(str, 0, I-1);
          end;

        Break;
      end;

  Result := StrToFloat(str);
end;

function Factorial(N: Integer): Int64;
var
  I: Integer;
  ResultValue: Int64;
begin
  if N < 0 then
    raise Exception.Create('Factorial is undefined for negative numbers.');

  ResultValue := 1; // Initialize value
  for I := 2 to N do
    ResultValue := ResultValue * I;

  Result := ResultValue;
end;

function GetNthPermutation(Base: Integer; X: Integer): TArray<Integer>;
var
  Permutation: TArray<Integer>;
  Used: TArray<Boolean>;
  AFactorial, Temp, I, J, Index: Integer;
begin
  // Initialize the permutation array
  SetLength(Permutation, Base);
  SetLength(Used, Base);

  // Calculate the factorial of the base
  AFactorial := Factorial(Base);

  // Generate the Xth permutation
  for I := 0 to Base - 1 do
  begin
    AFactorial := AFactorial div (Base - I); // Factorial for the current position
    Index := X div AFactorial;              // Determine which element to pick
    X := X mod AFactorial;                  // Update X for the next position

    // Find the Index-th unused element
    Temp := 0;
    for J := 0 to Base - 1 do
    begin
      if not Used[J] then
      begin
        if Temp = Index then
        begin
          Permutation[I] := J; // Store the chosen element
          Used[J] := True;        // Mark it as used
          Break;
        end;
        Inc(Temp);
      end;
    end;
  end;

  Result := Permutation;
end;

function GetParanthStart(from: integer; InText: string; paranthtype: char): integer;
var
  spar: char;
begin
  spar := paranthtype; { Parantheses type }

  Result := Pos(spar, InText);
end;

function GetParanthEnd(parastart: integer; InText: string; FindOnEmpty: boolean; p1type, p2type: char): integer;
var
  spar, epar, cr: char;
  I, P, PS, PE, prstarts: Integer;
begin
  { The FindOnEmpty property find the first found
  start parantheses in case that its missing! }

  // Parantheses Type
  spar := p1type;
  epar := p2type;

  // Find Para
    if FindOnEmpty and (InText[parastart] <> spar) then
      for I := parastart to length( InText ) do
        if InText[I] = spar then
          begin
            parastart := I;
            Break;
          end;

  // Values Reset
  Result := 0;
  prstarts := 0;

  // Start Position
  P := parastart;

  repeat
    // Find position of "(" and ")"
    PS := Pos(spar, InText, P + 1);
    PE := Pos(epar, InText, P + 1);

    // Find which is closer
    if (PS < PE) and (PS <> 0) then
      P := PS
    else
      P := PE;

    // Avoid invalid memory access
    if P = 0 then
      Break;

    cr := InText[P];

    // Increate the amount of unfinished brackets
    if cr = spar then
        inc(prstarts);

    // Check for end bracked
      if cr = epar then
        begin
          if prstarts > 0 then
            dec(prstarts)
          else
            begin
              Result := P;

              Break;
            end;

        end;

  until (PE = 0);
end;

end.
