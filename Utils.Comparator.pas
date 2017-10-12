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

unit Utils.Comparator;

interface

uses
  System.Generics.Defaults;

type
  TEqualityComparator = record
  strict private
    FValue: Boolean;
  public
    class function Init: TEqualityComparator; inline; static;
    function ComparingGeneric<T>(const Left, Right: T): TEqualityComparator; overload; inline;
    function ComparingGeneric<T>(const Left, Right: T;
      const Comparison: TEqualityComparison<T>): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: Boolean): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: Integer): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: Int64): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: Cardinal): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: UInt64): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: Single): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: Double): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: String): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: Char): TEqualityComparator; overload; inline;
    function Comparing(const Left, Right: TObject): TEqualityComparator; overload; inline;
    function Compare: Boolean; inline;
  end;

  TComparator = record
  strict private
    FValue: Integer;
  public
    class function Init: TComparator; inline; static;
    function ComparingGeneric<T>(const Left, Right: T): TComparator; overload; inline;
    function ComparingGeneric<T>(const Left, Right: T;
      const Comparison: TComparison<T>): TComparator; overload; inline;
    function Comparing(const Left, Right: Boolean): TComparator; overload; inline;
    function Comparing(const Left, Right: Integer): TComparator; overload; inline;
    function Comparing(const Left, Right: Int64): TComparator; overload; inline;
    function Comparing(const Left, Right: Cardinal): TComparator; overload; inline;
    function Comparing(const Left, Right: UInt64): TComparator; overload; inline;
    function Comparing(const Left, Right: Single): TComparator; overload; inline;
    function Comparing(const Left, Right: Double): TComparator; overload; inline;
    function Comparing(const Left, Right: String): TComparator; overload; inline;
    function Comparing(const Left, Right: Char): TComparator; overload; inline;
    function Compare: Integer; inline;
  end;

implementation

uses
  System.SysUtils;

{ TEqualityComparator }

function TEqualityComparator.Compare: Boolean;
begin
  Result := FValue;
end;

function TEqualityComparator.Comparing(const Left, Right: Boolean): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: Integer): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: Int64): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: Cardinal): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: UInt64): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: Single): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: Double): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: String): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: Char): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := (Left = Right);
end;

function TEqualityComparator.Comparing(const Left, Right: TObject): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  if (Left = nil) and (Right = nil) then
  begin
    Result.FValue := true;
  end else
  if (Left = nil) xor (Right = nil) then
  begin
    Result.FValue := false;
  end else
  begin
    Result.FValue := Left.Equals(Right);
  end;
end;

function TEqualityComparator.ComparingGeneric<T>(const Left, Right: T): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := TEqualityComparer<T>.Default.Equals(Left, Right);
end;

function TEqualityComparator.ComparingGeneric<T>(const Left, Right: T;
  const Comparison: TEqualityComparison<T>): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result.FValue := TEqualityComparer<T>.Construct(Comparison, nil).Equals(Left, Right);
end;

class function TEqualityComparator.Init: TEqualityComparator;
begin
  Result.FValue := true;
end;

{ TComparator }

function TComparator.Compare: Integer;
begin
  Result := FValue;
end;

function TComparator.Comparing(const Left, Right: Boolean): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Right and (not Left)) then
  begin
    Result.FValue := -1;
  end else
  if (Left and (not Right)) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.Comparing(const Left, Right: Integer): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Left < Right) then
  begin
    Result.FValue := -1;
  end else
  if (Left > Right) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.Comparing(const Left, Right: Int64): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Left < Right) then
  begin
    Result.FValue := -1;
  end else
  if (Left > Right) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.Comparing(const Left, Right: Cardinal): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Left < Right) then
  begin
    Result.FValue := -1;
  end else
  if (Left > Right) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.Comparing(const Left, Right: UInt64): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Left < Right) then
  begin
    Result.FValue := -1;
  end else
  if (Left > Right) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.Comparing(const Left, Right: Single): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Left < Right) then
  begin
    Result.FValue := -1;
  end else
  if (Left > Right) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.Comparing(const Left, Right: Double): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Left < Right) then
  begin
    Result.FValue := -1;
  end else
  if (Left > Right) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.Comparing(const Left, Right: String): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  Result.FValue := AnsiCompareStr(Left, Right);
end;

function TComparator.Comparing(const Left, Right: Char): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  if (Left = Right) then
  begin
    Result.FValue := 0;
  end else
  if (Ord(Left) < Ord(Right)) then
  begin
    Result.FValue := -1;
  end else
  if (Ord(Left) > Ord(Right)) then
  begin
    Result.FValue := 1;
  end;
end;

function TComparator.ComparingGeneric<T>(const Left, Right: T): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  Result.FValue := TComparer<T>.Default.Compare(Left, Right);
end;

function TComparator.ComparingGeneric<T>(const Left, Right: T;
  const Comparison: TComparison<T>): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  Result.FValue := TComparer<T>.Construct(Comparison).Compare(Left, Right);
end;

class function TComparator.Init: TComparator;
begin
  Result.FValue := 0;
end;

end.