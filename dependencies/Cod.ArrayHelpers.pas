{***********************************************************}
{                  Codruts Variabile Helpers                }
{                                                           }
{                        version 1.1                        }
{                                                           }
{              https://www.codrutsoft.com/                  }
{             Copyright 2025 Codrut Software                }
{    This unit is licensed for usage under a MIT license    }
{                                                           }
{***********************************************************}

{$SCOPEDENUMS ON}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

unit Cod.ArrayHelpers;

interface
uses
  SysUtils, Classes{$IFNDEF FPC},Types, Generics.Collections{$ENDIF}, Generics.Defaults, Math;

type
  /// Note about internal errors
  ///  This class uses lComparer to compare values because some value types,
  ///  such as record cannot be directly compared and would give the
  ///  "Invalid operand type" error, but since this class is type based,
  ///  a internal error would appear instead.


  // TArray colection
  TArrayUtils<T> = class
  private
    {$IFDEF FPC}
    class function _internal_compare(const A, B: T): TValueRelationship; static;
    {$ENDIF}
  public
    // Callback types
    type
    TArrayEachCallback = {$IFNDEF FPC}reference to{$ENDIF} procedure(var Element: T);
    TArrayEachCallbackConst = {$IFNDEF FPC}reference to{$ENDIF} procedure(const Element: T);
    TArrayDualCallback = {$IFNDEF FPC}reference to{$ENDIF} function(const A, B: T): TValueRelationship;
    TArrayIndexCallback = {$IFNDEF FPC}reference to{$ENDIF} function(const Index: integer): T;
    TArrayFindItemCallback = {$IFNDEF FPC}reference to{$ENDIF} function(const Element: T): boolean;

    /// <summary> Verify if the array contains element x. </summary>
    class function Build(const Length: integer; Callback: TArrayIndexCallback): TArray<T>;

    /// <summary> Verify if the array contains element x. </summary>
    class function Contains(const x: T; const Values: TArray<T>): boolean; overload;
    /// <summary> Verify if the array contains element x. </summary>
    class function ContainsAny(const Search: TArray<T>; const Values: TArray<T>): boolean; overload;
    /// <summary> Verify if the array contains an element with a verify callback. </summary>
    class function Contains(const Values: TArray<T>; Callback: TArrayFindItemCallback): boolean; overload;
    /// <summary> Compares is two arrays are equal. </summary>
    class function CheckEquality(const First, Second: TArray<T>) : boolean;

    /// <summary> Create a copy of the array. </summary>
    class function CreateCopy(const Source: TArray<T>): TArray<T>;
    /// <summary> Create a copy of the array. </summary>
    class procedure CopyTo(const Source: TArray<T>; var Destination: TArray<T>);

    /// <summary> Get the index if element x searching top-bottom. </summary>
    class function GetIndex(const x: T; const Values: TArray<T>): integer; overload;
    /// <summary> Get the index if element x searching top-bottom. </summary>
    class function GetIndex(const x: T; const Values: TArray<T>; StartingValue: integer): integer; overload;
    /// <summary> Get the index if element x searching bottom-top. </summary>
    class function GetIndexDownTo(const x: T; const Values: TArray<T>): integer; overload;
    /// <summary> Get the index if element x searching bottom-top. </summary>
    class function GetIndexDownTo(const x: T; const Values: TArray<T>; StartingValue: integer): integer; overload;
    /// <summary> Get the index if element with a callback to see if the item was found. </summary>
    class function GetIndex(const Values: TArray<T>; Callback: TArrayFindItemCallback): integer; overload;
    /// <summary> Go trough all elements of an array and get their value. </summary>
    class procedure ForEach(const Values: TArray<T>; Callback: TArrayEachCallbackConst); overload;
    /// <summary> Go trough all elements of an array and modify their value. </summary>
    class procedure ForEach(var Values: TArray<T>; Callback: TArrayEachCallback); overload;
    /// <summary> Sort the elements of an array using the valid type IComparer for that type. </summary>
    class procedure Sort(var Values: TArray<T>); overload;
    /// <summary> Sort the elements of an array using the provided callback for comparison. </summary>
    class procedure Sort(var Values: TArray<T>; const Callback: TArrayDualCallback); overload;
    /// <summary> Flip the array values Top-Bottom. </summary>
    class procedure Flip(var Values: TArray<T>); overload;

    /// <summary> Move one item from It's index to another item's index and moving that one uppwards. </summary>
    class procedure Move(var Values: TArray<T>; const Source, Destination: integer); overload;
    /// <summary> Switch places for two items. </summary>
    class procedure Switch(var Values: TArray<T>; const Source, Destination: integer); overload;

    /// <summary> Shuffle array to random position. </summary>
    class procedure Shuffle(var Values: TArray<T>); overload;

    /// <summary> Add blank value to the end of the array. </summary>
    class function AddValue(var Values: TArray<T>) : integer; overload;
    /// <summary> Add value to the end of the array. </summary>
    class function AddValue(const Value: T; var Values: TArray<T>) : integer; overload;
    /// <summary> Add value to the end of the array. </summary>
    class procedure AddValues(const Values: TArray<T>; var Destination: TArray<T>);
    /// <summary> Add value to the end of the array if It;s not in the array allready. </summary>
    class function AddValueUnique(const Value: T; var Values: TArray<T>) : integer; overload;
    /// <summary> Add value to the end of the array if It;s not in the array allready. </summary>
    class procedure AddValuesUnique(const Values: TArray<T>; var Destination: TArray<T>); overload;
    /// <summary> Concat secondary array to primary array. </summary>
    class function Concat(const Primary, Secondary: TArray<T>) : TArray<T>;
    /// <summary> Concat secondary array to primary array. </summary>
    class function ConcatUnique(const Primary, Secondary: TArray<T>) : TArray<T>;
    /// <summary> Subtract from the primary array the values in the secondary array. </summary>
    class function Subtract(const Primary, Secondary: TArray<T>) : TArray<T>;
    /// <summary> Insert empty value at the specified index into the array. </summary>
    class procedure Insert(const Index: integer; var Values: TArray<T>); overload;
    /// <summary> Insert value at the specified index into the array. </summary>
    class procedure Insert(const Index: integer; const Value: T; var Values: TArray<T>); overload;

    /// <summary> Delete element by index from array. </summary>
    class procedure Delete(const Index: integer; var Values: TArray<T>); overload;
    /// <summary> Delete element by type T from array. </summary>
    class procedure Delete(var Values: TArray<T>; Callback: TArrayFindItemCallback); overload;
    /// <summary> Delete element by type T from array. </summary>
    class function DeleteValue(const Value: T; var Values: TArray<T>): boolean;
    /// <summary> Delete element by type T from array. </summary>
    class procedure DeleteValues(const Values: TArray<T>; var Destination: TArray<T>);
    /// <summary> Delete all by type T of the provided value from array. </summary>
    class procedure DeleteAllMatchingValues(const Value: T; var Values: TArray<T>);

    /// <summary> Replace element of type T with a new one in the array. </summary>
    class function ReplaceValue(const Value, NewValue: T; var Values: TArray<T>): boolean;
    /// <summary> Replace all element of type T with the provided value with the new one in the array. </summary>
    class procedure ReplaceAllMatchingValues(const Value, NewValue: T; var Values: TArray<T>);

    /// <summary> Delete the last element of the array and return It's value. </summary>
    class function Pop(var Values: TArray<T>): T;
    /// <summary> Delete the first element of the array and return It's value. </summary>
    class function Shift(var Values: TArray<T>): T;
    /// <summary> Set length to specifieed value. </summary>
    class procedure SetLength(const Length: integer; var Values: TArray<T>);
    /// <summary> Get array length. </summary>
    class function Count(const Values: TArray<T>) : integer;

    (* Known algorithms *)
    {$IFNDEF FPC}
    /// <summary> Generics.Collections Sort, </summary>
    class procedure DoGenericsCollect(var Values: TArray<T>; const Callback: TArrayDualCallback);
    {$ENDIF}
    /// <summary> Quick sort algorithm, </summary>
    class procedure DoQuickSort(var Values: TArray<T>; const Callback: TArrayDualCallback; Left, Right: Integer);
    /// <summary> Quick sort algorithm, </summary>
    class procedure DoFisherYatesShuffle(var Values: TArray<T>; Left, Right: Integer);
  end;

implementation

{ TArrayUtils<T> }

class function TArrayUtils<T>.AddValue(const Value: T;
  var Values: TArray<T>): integer;
begin
  Result := AddValue(Values);
  Values[Result] := Value;
end;

class function TArrayUtils<T>.AddValue(var Values: TArray<T>): integer;
begin
  System.SetLength(Values, length(Values)+1);

  Result := High(Values);
end;

class procedure TArrayUtils<T>.AddValues(const Values: TArray<T>;
  var Destination: TArray<T>);
var
  StartIndex: integer;
  LowPoint: integer;
  I: integer;
begin
  StartIndex := High(Destination)+1;
  System.SetLength(Destination, length(Destination)+length(Values));

  LowPoint := Low(Values);
  for I := LowPoint to High(Values) do
    Destination[StartIndex+I-LowPoint] := Values[I];
end;

class procedure TArrayUtils<T>.AddValuesUnique(const Values: TArray<T>;
  var Destination: TArray<T>);
var
  I: integer;
begin
  for I := 0 to High(Values) do
    if not Contains(Values[I], Destination) then
      AddValue(Values[I], Destination);
end;

class function TArrayUtils<T>.AddValueUnique(const Value: T;
  var Values: TArray<T>): integer;
begin
  Result := -1;
  if not Contains(Value, Values) then
    Result := AddValue(Value, Values);
end;

class function TArrayUtils<T>.Build(const Length: integer;
  Callback: TArrayIndexCallback): TArray<T>; 
var
  I: integer;
begin
  Result := [];
  System.SetLength(Result, Length);
  for I := 0 to Length-1 do
    Result[I] := Callback(I);
end;

class function TArrayUtils<T>.Concat(const Primary,
  Secondary: TArray<T>): TArray<T>;
begin
  Result := Copy(Primary);
  AddValues(Secondary, Result);
end;

class function TArrayUtils<T>.ConcatUnique(const Primary,
  Secondary: TArray<T>): TArray<T>;
begin
  Result := Copy(Primary);
  AddValuesUnique(Secondary, Result);
end;

class function TArrayUtils<T>.Contains(const Values: TArray<T>;
  Callback: TArrayFindItemCallback): boolean;   
var
  I: integer;
begin
  Result := false;
  for I := Low(Values) to High(Values) do
    if Callback( Values[I] ) then
      Exit(true);
end;

class function TArrayUtils<T>.ContainsAny(const Search,
  Values: TArray<T>): boolean;    
var
  I: integer;
begin
  Result := false;
  for I := Low(Values) to High(Values) do
    if Contains( Values[I], Search ) then
      Exit(true);
end;

class procedure TArrayUtils<T>.CopyTo(const Source: TArray<T>;
  var Destination: TArray<T>);
begin
  Destination := Copy(Source, 0, Length(Source));
end;

class function TArrayUtils<T>.Contains(const x: T; const Values: TArray<T>): boolean;
var
  y : T;
  Comparator: IEqualityComparer<T>;
begin
  Comparator := TEqualityComparer<T>.Default;

  for y in Values do
  begin
    if Comparator.Equals(x, y) then
      Exit(True);
  end;
  Exit(False);

end;

class function TArrayUtils<T>.Count(const Values: TArray<T>): integer;
begin
  Result := Length(Values);
end;

class function TArrayUtils<T>.CreateCopy(const Source: TArray<T>): TArray<T>;
begin
  Result := Copy(Source, 0, Length(Source));
end;

class procedure TArrayUtils<T>.Delete(const Index: integer;
  var Values: TArray<T>);  
var
  I: integer;
begin
  if Index = -1 then
    Exit;

  for I := Index to High(Values)-1 do
    Values[I] := Values[I+1];

  System.SetLength(Values, Length(Values)-1);
end;

class procedure TArrayUtils<T>.Delete(var Values: TArray<T>;
  Callback: TArrayFindItemCallback);         
var
  I: integer;
begin
  for I := High(Values) downto Low(Values) do
    if Callback(Values[I]) then
      Delete(I, Values);
end;

class procedure TArrayUtils<T>.DeleteAllMatchingValues(const Value: T;
  var Values: TArray<T>);
var
  Index: integer;
begin
  Index := GetIndexDownTo(Value, Values);
  while Index <> -1 do begin
    Delete(Index, Values);
    Index := GetIndexDownTo(Value, Values, Index-1);
  end;
end;

class function TArrayUtils<T>.DeleteValue(const Value: T;
  var Values: TArray<T>): boolean;       
var
  Index: integer;
begin
  Index := GetIndex(Value, Values);
  Result := Index <> -1;
  if Result then
    Delete(Index, Values);
end;

class procedure TArrayUtils<T>.DeleteValues(const Values: TArray<T>;
  var Destination: TArray<T>);        
var
  I: integer;
begin
  for I := Low(Values) to High(Values) do
    DeleteValue(Values[I], Destination);
end;

class function TArrayUtils<T>.CheckEquality(const First, Second: TArray<T>): boolean;
var
  Count: integer;
  I: integer;
  Comparator: IEqualityComparer<T>;
begin
  Comparator := TEqualityComparer<T>.Default;

  Result := true;

  if Length(First) <> Length(Second) then
    Exit(false);
  Count := Length(First);
  for I := 0 to Count-1 do
    if not Comparator.Equals(First[I], Second[I]) then
      Exit(false);
end;

class procedure TArrayUtils<T>.DoFisherYatesShuffle(var Values: TArray<T>; Left,
  Right: Integer);
var
  I, J: Integer;
  Temp: T;
begin
  Randomize;

  for I := Right downto Left + 1 do
  begin
    J := Random(I - Left + 1) + Left;

    // Swap values
    Temp := Values[I];
    Values[I] := Values[J];
    Values[J] := Temp;
  end;
end;

{$IFNDEF FPC}
class procedure TArrayUtils<T>.DoGenericsCollect(var Values: TArray<T>;
  const Callback: TArrayDualCallback);
begin
  TArray.Sort<T>(Values, TComparer<T>.Construct(function(const A, B: T): Integer begin
    Result := Callback(A, B);
  end));
end;
{$ENDIF}

class procedure TArrayUtils<T>.Flip(var Values: TArray<T>);
var
  AHigh: integer;
  AMiddle: integer;
  Temp: T;
  I: integer;
begin
  AHigh := High(Values);
  AMiddle := AHigh div 2;
  for I := 0 to AMiddle do begin
    Temp := Values[I];
    Values[I] := Values[AHigh-I];
    Values[AHigh-I] := Temp;
  end;

end;

class procedure TArrayUtils<T>.ForEach(var Values: TArray<T>;
  Callback: TArrayEachCallback);  
var
  I: integer;
begin
  for I := Low(Values) to High(Values) do
    Callback( Values[I] );
end;

class function TArrayUtils<T>.GetIndex(const Values: TArray<T>;
  Callback: TArrayFindItemCallback): integer;     
var
  I: integer;
begin
  Result := -1;
  for I := Low(Values) to High(Values) do
    if Callback( Values[I] ) then
      Exit(I);
end;

class function TArrayUtils<T>.GetIndex(const x: T; const Values: TArray<T>;
  StartingValue: integer): integer;
var
  I: Integer;
  y: T;
  Comparator: IEqualityComparer<T>;
begin
  Comparator := TEqualityComparer<T>.Default;

  for I := StartingValue to High(Values) do
    begin
      y := Values[I];

      if Comparator.Equals(x, y) then
        Exit(I);
    end;
    Exit(-1);
end;

class function TArrayUtils<T>.GetIndexDownTo(const x: T;
  const Values: TArray<T>; StartingValue: integer): integer;
var
  I: Integer;
  y: T;
  Comparator: IEqualityComparer<T>;
begin
  Comparator := TEqualityComparer<T>.Default;

  for I := StartingValue downto Low(Values) do
    begin
      y := Values[I];

      if Comparator.Equals(x, y) then
        Exit(I);
    end;
    Exit(-1);
end;

class function TArrayUtils<T>.GetIndexDownTo(const x: T;
  const Values: TArray<T>): integer;
var
  I: Integer;
  y: T;
  Comparator: IEqualityComparer<T>;
begin
  Comparator := TEqualityComparer<T>.Default;

  for I := High(Values) downto Low(Values) do
    begin
      y := Values[I];

      if Comparator.Equals(x, y) then
        Exit(I);
    end;
    Exit(-1);
end;

class procedure TArrayUtils<T>.ForEach(const Values: TArray<T>;
  Callback: TArrayEachCallbackConst);
var
  y : T;
begin
  for y in Values do
    Callback(y);
end;

class function TArrayUtils<T>.GetIndex(const x: T; const Values: TArray<T>): integer;
var
  I: Integer;
  y: T;
  Comparator: IEqualityComparer<T>;
begin
  Comparator := TEqualityComparer<T>.Default;

  for I := Low(Values) to High(Values) do
    begin
      y := Values[I];

      if Comparator.Equals(x, y) then
        Exit(I);
    end;
    Exit(-1);
end;

class procedure TArrayUtils<T>.Insert(const Index: integer;
  var Values: TArray<T>);
var
  Size: integer;
  I: Integer;
begin
  System.SetLength(Values, Length(Values)+1);
  Size := High(Values);

  for I := Size downto Index+1 do
    Values[I] := Values[I-1];
end;

class procedure TArrayUtils<T>.Insert(const Index: integer; const Value: T;
  var Values: TArray<T>);
begin
  Insert(Index, Values);

  // Set
  Values[Index] := Value;
end;

class procedure TArrayUtils<T>.Move(var Values: TArray<T>; const Source,
  Destination: integer);
var
  I: integer;
  OriginalItem: T;
begin
  OriginalItem := Values[Source];

  // Move all items
  if Source < Destination then begin
    for I := Source to Destination-1 do
      Values[I] := Values[I+1];
  end else begin
    for I := Source downto Destination+1 do
      Values[I] := Values[I-1];
  end;

  // Item
  Values[Destination] := OriginalItem;
end;

class function TArrayUtils<T>.Pop(var Values: TArray<T>): T;
begin
  Result := Values[High(Values)];
  System.SetLength(Values, High(Values));
end;

class procedure TArrayUtils<T>.ReplaceAllMatchingValues(const Value,
  NewValue: T; var Values: TArray<T>);
var
  Index: integer;
begin
  Index := GetIndexDownTo(Value, Values);
  while Index <> -1 do begin
    Values[Index] := NewValue;
    Index := GetIndexDownTo(Value, Values, Index-1);
  end;
end;

class function TArrayUtils<T>.ReplaceValue(const Value, NewValue: T;
  var Values: TArray<T>): boolean; 
var
  Index: integer;
begin
  Index := GetIndex(Value, Values);
  Result := Index <> -1;
  if Result then
    Values[Index] := NewValue;
end;

class procedure TArrayUtils<T>.DoQuickSort(var Values: TArray<T>;
  const Callback: TArrayDualCallback; Left, Right: Integer);
var
  Lower, Upper: Integer;
  Pivot, Temp: T;
begin
  if (Right - Left = 0) or (Right = -1) or (Left = -1) then
    Exit;

  Lower := Left;
  Upper := Right;
  Pivot := Values[(Left + Right) div 2]; // Choosing middle item as pivot

  repeat
    // Move Lower right while Values[Lower] < Pivot and ensure Lower stays within bounds
    while (Lower <= Right) and (Callback(Values[Lower], Pivot) = LessThanValue) do
      Inc(Lower);

    // Move Upper left while Values[Upper] > Pivot and ensure Upper stays within bounds
    while (Upper >= Left) and (Callback(Values[Upper], Pivot) = GreaterThanValue) do
      Dec(Upper);

    if Lower <= Upper then begin
      // Swap Values[Lower] and Values[Upper]
      Temp := Values[Lower];
      Values[Lower] := Values[Upper];
      Values[Upper] := Temp;

      Inc(Lower);
      Dec(Upper);
    end;
  until Lower > Upper;

  // Recursively sort the sub-arrays
  if Left < Upper then
    DoQuickSort(Values, Callback, Left, Upper);
  if Lower < Right then
    DoQuickSort(Values, Callback, Lower, Right);
end;

class procedure TArrayUtils<T>.SetLength(const Length: integer;
  var Values: TArray<T>);
begin
  System.SetLength(Values, Length);
end;

class function TArrayUtils<T>.Shift(var Values: TArray<T>): T;
begin
  Result := Values[0];
  Self.Delete(0, Values);
end;

class procedure TArrayUtils<T>.Shuffle(var Values: TArray<T>);
begin
  if Length(Values) > 1 then
    DoFisherYatesShuffle(Values, 0, Length(Values) - 1);
end;

class procedure TArrayUtils<T>.Sort(var Values: TArray<T>);
{$IFDEF FPC}
begin
  Sort(Values, _internal_compare);
{$ELSE}
var
  Comparator: IComparer<T>;
begin
  Comparator := TComparer<T>.Default;

  Sort(Values, function(const A, B: T): TValueRelationship begin
    Result := Comparator.Compare(A, B);
  end);
{$ENDIF}
end;

class function TArrayUtils<T>.Subtract(const Primary,
  Secondary: TArray<T>): TArray<T>;
begin
  Result := Copy(Primary);
  DeleteValues(Secondary, Result);
end;

class procedure TArrayUtils<T>.Sort(var Values: TArray<T>;
  const Callback: TArrayDualCallback);
begin
  DoQuickSort(Values, Callback, 0, Length(Values)-1);
end;

class procedure TArrayUtils<T>.Switch(var Values: TArray<T>; const Source,
  Destination: integer);    
var
  OriginalItem: T;
begin
  OriginalItem := Values[Source];
  Values[Source] := Values[Destination];
  Values[Destination] := OriginalItem;
end;

{$IFDEF FPC}
class function TArrayUtils<T>._internal_compare(const A,
  B: T): TValueRelationship;
begin
  Result := TComparer<T>.Default.Compare(A, B);
end;
{$ENDIF}

end.
