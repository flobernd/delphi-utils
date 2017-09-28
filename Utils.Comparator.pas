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
    class function Comparing<T>(
      const Left, Right: T): TEqualityComparator; overload; inline; static;
    class function Comparing<T>(const Left, Right: T;
      const Comparison: TEqualityComparison<T>): TEqualityComparator; overload; inline; static;
    function ThenComparing<T>(const Left, Right: T): TEqualityComparator; overload; inline;
    function ThenComparing<T>(const Left, Right: T;
      const Comparison: TEqualityComparison<T>): TEqualityComparator; overload; inline;
    function Compare: Boolean; inline;
  end;

  TComparator = record
  strict private
    FValue: Integer;
  public
    class function Comparing<T>(const Left, Right: T): TComparator; overload; inline; static;
    class function Comparing<T>(const Left, Right: T;
      const Comparison: TComparison<T>): TComparator; overload; inline; static;
    function ThenComparing<T>(const Left, Right: T): TComparator; overload; inline;
    function ThenComparing<T>(const Left, Right: T;
      const Comparison: TComparison<T>): TComparator; overload; inline;
    function Compare: Integer; inline;
  end;

implementation

{ TEqualityComparator }

function TEqualityComparator.Compare: Boolean;
begin
  Result := FValue;
end;

class function TEqualityComparator.Comparing<T>(const Left, Right: T): TEqualityComparator;
begin
  Result.FValue := TEqualityComparer<T>.Default.Equals(Left, Right);
end;

class function TEqualityComparator.Comparing<T>(const Left, Right: T;
  const Comparison: TEqualityComparison<T>): TEqualityComparator;
begin
  Result.FValue := TEqualityComparer<T>.Construct(Comparison, nil).Equals(Left, Right);
end;

function TEqualityComparator.ThenComparing<T>(const Left, Right: T): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result := Comparing<T>(Left, Right);
end;

function TEqualityComparator.ThenComparing<T>(const Left, Right: T;
  const Comparison: TEqualityComparison<T>): TEqualityComparator;
begin
  if (not FValue) then Exit(Self);
  Result := Comparing<T>(Left, Right, Comparison);
end;

{ TComparator }

function TComparator.Compare: Integer;
begin
  Result := FValue;
end;

class function TComparator.Comparing<T>(const Left, Right: T): TComparator;
begin
  Result.FValue := TComparer<T>.Default.Compare(Left, Right);
end;

class function TComparator.Comparing<T>(const Left, Right: T;
  const Comparison: TComparison<T>): TComparator;
begin
  Result.FValue := TComparer<T>.Construct(Comparison).Compare(Left, Right);
end;

function TComparator.ThenComparing<T>(const Left, Right: T): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  Result := Comparing<T>(Left, Right);
end;

function TComparator.ThenComparing<T>(const Left, Right: T;
  const Comparison: TComparison<T>): TComparator;
begin
  if (FValue <> 0) then Exit(Self);
  Result := Comparing<T>(Left, Right, Comparison);
end;

end.
