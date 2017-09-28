{***************************************************************************************************

  Delphi Utils

  Original Author : Florian Bernd

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.

***************************************************************************************************}

unit Utils.Container;

interface

uses
  System.Generics.Collections, System.Generics.Defaults;

type
  TItemToStringFunction<T> = reference to function(const Item: T): String;

  TArrayHelper = record
  public
    class procedure Add<T>(var A: TArray<T>; const Item: T); static; inline;
    class procedure Insert<T>(var A: TArray<T>; Index: Integer; const Item: T); static;
    class procedure Delete<T>(var A: TArray<T>; Index: Integer); static;
    class procedure Exchange<T>(var A: TArray<T>; Index1, Index2: Integer); static; inline;
  public
    class procedure BubbleSort<T>(var A: TArray<T>;
      const Comparer: IComparer<T>); overload; static; inline;
    class procedure BubbleSort<T>(var A: TArray<T>;
      const Comparer: IComparer<T>; Index, Count: Integer); overload; static;
  public
    class function ToString<T>(const A: TArray<T>;
      const ItemDelimiter: String = sLineBreak): String; overload; static; inline;
    class function ToString<T>(const A: TArray<T>;
      const ToStringFunction: TItemToStringFunction<T>;
      const ItemDelimiter: String = sLineBreak): String; overload; static; inline;
  end;

  TListHelper = record
  public
    class procedure BubbleSort<T>(var List: TList<T>;
      const Comparer: IComparer<T>); overload; static; inline;
    class procedure BubbleSort<T>(var List: TList<T>;
      const Comparer: IComparer<T>; Index, Count: Integer); overload; static;
  public
    class function ToString<T>(const List: TList<T>;
      const ItemDelimiter: String = sLineBreak): String; overload; static; inline;
    class function ToString<T>(const List: TList<T>;
      const ToStringFunction: TItemToStringFunction<T>;
      const ItemDelimiter: String = sLineBreak): String; overload; static; inline;
  end;

implementation

uses
  System.SysUtils, System.RTLConsts, System.RTTI;

{ TArrayHelper }

class procedure TArrayHelper.Add<T>(var A: TArray<T>; const Item: T);
var
  I: Integer;
begin
  I := Length(A);
  SetLength(A, I + 1);
  A[I] := Item;
end;

class procedure TArrayHelper.BubbleSort<T>(var A: TArray<T>; const Comparer: IComparer<T>);
begin
  BubbleSort<T>(A, Comparer, Low(A), Length(A));
end;

class procedure TArrayHelper.BubbleSort<T>(var A: TArray<T>; const Comparer: IComparer<T>; Index,
  Count: Integer);
var
  I, H: Integer;
  Done: Boolean;
begin
  if (Index < Low(A)) or ((Index > High(A)) and (Count > 0)) or (Index + Count - 1 > High(A)) or
    (Count < 0) or (Index + Count < 0) then
  begin
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  end;
  if (Count <= 1) then
  begin
    Exit;
  end;
  H := Index + Count - 1;
  repeat
    Dec(H);
    Done := true;
    for I := Index to H do
    begin
      if (Comparer.Compare(A[I], A[I + 1]) > 0) then
      begin
        Exchange<T>(A, I, I + 1);
        Done := false;
      end;
    end;
  until Done;
end;

class procedure TArrayHelper.Delete<T>(var A: TArray<T>; Index: Integer);
var
  I: Integer;
begin
  for I := Index to High(A) - 1 do
  begin
    A[I] := A[I + 1];
  end;
  SetLength(A, Length(A) - 1);
end;

class procedure TArrayHelper.Exchange<T>(var A: TArray<T>; Index1, Index2: Integer);
var
  Temp: T;
begin
  Temp := A[Index1];
  A[Index1] := A[Index2];
  A[Index2] := Temp;
end;

class procedure TArrayHelper.Insert<T>(var A: TArray<T>; Index: Integer; const Item: T);
var
  I: Integer;
begin
  SetLength(A, Length(A) + 1);
  for I := High(A) - 1 downto Index do
  begin
    A[I + 1] := A[I];
  end;
  A[Index] := Item;
end;

class function TArrayHelper.ToString<T>(const A: TArray<T>; const ItemDelimiter: String): String;
begin
  Result := ToString<T>(A,
    function(const Item: T): String
    begin
      Result := TValue.From<T>(Item).ToString;
    end, ItemDelimiter);
end;

class function TArrayHelper.ToString<T>(const A: TArray<T>;
  const ToStringFunction: TItemToStringFunction<T>; const ItemDelimiter: String): String;
var
  Builder: TStringBuilder;
  I: Integer;
begin
  if (Length(A) = 0) then Exit('');
  Builder := TStringBuilder.Create;
  try
    for I := Low(A) to High(A) do
    begin
      Builder.Append(ToStringFunction(A[I]));
      if (I <> High(A)) then
      begin
        Builder.Append(ItemDelimiter);
      end;
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

{ TListHelper }

class procedure TListHelper.BubbleSort<T>(var List: TList<T>; const Comparer: IComparer<T>);
begin
  BubbleSort<T>(List, Comparer, 0, List.Count);
end;

class procedure TListHelper.BubbleSort<T>(var List: TList<T>; const Comparer: IComparer<T>; Index,
  Count: Integer);
var
  I, H: Integer;
  Done: Boolean;
begin
  if (Index < 0) or ((Index >= List.Count) and (Count > 0)) or (Index + Count - 1 >= List.Count) or
    (Count < 0) or (Index + Count < 0) then
  begin
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  end;
  if (Count <= 1) then
  begin
    Exit;
  end;
  H := Index + Count - 1;
  repeat
    Dec(H);
    Done := true;
    for I := Index to H do
    begin
      if (Comparer.Compare(List[I], List[I + 1]) > 0) then
      begin
        List.Exchange(I, I + 1);
        Done := false;
      end;
    end;
  until Done;
end;

class function TListHelper.ToString<T>(const List: TList<T>;
  const ItemDelimiter: String): String;
begin
  Result := ToString<T>(List,
    function(const Item: T): String
    begin
      Result := TValue.From<T>(Item).ToString;
    end);
end;

class function TListHelper.ToString<T>(const List: TList<T>;
  const ToStringFunction: TItemToStringFunction<T>; const ItemDelimiter: String): String;
var
  Builder: TStringBuilder;
  I: Integer;
begin
  if (List.Count = 0) then Exit('');
  Builder := TStringBuilder.Create;
  try
    for I := 0 to List.Count - 1 do
    begin
      Builder.Append(ToStringFunction(List[I]));
      if (I <> List.Count - 1) then
      begin
        Builder.Append(ItemDelimiter);
      end;
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

end.
