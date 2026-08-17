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

{$SCOPEDENUMS ON}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

unit Cod.JSON.Utils;

interface
uses
  SysUtils, Classes, Generics.Collections, Generics.Defaults, Cod.JSON;

// Dictionary - JObject
function DictionaryToJObject(Value: TDictionary<string, string>): IJValue; overload;
function DictionaryToJObject(Value: TDictionary<string, JNumber>): IJValue; overload;
function DictionaryToJObject(Value: TDictionary<string, JFloat>): IJValue; overload;
function DictionaryToJObject(Value: TDictionary<string, boolean>): IJValue; overload;

function JObjectToStringDictionary(Value: IJValue): TDictionary<string, string>;
function JObjectToIntegerDictionary(Value: IJValue): TDictionary<string, JNumber>;
function JObjectToFloatDictionary(Value: IJValue): TDictionary<string, JFloat>;
function JObjectToBooleanDictionary(Value: IJValue): TDictionary<string, boolean>;

// Array - JArray
function ArrayToJArray(Value: TArray<string>): IJValue; overload;
function ArrayToJArray(Value: TArray<JNumber>): IJValue; overload;
function ArrayToJArray(Value: TArray<JFloat>): IJValue; overload;
function ArrayToJArray(Value: TArray<boolean>): IJValue; overload;

function JArrayToStringArray(Value: IJValue): TArray<string>;
function JArrayToIntegerArray(Value: IJValue): TArray<JNumber>;
function JArrayToFloatArray(Value: IJValue): TArray<JFloat>;
function JArrayToBooleanArray(Value: IJValue): TArray<boolean>;

implementation

function DictionaryToJObject(Value: TDictionary<string, string>): IJValue;
var
   E: TDictionary<string, string>.TPairEnumerator;
begin
  Result := TJObject.CreateNew;
  E := Value.GetEnumerator;
  try
    while E.MoveNext do
      (Result as IJObject).Put(E.Current.Key, E.Current.Value);
  finally
    E.Free;
  end;
end;

function DictionaryToJObject(Value: TDictionary<string, JNumber>): IJValue; 
var
   E: TDictionary<string, JNumber>.TPairEnumerator;
begin
  Result := TJObject.CreateNew;
  E := Value.GetEnumerator;
  try
    while E.MoveNext do
      (Result as IJObject).Put(E.Current.Key, E.Current.Value);
  finally
    E.Free;
  end;
end;

function DictionaryToJObject(Value: TDictionary<string, JFloat>): IJValue;
var
   E: TDictionary<string, JFloat>.TPairEnumerator;
begin
  Result := TJObject.CreateNew;
  E := Value.GetEnumerator;
  try
    while E.MoveNext do
      (Result as IJObject).Put(E.Current.Key, E.Current.Value);
  finally
    E.Free;
  end;
end;

function DictionaryToJObject(Value: TDictionary<string, boolean>): IJValue;
var
   E: TDictionary<string, boolean>.TPairEnumerator;
begin
  Result := TJObject.CreateNew;
  E := Value.GetEnumerator;
  try
    while E.MoveNext do
      (Result as IJObject).Put(E.Current.Key, E.Current.Value);
  finally
    E.Free;
  end;
end;

function JObjectToStringDictionary(Value: IJValue): TDictionary<string, string>;
var
   ACount: integer;
   I: integer;
begin
  ACount := (Value as IJObject).Count;
  Result := TDictionary<string, string>.Create;
  for I := 0 to ACount-1 do
    Result.Add((Value as IJObject).GetItemKey(I), (Value as IJObject).GetMemory(I).AsString);
end;

function JObjectToIntegerDictionary(Value: IJValue): TDictionary<string, JNumber>;
var    
   ACount: integer;
   I: integer;
begin
  ACount := (Value as IJObject).Count;
  Result := TDictionary<string, JNumber>.Create;
  for I := 0 to ACount-1 do
    Result.Add((Value as IJObject).GetItemKey(I), (Value as IJObject).GetMemory(I).AsInteger);
end;

function JObjectToFloatDictionary(Value: IJValue): TDictionary<string, JFloat>;      
var    
   ACount: integer;
   I: integer;
begin
  ACount := (Value as IJObject).Count;
  Result := TDictionary<string, JFloat>.Create;
  for I := 0 to ACount-1 do
    Result.Add((Value as IJObject).GetItemKey(I), (Value as IJObject).GetMemory(I).AsFloat);
end;

function JObjectToBooleanDictionary(Value: IJValue): TDictionary<string, boolean>;  
var       
   ACount: integer;
   I: integer;
begin
  ACount := (Value as IJObject).Count;
  Result := TDictionary<string, boolean>.Create;
  for I := 0 to ACount-1 do
    Result.Add((Value as IJObject).GetItemKey(I), (Value as IJObject).GetMemory(I).AsBoolean);
end;

function ArrayToJArray(Value: TArray<string>): IJValue;
var
   X: string;
begin
  Result := TJArray.CreateNew;
  for X in Value do
    (Result as IJArray).Add(X);
end;

function ArrayToJArray(Value: TArray<JNumber>): IJValue;   
var
   X: JNumber;
begin
  Result := TJArray.CreateNew;
  for X in Value do
    (Result as IJArray).Add(X);
end;

function ArrayToJArray(Value: TArray<JFloat>): IJValue;   
var
   X: JFloat;
begin
  Result := TJArray.CreateNew;
  for X in Value do
    (Result as IJArray).Add(X);
end;

function ArrayToJArray(Value: TArray<boolean>): IJValue;    
var
   X: boolean;
begin
  Result := TJArray.CreateNew;
  for X in Value do
    (Result as IJArray).Add(X);
end;

function JArrayToStringArray(Value: IJValue): TArray<string>;
var
   ACount: integer;
   I: integer;
begin   
  Result := [];
  ACount := (Value as IJArray).Count;
  SetLength(Result, ACount);
  for I := 0 to ACount-1 do
    Result[I] := (Value as IJArray).Memory[I].AsString;
end;

function JArrayToIntegerArray(Value: IJValue): TArray<JNumber>;
var
   ACount: integer;
   I: integer;
begin    
  Result := [];
  ACount := (Value as IJArray).Count;
  SetLength(Result, ACount);
  for I := 0 to ACount-1 do
    Result[I] := (Value as IJArray).Memory[I].AsInteger;
end;

function JArrayToFloatArray(Value: IJValue): TArray<JFloat>;
var
   ACount: integer;
   I: integer;
begin  
  Result := [];
  ACount := (Value as IJArray).Count;
  SetLength(Result, ACount);
  for I := 0 to ACount-1 do
    Result[I] := (Value as IJArray).Memory[I].AsFloat;
end;

function JArrayToBooleanArray(Value: IJValue): TArray<boolean>;
var
   ACount: integer;
   I: integer;
begin
  Result := [];
  ACount := (Value as IJArray).Count;
  SetLength(Result, ACount);
  for I := 0 to ACount-1 do
    Result[I] := (Value as IJArray).Memory[I].AsBoolean;
end;

end.
