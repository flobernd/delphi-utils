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

unit Utils.JSON;

interface

uses
  System.SysUtils, System.JSON, System.TypInfo;

type
  TJSONType = (
    jsonInvalid,
    jsonInteger,
    jsonFloat,
    jsonString,
    jsonBoolean,
    jsonArray,
    jsonObject,
    jsonNull
  );

  TJSONHelper = record
  public
    class function ValueType(Value: TJSONValue): TJSONType; static;
  end;

  EJSONException = class(Exception)
  strict private
    FPath: String;
  public
    property Path: String read FPath write FPath;
  end;

  TJSONTypes = set of TJSONType;

  EJSONTypeException = class(EJSONException)
  strict private
    FAcceptedTypes: TJSONTypes;
  public
    property AcceptedTypes: TJSONTypes read FAcceptedTypes write FAcceptedTypes;
  end;

  EJSONValueException = class(EJSONException);

  TJSONArrayReader  = class;
  TJSONObjectReader = class;
  IJSONObjectReader = interface;

  IJSONArrayReader = interface['{0AFD8041-3B91-4054-ABBD-E186FFC2853E}']
  { Getter }
    function GetInnerObject: TJSONArray;
    function GetReader: TJSONArrayReader;
    function GetCurrentPath: String;
  { Methods }
    function ReadInteger(Index: Integer): Integer;
    function ReadInt64(Index: Integer): Int64;
    function ReadDouble(Index: Integer): Double;
    function ReadString(Index: Integer): String;
    function ReadBoolean(Index: Integer): Boolean;
    function ReadArray(Index: Integer): IJSONArrayReader;
    function ReadObject(Index: Integer): IJSONObjectReader;
    function ValueType(Index: Integer): TJSONType;
  { Properties }
    property InnerObject: TJSONArray read GetInnerObject;
    property Reader: TJSONArrayReader read GetReader;
    property CurrentPath: String read GetCurrentPath;
  end;

  IJSONObjectReader = interface['{34D2B62A-41B8-49FF-A2E4-6A12BE8186C0}']
  { Getter }
    function GetInnerObject: TJSONObject;
    function GetReader: TJSONObjectReader;
    function GetCurrentPath: String;
  { Methods }
    function ReadInteger(const Name: String): Integer; overload;
    function ReadInteger(const Name: String; Default: Integer): Integer; overload;
    function ReadInt64(const Name: String): Int64; overload;
    function ReadInt64(const Name: String; Default: Int64): Int64; overload;
    function ReadDouble(const Name: String): Double; overload;
    function ReadDouble(const Name: String; Default: Double): Double; overload;
    function ReadString(const Name: String): String; overload;
    function ReadString(const Name: String; const Default: String): String; overload;
    function ReadBoolean(const Name: String): Boolean; overload;
    function ReadBoolean(const Name: String; Default: Boolean): Boolean; overload;
    function ReadArray(const Name: String): IJSONArrayReader;
    function ReadObject(const Name: String): IJSONObjectReader;
    function ValueType(const Name: String): TJSONType;
    function ValueExists(const Name: String): Boolean;
  { Properties }
    property InnerObject: TJSONObject read GetInnerObject;
    property Reader: TJSONObjectReader read GetReader;
    property CurrentPath: String read GetCurrentPath;
  end;

  TJSONArrayReader = class sealed(TInterfacedObject, IJSONArrayReader)
  strict private type
    TGenericSet = set of 0..255;
  strict private
    FJSON: TJSONArray;
    FCurrentPath: String;
  strict private
    function GetInnerObject: TJSONArray; inline;
    function GetReader: TJSONArrayReader; inline;
    function GetCurrentPath: String; inline;
  strict private
    function JSONValueToEnumOrdinal(TypeInfo: PTypeInfo; Index: Integer;
      const EnumStrings: array of String): Integer;
  strict private
    procedure RaiseTypeException(AcceptedTypes: TJSONTypes; Index: Integer);
    procedure RaiseEnumValException(Index: Integer);
  strict private
    function ReadValue(AType: TJSONType; Index: Integer): TJSONValue; inline;
    function ReadSetValue<T>(Index: Integer; const EnumStrings: array of String): T;
  public
    function ReadInteger(Index: Integer): Integer; overload; inline;
    function ReadInt64(Index: Integer): Int64; overload; inline;
    function ReadDouble(Index: Integer): Double; overload; inline;
    function ReadString(Index: Integer): String; overload; inline;
    function ReadBoolean(Index: Integer): Boolean; overload; inline;
    function ReadEnum(TypeInfo: PTypeInfo; Index: Integer): Integer; overload;
    function ReadEnum(TypeInfo: PTypeInfo; Index: Integer;
      const EnumStrings: array of String): Integer; overload;
    function ReadEnum<T: record>(Index: Integer): T; overload; inline;
    function ReadEnum<T: record>(Index: Integer;
      const EnumStrings: array of String): T; overload;
    function ReadSet<T>(Index: Integer): T; overload; inline;
    function ReadSet<T>(Index: Integer; const EnumStrings: array of String): T; overload;
    function ReadArray(Index: Integer): IJSONArrayReader; overload; inline;
    function ReadObject(Index: Integer): IJSONObjectReader; overload; inline;
    function ValueType(Index: Integer): TJSONType; inline;
  public
    constructor Create(JSON: TJSONArray; const CurrentPath: String = 'JSON');
  public
    property InnerObject: TJSONArray read GetInnerObject;
    property Reader: TJSONArrayReader read GetReader;
    property CurrentPath: String read GetCurrentPath;
  end;

  TJSONObjectReader = class sealed(TInterfacedObject, IJSONObjectReader)
  strict private type
    TGenericSet = set of 0..255;
  strict private
    FJSON: TJSONObject;
    FCurrentPath: String;
  strict private
    function GetInnerObject: TJSONObject; inline;
    function GetReader: TJSONObjectReader; inline;
    function GetCurrentPath: String; inline;
  strict private
    function JSONValueToEnumOrdinal(TypeInfo: PTypeInfo; const Name: String;
      const EnumStrings: array of String): Integer; overload;
  strict private
    procedure RaiseTypeException(AcceptedTypes: TJSONTypes; const Name: String);
    procedure RaiseEnumValException(const Name: String);
  strict private
    function ReadValue(AType: TJSONType; const Name: String;
      IgnoreMissingValue: Boolean): TJSONValue; overload; inline;
    function ReadSetValue<T>(const Name: String; UseDefault: Boolean; Default: T;
      const EnumStrings: array of String): T;
  public
    function ReadInteger(const Name: String): Integer; overload; inline;
    function ReadInteger(const Name: String; Default: Integer): Integer; overload; inline;
    function ReadInt64(const Name: String): Int64; overload; inline;
    function ReadInt64(const Name: String; Default: Int64): Int64; overload; inline;
    function ReadDouble(const Name: String): Double; overload; inline;
    function ReadDouble(const Name: String; Default: Double): Double; overload; inline;
    function ReadString(const Name: String): String; overload; inline;
    function ReadString(const Name: String; const Default: String): String; overload; inline;
    function ReadBoolean(const Name: String): Boolean; overload; inline;
    function ReadBoolean(const Name: String; Default: Boolean): Boolean; overload; inline;
    function ReadEnum<T: record>(const Name: String): T; overload; inline;
    function ReadEnum<T: record>(const Name: String;
      const EnumStrings: array of String): T; overload;
    function ReadEnum<T: record>(const Name: String; const Default: T): T; overload; inline;
    function ReadEnum<T: record>(const Name: String; const Default: T;
      const EnumStrings: array of String): T; overload;
    function ReadSet<T>(const Name: String): T; overload; inline;
    function ReadSet<T>(const Name: String; const EnumStrings: array of String): T; overload;
    function ReadSet<T>(const Name: String; const Default: T): T; overload; inline;
    function ReadSet<T>(const Name: String; const Default: T;
      const EnumStrings: array of String): T; overload;
    function ReadArray(const Name: String): IJSONArrayReader; inline;
    function ReadObject(const Name: String): IJSONObjectReader; inline;
    function ValueType(const Name: String): TJSONType; inline;
    function ValueExists(const Name: String): Boolean; inline;
  public
    constructor Create(JSON: TJSONObject; const CurrentPath: String = 'JSON');
  public
    property InnerObject: TJSONObject read GetInnerObject;
    property Reader: TJSONObjectReader read GetReader;
    property CurrentPath: String read GetCurrentPath;
  end;

  TJSONArrayWriter  = class;
  TJSONObjectWriter = class;
  IJSONObjectWriter = interface;

  TJSONCondWriteArrayFunc  = reference to function(JSON: TJSONArrayWriter): Boolean;
  TJSONCondWriteObjectFunc = reference to function(JSON: TJSONObjectWriter): Boolean;

  IJSONArrayWriter = interface['{DF1DDF6D-4D72-4731-A5E2-0421AC479B8D}']
  { Getter }
    function GetInnerObject: TJSONArray;
    function GetWriter: TJSONArrayWriter;
  { Methods }
    procedure AddInteger(Value: Integer);
    procedure AddInt64(Value: Int64);
    procedure AddDouble(Value: Double);
    procedure AddString(const Value: String);
    procedure AddBoolean(Value: Boolean);
    procedure AddNull;
    function AddArray: IJSONArrayWriter; overload;
    procedure AddArray(WriteFunc: TJSONCondWriteArrayFunc); overload;
    procedure AddArrayOrNull(WriteFunc: TJSONCondWriteArrayFunc);
    function AddObject: IJSONObjectWriter; overload;
    procedure AddObject(WriteFunc: TJSONCondWriteObjectFunc); overload;
    procedure AddObjectOrNull(WriteFunc: TJSONCondWriteObjectFunc);
    procedure Remove(Index: Integer);
  { Properties }
    property InnerObject: TJSONArray read GetInnerObject;
    property Writer: TJSONArrayWriter read GetWriter;
  end;

  IJSONObjectWriter = interface['{74BEF8A4-55A7-442C-A6B7-AFCDE96637E6}']
  { Getter }
    function GetInnerObject: TJSONObject;
    function GetWriter: TJSONObjectWriter;
  { Methods }
    procedure WriteInteger(const Name: String; Value: Integer);
    procedure WriteInt64(const Name: String; Value: Int64);
    procedure WriteDouble(const Name: String; Value: Double);
    procedure WriteString(const Name: String; const Value: String);
    procedure WriteBoolean(const Name: String; Value: Boolean);
    procedure WriteNull(const Name: String);
    function WriteArray(const Name: String): IJSONArrayWriter; overload;
    procedure WriteArray(const Name: String; WriteFunc: TJSONCondWriteArrayFunc); overload;
    procedure WriteArrayOrNull(const Name: String; WriteFunc: TJSONCondWriteArrayFunc);
    function WriteObject(const Name: String): IJSONObjectWriter; overload;
    procedure WriteObject(const Name: String; WriteFunc: TJSONCondWriteObjectFunc); overload;
    procedure WriteObjectOrNull(const Name: String; WriteFunc: TJSONCondWriteObjectFunc);
    procedure Remove(const Name: String);
  { Properties }
    property InnerObject: TJSONObject read GetInnerObject;
    property Writer: TJSONObjectWriter read GetWriter;
  end;

  TJSONArrayWriter = class sealed(TInterfacedObject, IJSONArrayWriter)
  strict private type
    TGenericSet = set of 0..255;
  strict private
    FJSON: TJSONArray;
  strict private
    function GetInnerObject: TJSONArray;
    function GetWriter: TJSONArrayWriter;
  strict private
    function JSONValueFromEnum<T: record>(Value: T; UseEnumStrings: Boolean;
      const EnumStrings: array of String): TJSONValue;
    function JSONValueFromSet<T>(Value: T; UseEnumStrings: Boolean;
      const EnumStrings: array of String): TJSONArray;
  public
    procedure AddInteger(Value: Integer); inline;
    procedure AddInt64(Value: Int64); inline;
    procedure AddDouble(Value: Double); inline;
    procedure AddString(const Value: String); inline;
    procedure AddBoolean(Value: Boolean); inline;
    procedure AddEnum<T: record>(Value: T; UseEnumStrings: Boolean = false); overload; inline;
    procedure AddEnum<T: record>(Value: T; const EnumStrings: array of String); overload;
    procedure AddSet<T>(Value: T; UseEnumStrings: Boolean = false); overload; inline;
    procedure AddSet<T>(Value: T; const EnumStrings: array of String); overload;
    procedure AddNull; inline;
    function AddArray: IJSONArrayWriter; overload; inline;
    procedure AddArray(WriteFunc: TJSONCondWriteArrayFunc); overload; inline;
    procedure AddArrayOrNull(WriteFunc: TJSONCondWriteArrayFunc); inline;
    function AddObject: IJSONObjectWriter; overload; inline;
    procedure AddObject(WriteFunc: TJSONCondWriteObjectFunc); overload; inline;
    procedure AddObjectOrNull(WriteFunc: TJSONCondWriteObjectFunc); inline;
    procedure Remove(Index: Integer); inline;
  public
    constructor Create(JSON: TJSONArray);
  public
    property InnerObject: TJSONArray read GetInnerObject;
    property Writer: TJSONArrayWriter read GetWriter;
  end;

  TJSONObjectWriter = class sealed(TInterfacedObject, IJSONObjectWriter)
  strict private type
    TGenericSet = set of 0..255;
  strict private
    FJSON: TJSONObject;
  strict private
    function GetInnerObject: TJSONObject;
    function GetWriter: TJSONObjectWriter;
  strict private
    function JSONValueFromEnum<T: record>(Value: T; UseEnumStrings: Boolean;
      const EnumStrings: array of String): TJSONValue;
    function JSONValueFromSet<T>(Value: T; UseEnumStrings: Boolean;
      const EnumStrings: array of String): TJSONArray;
  public
    procedure WriteInteger(const Name: String; Value: Integer); inline;
    procedure WriteInt64(const Name: String; Value: Int64); inline;
    procedure WriteDouble(const Name: String; Value: Double); inline;
    procedure WriteString(const Name: String; const Value: String); inline;
    procedure WriteBoolean(const Name: String; Value: Boolean); inline;
    procedure WriteEnum<T: record>(const Name: String; Value: T;
      UseEnumStrings: Boolean = false); overload; inline;
    procedure WriteEnum<T: record>(const Name: String; Value: T;
      const EnumStrings: array of String); overload;
    procedure WriteSet<T>(const Name: String; Value: T;
      UseEnumStrings: Boolean = false); overload; inline;
    procedure WriteSet<T>(const Name: String; Value: T;
      const EnumStrings: array of String); overload;
    procedure WriteNull(const Name: String); inline;
    function WriteArray(const Name: String): IJSONArrayWriter; overload; inline;
    procedure WriteArray(const Name: String; WriteFunc: TJSONCondWriteArrayFunc); overload; inline;
    procedure WriteArrayOrNull(const Name: String; WriteFunc: TJSONCondWriteArrayFunc); inline;
    function WriteObject(const Name: String): IJSONObjectWriter; overload; inline;
    procedure WriteObject(const Name: String;
      WriteFunc: TJSONCondWriteObjectFunc); overload; inline;
    procedure WriteObjectOrNull(const Name: String; WriteFunc: TJSONCondWriteObjectFunc); inline;
    procedure Remove(const Name: String);
  public
    constructor Create(JSON: TJSONObject);
  public
    property InnerObject: TJSONObject read GetInnerObject;
    property Writer: TJSONObjectWriter read GetWriter;
  end;

  TJSONFormatter = record
  strict private
    class procedure FormatValue(Builder: TStringBuilder; const JSON: TJSONValue); static; inline;
  strict private
    class procedure FormatCompact(Builder: TStringBuilder;
      const JSON: TJSONValue); overload; static;
    class procedure FormatPretty(Builder: TStringBuilder; const JSON: TJSONValue;
      const Indent: String; const CurrentIndent: String); overload; static;
  public
    class procedure Format(Builder: TStringBuilder; const JSON: TJSONValue;
      PrettyPrint: Boolean = false;
      Indent: Integer = 2; InitialIndent: Integer = 0); overload; static; inline;
    class function Format(const JSON: TJSONValue;
      PrettyPrint: Boolean = false;
      Indent: Integer = 2; InitialIndent: Integer = 0): String; overload; static; inline;
  end;

implementation

uses
  System.StrUtils;

{$REGION 'Internal Helper Functions'}
function FormatType(AType: TJSONType): String;
begin
  Result := '';
  case AType of
    TJSONType.jsonInteger : Result := 'INTEGER';
    TJSONType.jsonFloat   : Result := 'FLOAT';
    TJSONType.jsonString  : Result := 'STRING';
    TJSONType.jsonBoolean : Result := 'BOOLEAN';
    TJSONType.jsonArray   : Result := 'ARRAY';
    TJSONType.jsonObject  : Result := 'OBJECT';
    TJSONType.jsonNull    : Result := 'NULL';
  end;
end;
{$ENDREGION}

{$REGION 'Class: TJSONHelper'}
class function TJSONHelper.ValueType(Value: TJSONValue): TJSONType;
begin
  Result := TJSONType.jsonInvalid;
  if (Value is TJSONNumber) then
  begin
    if (Value.ToString.Contains(GetJSONFormat.DecimalSeparator)) then
    begin
      Result := TJSONType.jsonFloat;
    end else
    begin
      Result := TJSONType.jsonInteger;
    end;
  end else
  if (Value is TJSONString) then
  begin
    Result := TJSONType.jsonString;
  end else
  if (Value is TJSONBool) then
  begin
    Result := TJSONType.jsonBoolean;
  end else
  if (Value is TJSONArray) then
  begin
    Result := TJSONType.jsonArray;
  end else
  if (Value is TJSONObject) then
  begin
    Result := TJSONType.jsonObject;
  end else
  if (Value is TJSONNull) then
  begin
    Result := TJSONType.jsonNull;
  end;
end;
{$ENDREGION}

{$REGION 'Class: TJSONArrayReader'}
constructor TJSONArrayReader.Create(JSON: TJSONArray; const CurrentPath: String);
begin
  inherited Create;
  FJSON := JSON;
  FCurrentPath := CurrentPath;
end;

function TJSONArrayReader.GetInnerObject: TJSONArray;
begin
  Result := FJSON;
end;

function TJSONArrayReader.GetReader: TJSONArrayReader;
begin
  Result := Self;
end;

function TJSONArrayReader.GetCurrentPath: String;
begin
  Result := FCurrentPath;
end;

function TJSONArrayReader.JSONValueToEnumOrdinal(TypeInfo: PTypeInfo; Index: Integer;
  const EnumStrings: array of String): Integer;
var
  TypeData: PTypeData;
begin
  Assert(Assigned(TypeInfo),
    'No type-info found for the given generic type');
  Assert(TypeInfo^.Kind = tkEnumeration,
    'The generic type "' + TypeInfo^.Name + '" is not an enum-type');

  Result := -1;
  if (Length(EnumStrings) = 0) then
  begin
    case ValueType(Index) of
      jsonInteger: Result := ReadInteger(Index);
      jsonString : Result := System.TypInfo.GetEnumValue(TypeInfo, ReadString(Index)) else
        RaiseTypeException([jsonInteger, jsonString], Index);
    end;
  end else
  begin
    Result := System.StrUtils.IndexText(ReadString(Index), EnumStrings);
  end;

  TypeData := System.TypInfo.GetTypeData(TypeInfo);
  if (Result < TypeData^.MinValue) or (Result > TypeData^.MaxValue) then
  begin
    RaiseEnumValException(Index);
  end;
end;

procedure TJSONArrayReader.RaiseTypeException(AcceptedTypes: TJSONTypes; Index: Integer);
var
  S: String;
  T: TJSONType;
  E: EJSONTypeException;
begin
  S := '';
  for T in AcceptedTypes do
  begin
    S := S + FormatType(T) + '/';
  end;
  Delete(S, Length(S), 1);
  E := EJSONTypeException.CreateFmt('"%s[%d]" is missing or does not contain a valid %s value.',
    [FCurrentPath, Index, S]);
  E.Path := Format('%s[%d]', [FCurrentPath, Index]);
  E.AcceptedTypes := AcceptedTypes;
  raise E;
end;

procedure TJSONArrayReader.RaiseEnumValException(Index: Integer);
var
  E: EJSONValueException;
begin
  E := EJSONValueException.CreateFmt('"%s[%d]" contains an invalid enum value.',
    [FCurrentPath, Index]);
  E.Path := FCurrentPath;
  raise E;
end;

function TJSONArrayReader.ReadValue(AType: TJSONType; Index: Integer): TJSONValue;
begin
  Result := FJSON.Items[Index];
  if (TJSONHelper.ValueType(Result) <> AType) then
  begin
    RaiseTypeException([AType], Index);
  end;
end;

function TJSONArrayReader.ReadSetValue<T>(Index: Integer; const EnumStrings: array of String): T;
var
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  A: IJSONArrayReader;
  I: Integer;
begin
  TypeInfo := System.TypeInfo(T);
  Assert(Assigned(TypeInfo),
    'No type-info found for the given generic type');
  Assert(GetTypeKind(T) = tkSet,
    'The generic type "' + TypeInfo^.Name + '" is not a set-type');

  TypeData := System.TypInfo.GetTypeData(TypeInfo);
  TypeInfo := GetTypeData(System.TypeInfo(T))^.CompType^;
  TypeData := System.TypInfo.GetTypeData(TypeInfo);

  A := ReadArray(Index);
  FillChar(Result, SizeOf(T), #0);
  for I := 0 to A.InnerObject.Count - 1 do
  begin
    Include(TGenericSet(Pointer(@Result)^), A.Reader.ReadEnum(TypeInfo, I, EnumStrings));
  end;
end;

function TJSONArrayReader.ReadInteger(Index: Integer): Integer;
begin
  Result := TJSONNumber(ReadValue(TJSONType.jsonInteger, Index)).AsInt;
end;

function TJSONArrayReader.ReadInt64(Index: Integer): Int64;
begin
  Result := TJSONNumber(ReadValue(TJSONType.jsonInteger, Index)).AsInt64;
end;

function TJSONArrayReader.ReadDouble(Index: Integer): Double;
begin
  Result := TJSONNumber(ReadValue(TJSONType.jsonFloat, Index)).AsDouble;
end;

function TJSONArrayReader.ReadString(Index: Integer): String;
begin
  Result := TJSONString(ReadValue(TJSONType.jsonString, Index)).Value;
end;

function TJSONArrayReader.ReadBoolean(Index: Integer): Boolean;
begin
  Result := TJSONBool(ReadValue(TJSONType.jsonBoolean, Index)).AsBoolean;
end;

function TJSONArrayReader.ReadEnum(TypeInfo: PTypeInfo; Index: Integer): Integer;
begin
  Result := JSONValueToEnumOrdinal(TypeInfo, Index, []);
end;

function TJSONArrayReader.ReadEnum(TypeInfo: PTypeInfo; Index: Integer;
  const EnumStrings: array of String): Integer;
begin
  Result := JSONValueToEnumOrdinal(TypeInfo, Index, EnumStrings);
end;

function TJSONArrayReader.ReadEnum<T>(Index: Integer): T;
var
  I: Integer;
begin
  Assert(SizeOf(Result) <= SizeOf(I));
  I := ReadEnum(System.TypeInfo(T), Index);
  Move(I, Result, SizeOf(Result));
end;

function TJSONArrayReader.ReadEnum<T>(Index: Integer; const EnumStrings: array of String): T;
var
  I: Integer;
begin
  Assert(SizeOf(Result) <= SizeOf(I));
  I := ReadEnum(System.TypeInfo(T), Index, EnumStrings);
  Move(I, Result, SizeOf(Result));
end;

function TJSONArrayReader.ReadSet<T>(Index: Integer): T;
begin
  Result := ReadSetValue<T>(Index, []);
end;

function TJSONArrayReader.ReadSet<T>(Index: Integer; const EnumStrings: array of String): T;
begin
  Result := ReadSetValue<T>(Index, EnumStrings);
end;

function TJSONArrayReader.ReadArray(Index: Integer): IJSONArrayReader;
begin
  Result := TJSONArrayReader.Create(TJSONArray(ReadValue(TJSONType.jsonArray, Index)),
    Format('%s[%d]', [FCurrentPath, Index]));
end;

function TJSONArrayReader.ReadObject(Index: Integer): IJSONObjectReader;
begin
  Result := TJSONObjectReader.Create(TJSONObject(ReadValue(TJSONType.jsonObject, Index)),
    Format('%s[%d]', [FCurrentPath, Index]));
end;

function TJSONArrayReader.ValueType(Index: Integer): TJSONType;
begin
  Result := TJSONHelper.ValueType(FJSON.Items[Index]);
end;
{$ENDREGION}

{$REGION 'Class: TJSONObjectReader'}
constructor TJSONObjectReader.Create(JSON: TJSONObject; const CurrentPath: String);
begin
  inherited Create;
  FJSON := JSON;
  FCurrentPath := CurrentPath;
end;

function TJSONObjectReader.GetInnerObject: TJSONObject;
begin
  Result := FJSON;
end;

function TJSONObjectReader.GetReader: TJSONObjectReader;
begin
  Result := Self;
end;

function TJSONObjectReader.GetCurrentPath: String;
begin
  Result := FCurrentPath;
end;

function TJSONObjectReader.JSONValueToEnumOrdinal(TypeInfo: PTypeInfo; const Name: String;
  const EnumStrings: array of String): Integer;
var
  TypeData: PTypeData;
begin
  Assert(Assigned(TypeInfo),
    'No type-info found for the given generic type');
  Assert(TypeInfo^.Kind = tkEnumeration,
    'The generic type "' + TypeInfo^.Name + '" is not an enum-type');

  Result := -1;
  if (Length(EnumStrings) = 0) then
  begin
    case ValueType(Name) of
      jsonInteger: Result := ReadInteger(Name);
      jsonString : Result := System.TypInfo.GetEnumValue(TypeInfo, ReadString(Name)) else
        RaiseTypeException([jsonInteger, jsonString], Name);
    end;
  end else
  begin
    Result := System.StrUtils.IndexText(ReadString(Name), EnumStrings);
  end;

  TypeData := System.TypInfo.GetTypeData(TypeInfo);
  if (Result < TypeData^.MinValue) or (Result > TypeData^.MaxValue) then
  begin
    RaiseEnumValException(Name);
  end;
end;

procedure TJSONObjectReader.RaiseTypeException(AcceptedTypes: TJSONTypes; const Name: String);
var
  S: String;
  T: TJSONType;
  E: EJSONTypeException;
begin
  S := '';
  for T in AcceptedTypes do
  begin
    S := S + FormatType(T) + '/';
  end;
  Delete(S, Length(S), 1);
  E := EJSONTypeException.CreateFmt('"%s.%s" is missing or does not contain a valid %s value.',
    [FCurrentPath, Name, S]);
  E.Path := Format('%s.%s', [FCurrentPath, Name]);
  E.AcceptedTypes := AcceptedTypes;
  raise E;
end;

procedure TJSONObjectReader.RaiseEnumValException(const Name: String);
var
  E: EJSONValueException;
begin
  E := EJSONValueException.CreateFmt('"%s.%s" contains an invalid enum value.',
    [FCurrentPath, Name]);
  E.Path := FCurrentPath;
  raise E;
end;

function TJSONObjectReader.ReadValue(AType: TJSONType; const Name: String;
  IgnoreMissingValue: Boolean): TJSONValue;
begin
  Result := FJSON.Values[Name];
  if (IgnoreMissingValue and (not Assigned(Result))) then
  begin
    Result := nil;
    Exit;
  end;
  if (TJSONHelper.ValueType(Result) <> AType) then
  begin
    RaiseTypeException([AType], Name);
  end;
end;

function TJSONObjectReader.ReadSetValue<T>(const Name: String; UseDefault: Boolean; Default: T;
  const EnumStrings: array of String): T;
var
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  A: IJSONArrayReader;
  I: Integer;
begin
  TypeInfo := System.TypeInfo(T);
  Assert(Assigned(TypeInfo),
    'No type-info found for the given generic type');
  Assert(GetTypeKind(T) = tkSet,
    'The generic type "' + TypeInfo^.Name + '" is not a set-type');

  TypeData := System.TypInfo.GetTypeData(TypeInfo);
  TypeInfo := GetTypeData(System.TypeInfo(T))^.CompType^;
  TypeData := System.TypInfo.GetTypeData(TypeInfo);

  if (UseDefault) and (not ValueExists(Name)) then
  begin
    Move(Default, Result, SizeOf(T));
    Exit;
  end;

  A := ReadArray(Name);
  FillChar(Result, SizeOf(T), #0);
  for I := 0 to A.InnerObject.Count - 1 do
  begin
    Include(TGenericSet(Pointer(@Result)^), A.Reader.ReadEnum(TypeInfo, I, EnumStrings));
  end;
end;

function TJSONObjectReader.ReadInteger(const Name: String): Integer;
begin
  Result := TJSONNumber(ReadValue(TJSONType.jsonInteger, Name, false)).AsInt;
end;

function TJSONObjectReader.ReadInteger(const Name: String; Default: Integer): Integer;
var
  V: TJSONNumber;
begin
  V := TJSONNumber(ReadValue(TJSONType.jsonInteger, Name, true));
  if Assigned(V) then
  begin
    Result := V.AsInt;
  end else
  begin
    Result := Default;
  end;
end;

function TJSONObjectReader.ReadInt64(const Name: String): Int64;
begin
  Result := TJSONNumber(ReadValue(TJSONType.jsonInteger, Name, false)).AsInt64;
end;

function TJSONObjectReader.ReadInt64(const Name: String; Default: Int64): Int64;
var
  V: TJSONNumber;
begin
  V := TJSONNumber(ReadValue(TJSONType.jsonInteger, Name, true));
  if Assigned(V) then
  begin
    Result := V.AsInt64;
  end else
  begin
    Result := Default;
  end;
end;

function TJSONObjectReader.ReadDouble(const Name: String): Double;
begin
  Result := TJSONNumber(ReadValue(TJSONType.jsonFloat, Name, false)).AsDouble;
end;

function TJSONObjectReader.ReadDouble(const Name: String; Default: Double): Double;
var
  V: TJSONNumber;
begin
  V := TJSONNumber(ReadValue(TJSONType.jsonFloat, Name, true));
  if Assigned(V) then
  begin
    Result := V.AsDouble;
  end else
  begin
    Result := Default;
  end;
end;

function TJSONObjectReader.ReadString(const Name: String): String;
begin
  Result := TJSONString(ReadValue(TJSONType.jsonString, Name, false)).Value;
end;

function TJSONObjectReader.ReadString(const Name, Default: String): String;
var
  V: TJSONString;
begin
  V := TJSONString(ReadValue(TJSONType.jsonString, Name, true));
  if Assigned(V) then
  begin
    Result := V.Value;
  end else
  begin
    Result := Default;
  end;
end;

function TJSONObjectReader.ReadBoolean(const Name: String): Boolean;
begin
  Result := TJSONBool(ReadValue(TJSONType.jsonBoolean, Name, false)).AsBoolean;
end;

function TJSONObjectReader.ReadBoolean(const Name: String; Default: Boolean): Boolean;
var
  V: TJSONBool;
begin
  V := TJSONBool(ReadValue(TJSONType.jsonBoolean, Name, true));
  if Assigned(V) then
  begin
    Result := V.AsBoolean;
  end else
  begin
    Result := Default;
  end;
end;

function TJSONObjectReader.ReadEnum<T>(const Name: String): T;
var
  I: Integer;
begin
  Assert(SizeOf(Result) <= SizeOf(I));
  I := JSONValueToEnumOrdinal(TypeInfo(T), Name, []);
  Move(I, Result, SizeOf(Result));
end;

function TJSONObjectReader.ReadEnum<T>(const Name: String; const EnumStrings: array of String): T;
var
  I: Integer;
begin
  Assert(SizeOf(Result) <= SizeOf(I));
  I := JSONValueToEnumOrdinal(TypeInfo(T), Name, EnumStrings);
  Move(I, Result, SizeOf(Result));
end;

function TJSONObjectReader.ReadEnum<T>(const Name: String; const Default: T): T;
begin
  if (not ValueExists(Name)) then
  begin
    Result := Default;
  end else
  begin
    Result := ReadEnum<T>(Name);
  end;
end;

function TJSONObjectReader.ReadEnum<T>(const Name: String; const Default: T;
  const EnumStrings: array of String): T;
begin
  if (not ValueExists(Name)) then
  begin
    Result := Default;
  end else
  begin
    Result := ReadEnum<T>(Name, EnumStrings);
  end;
end;

function TJSONObjectReader.ReadSet<T>(const Name: String): T;
begin
  Result := ReadSetValue(Name, false, Default(T), []);
end;

function TJSONObjectReader.ReadSet<T>(const Name: String; const Default: T): T;
begin
  Result := ReadSetValue(Name, true, Default, []);
end;

function TJSONObjectReader.ReadSet<T>(const Name: String; const Default: T;
  const EnumStrings: array of String): T;
begin
  Result := ReadSetValue(Name, true, Default, EnumStrings);
end;

function TJSONObjectReader.ReadSet<T>(const Name: String; const EnumStrings: array of String): T;
begin
  Result := ReadSetValue(Name, false, Default(T), EnumStrings);
end;

function TJSONObjectReader.ReadArray(const Name: String): IJSONArrayReader;
begin
  Result := TJSONArrayReader.Create(TJSONArray(ReadValue(TJSONType.jsonArray, Name, false)),
    Format('%s.%s', [FCurrentPath, Name]));
end;

function TJSONObjectReader.ReadObject(const Name: String): IJSONObjectReader;
begin
  Result := TJSONObjectReader.Create(TJSONObject(ReadValue(TJSONType.jsonObject, Name, false)),
    Format('%s.%s', [FCurrentPath, Name]));
end;

function TJSONObjectReader.ValueType(const Name: String): TJSONType;
begin
  Result := TJSONHelper.ValueType(FJSON.Values[Name]);
end;

function TJSONObjectReader.ValueExists(const Name: String): Boolean;
begin
  Result := Assigned(FJSON.Values[Name]);
end;
{$ENDREGION}

{$REGION 'Class: TJSONArrayWriter'}
constructor TJSONArrayWriter.Create(JSON: TJSONArray);
begin
  inherited Create;
  FJSON := JSON;
end;

function TJSONArrayWriter.GetInnerObject: TJSONArray;
begin
  Result := FJSON;
end;

function TJSONArrayWriter.GetWriter: TJSONArrayWriter;
begin
  Result := Self;
end;

function TJSONArrayWriter.JSONValueFromEnum<T>(Value: T; UseEnumStrings: Boolean;
  const EnumStrings: array of String): TJSONValue;
var
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  V: Integer;
begin
  Assert(SizeOf(V) >= SizeOf(T));
  TypeInfo := System.TypeInfo(T);
  Assert(Assigned(TypeInfo) and (TypeInfo^.Kind = tkEnumeration));
  TypeData := System.TypInfo.GetTypeData(TypeInfo);
  V := 0;
  Move(Value, V, SizeOf(T));
  Assert((V >= TypeData^.MinValue) and (V <= TypeData^.MaxValue));
  if UseEnumStrings then
  begin
    if (Length(EnumStrings) = 0) then
    begin
      Result := TJSONString.Create(System.TypInfo.GetEnumName(TypeInfo, V));
    end else
    begin
      Assert(High(EnumStrings) = TypeData^.MaxValue);
      Result := TJSONString.Create(EnumStrings[V]);
    end;
  end else
  begin
    Result := TJSONNumber.Create(V);
  end;
end;

function TJSONArrayWriter.JSONValueFromSet<T>(Value: T; UseEnumStrings: Boolean;
  const EnumStrings: array of String): TJSONArray;
var
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  I: Integer;
begin
  Assert(SizeOf(I) >= SizeOf(T));
  TypeInfo := System.TypeInfo(T);
  Assert(Assigned(TypeInfo) and (TypeInfo^.Kind = tkSet));
  TypeInfo := GetTypeData(TypeInfo)^.CompType^;
  TypeData := GetTypeData(TypeInfo);
  Assert((Length(EnumStrings) = 0) or (High(EnumStrings) = TypeData^.MaxValue));
  Result := TJSONArray.Create;
  for I := TypeData^.MinValue to TypeData^.MaxValue do
  begin
    if (I in TGenericSet(Pointer(@Value)^)) then
    begin
      if (UseEnumStrings) then
      begin
        if (Length(EnumStrings) = 0) then
        begin
          Result.AddElement(TJSONString.Create(System.TypInfo.GetEnumName(TypeInfo, I)));
        end else
        begin
          Result.AddElement(TJSONString.Create(EnumStrings[I]));
        end;
      end else
      begin
        Result.AddElement(TJSONNumber.Create(I));
      end;
    end;
  end;
end;

procedure TJSONArrayWriter.AddInteger(Value: Integer);
begin
  FJSON.AddElement(TJSONNumber.Create(Value));
end;

procedure TJSONArrayWriter.AddInt64(Value: Int64);
begin
  FJSON.AddElement(TJSONNumber.Create(Value));
end;

procedure TJSONArrayWriter.AddDouble(Value: Double);
begin
  FJSON.AddElement(TJSONNumber.Create(Value));
end;

procedure TJSONArrayWriter.AddString(const Value: String);
begin
  FJSON.AddElement(TJSONString.Create(Value));
end;

procedure TJSONArrayWriter.AddBoolean(Value: Boolean);
begin
  FJSON.AddElement(TJSONBool.Create(Value));
end;

procedure TJSONArrayWriter.AddEnum<T>(Value: T; UseEnumStrings: Boolean);
begin
  FJSON.AddElement(JSONValueFromEnum(Value, UseEnumStrings, []));
end;

procedure TJSONArrayWriter.AddEnum<T>(Value: T; const EnumStrings: array of String);
begin
  FJSON.AddElement(JSONValueFromEnum(Value, true, EnumStrings));
end;

procedure TJSONArrayWriter.AddSet<T>(Value: T; UseEnumStrings: Boolean);
begin
  FJSON.AddElement(JSONValueFromSet(Value, UseEnumStrings, []));
end;

procedure TJSONArrayWriter.AddSet<T>(Value: T; const EnumStrings: array of String);
begin
  FJSON.AddElement(JSONValueFromSet(Value, true, EnumStrings));
end;

procedure TJSONArrayWriter.AddNull;
begin
  FJSON.AddElement(TJSONNull.Create);
end;

function TJSONArrayWriter.AddArray: IJSONArrayWriter;
var
  V: TJSONArray;
begin
  V := TJSONArray.Create;
  FJSON.AddElement(V);
  Result := TJSONArrayWriter.Create(V);
end;

procedure TJSONArrayWriter.AddArray(WriteFunc: TJSONCondWriteArrayFunc);
var
  V: TJSONArray;
  W: IJSONArrayWriter;
begin
  V := TJSONArray.Create;
  W := TJSONArrayWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddElement(V);
  end else
  begin
    V.Free;
  end;
end;

procedure TJSONArrayWriter.AddArrayOrNull(WriteFunc: TJSONCondWriteArrayFunc);
var
  V: TJSONArray;
  W: IJSONArrayWriter;
begin
  V := TJSONArray.Create;
  W := TJSONArrayWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddElement(V);
  end else
  begin
    AddNull;
    V.Free;
  end;
end;

function TJSONArrayWriter.AddObject: IJSONObjectWriter;
var
  V: TJSONObject;
begin
  V := TJSONObject.Create;
  FJSON.AddElement(V);
  Result := TJSONObjectWriter.Create(V);
end;

procedure TJSONArrayWriter.AddObject(WriteFunc: TJSONCondWriteObjectFunc);
var
  V: TJSONObject;
  W: IJSONObjectWriter;
begin
  V := TJSONObject.Create;
  W := TJSONObjectWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddElement(V);
  end else
  begin
    V.Free;
  end;
end;

procedure TJSONArrayWriter.AddObjectOrNull(WriteFunc: TJSONCondWriteObjectFunc);
var
  V: TJSONObject;
  W: IJSONObjectWriter;
begin
  V := TJSONObject.Create;
  W := TJSONObjectWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddElement(V);
  end else
  begin
    AddNull;
    V.Free;
  end;
end;

procedure TJSONArrayWriter.Remove(Index: Integer);
begin
  FJSON.Remove(Index);
end;
{$ENDREGION}

{$REGION 'Class: TJSONObjectWriter'}
constructor TJSONObjectWriter.Create(JSON: TJSONObject);
begin
  inherited Create;
  FJSON := JSON;
end;

function TJSONObjectWriter.GetInnerObject: TJSONObject;
begin
  Result := FJSON;
end;

function TJSONObjectWriter.GetWriter: TJSONObjectWriter;
begin
  Result := Self;
end;

function TJSONObjectWriter.JSONValueFromEnum<T>(Value: T; UseEnumStrings: Boolean;
  const EnumStrings: array of String): TJSONValue;
var
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  V: Integer;
begin
  Assert(SizeOf(V) >= SizeOf(T));
  TypeInfo := System.TypeInfo(T);
  Assert(Assigned(TypeInfo) and (TypeInfo^.Kind = tkEnumeration));
  TypeData := System.TypInfo.GetTypeData(TypeInfo);
  V := 0;
  Move(Value, V, SizeOf(T));
  Assert((V >= TypeData^.MinValue) and (V <= TypeData^.MaxValue));
  if UseEnumStrings then
  begin
    if (Length(EnumStrings) = 0) then
    begin
      Result := TJSONString.Create(System.TypInfo.GetEnumName(TypeInfo, V));
    end else
    begin
      Assert(High(EnumStrings) = TypeData^.MaxValue);
      Result := TJSONString.Create(EnumStrings[V]);
    end;
  end else
  begin
    Result := TJSONNumber.Create(V);
  end;
end;

function TJSONObjectWriter.JSONValueFromSet<T>(Value: T; UseEnumStrings: Boolean;
  const EnumStrings: array of String): TJSONArray;
var
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  I: Integer;
begin
  Assert(SizeOf(I) >= SizeOf(T));
  TypeInfo := System.TypeInfo(T);
  Assert(Assigned(TypeInfo) and (TypeInfo^.Kind = tkSet));
  TypeInfo := GetTypeData(TypeInfo)^.CompType^;
  TypeData := GetTypeData(TypeInfo);
  Assert((Length(EnumStrings) = 0) or (High(EnumStrings) = TypeData^.MaxValue));
  Result := TJSONArray.Create;
  for I := TypeData^.MinValue to TypeData^.MaxValue do
  begin
    if (I in TGenericSet(Pointer(@Value)^)) then
    begin
      if (UseEnumStrings) then
      begin
        if (Length(EnumStrings) = 0) then
        begin
          Result.AddElement(TJSONString.Create(System.TypInfo.GetEnumName(TypeInfo, I)));
        end else
        begin
          Result.AddElement(TJSONString.Create(EnumStrings[I]));
        end;
      end else
      begin
        Result.AddElement(TJSONNumber.Create(I));
      end;
    end;
  end;
end;

procedure TJSONObjectWriter.WriteInteger(const Name: String; Value: Integer);
begin
  FJSON.AddPair(Name, TJSONNumber.Create(Value));
end;

procedure TJSONObjectWriter.WriteInt64(const Name: String; Value: Int64);
begin
  FJSON.AddPair(Name, TJSONNumber.Create(Value));
end;

procedure TJSONObjectWriter.WriteDouble(const Name: String; Value: Double);
begin
  FJSON.AddPair(Name, TJSONNumber.Create(Value));
end;

procedure TJSONObjectWriter.WriteString(const Name, Value: String);
begin
  FJSON.AddPair(Name, TJSONString.Create(Value));
end;

procedure TJSONObjectWriter.WriteBoolean(const Name: String; Value: Boolean);
begin
  FJSON.AddPair(Name, TJSONBool.Create(Value));
end;

procedure TJSONObjectWriter.WriteEnum<T>(const Name: String; Value: T; UseEnumStrings: Boolean);
begin
  FJSON.AddPair(Name, JSONValueFromEnum(Value, UseEnumStrings, []));
end;

procedure TJSONObjectWriter.WriteEnum<T>(const Name: String; Value: T;
  const EnumStrings: array of String);
begin
  FJSON.AddPair(Name, JSONValueFromEnum(Value, true, EnumStrings));
end;

procedure TJSONObjectWriter.WriteSet<T>(const Name: String; Value: T; UseEnumStrings: Boolean);
begin
  FJSON.AddPair(Name, JSONValueFromSet(Value, UseEnumStrings, []));
end;

procedure TJSONObjectWriter.WriteSet<T>(const Name: String; Value: T;
  const EnumStrings: array of String);
begin
  FJSON.AddPair(Name, JSONValueFromSet(Value, true, EnumStrings));
end;

procedure TJSONObjectWriter.WriteNull(const Name: String);
begin
  FJSON.AddPair(Name, TJSONNull.Create);
end;

function TJSONObjectWriter.WriteArray(const Name: String): IJSONArrayWriter;
var
  V: TJSONArray;
begin
  V := TJSONArray.Create;
  FJSON.AddPair(Name, V);
  Result := TJSONArrayWriter.Create(V);
end;

procedure TJSONObjectWriter.WriteArray(const Name: String; WriteFunc: TJSONCondWriteArrayFunc);
var
  V: TJSONArray;
  W: IJSONArrayWriter;
begin
  V := TJSONArray.Create;
  W := TJSONArrayWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddPair(Name, V);
  end else
  begin
    V.Free;
  end;
end;

procedure TJSONObjectWriter.WriteArrayOrNull(const Name: String;
  WriteFunc: TJSONCondWriteArrayFunc);
var
  V: TJSONArray;
  W: IJSONArrayWriter;
begin
  V := TJSONArray.Create;
  W := TJSONArrayWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddPair(Name, V);
  end else
  begin
    WriteNull(Name);
    V.Free;
  end;
end;

function TJSONObjectWriter.WriteObject(const Name: String): IJSONObjectWriter;
var
  V: TJSONObject;
begin
  V := TJSONObject.Create;
  FJSON.AddPair(Name, V);
  Result := TJSONObjectWriter.Create(V);
end;

procedure TJSONObjectWriter.WriteObject(const Name: String; WriteFunc: TJSONCondWriteObjectFunc);
var
  V: TJSONObject;
  W: IJSONObjectWriter;
begin
  V := TJSONObject.Create;
  W := TJSONObjectWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddPair(Name, V);
  end else
  begin
    V.Free;
  end;
end;

procedure TJSONObjectWriter.WriteObjectOrNull(const Name: String;
  WriteFunc: TJSONCondWriteObjectFunc);
var
  V: TJSONObject;
  W: IJSONObjectWriter;
begin
  V := TJSONObject.Create;
  W := TJSONObjectWriter.Create(V);
  if (WriteFunc(W.Writer)) then
  begin
    FJSON.AddPair(Name, V);
  end else
  begin
    WriteNull(Name);
    V.Free;
  end;
end;

procedure TJSONObjectWriter.Remove(const Name: String);
begin
  FJSON.RemovePair(Name);
end;
{$ENDREGION}

{$REGION 'Class: TJSONFormatter'}
class procedure TJSONFormatter.Format(Builder: TStringBuilder; const JSON: TJSONValue;
  PrettyPrint: Boolean; Indent, InitialIndent: Integer);
var
  S1, S2: String;
  I: Integer;
begin
  if (PrettyPrint) then
  begin
    SetLength(S1, Indent);
    for I := 1 to Indent do
    begin
      S1[I] := ' ';
    end;
    SetLength(S2, InitialIndent);
    for I := 1 to InitialIndent do
    begin
      S2[I] := ' ';
    end;
    FormatPretty(Builder, JSON, S1, S2);
  end else
  begin
    FormatCompact(Builder, JSON);
  end;
end;

class function TJSONFormatter.Format(const JSON: TJSONValue; PrettyPrint: Boolean;
  Indent: Integer; InitialIndent: Integer): String;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Format(Builder, JSON, PrettyPrint, Indent, InitialIndent);
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class procedure TJSONFormatter.FormatCompact(Builder: TStringBuilder; const JSON: TJSONValue);
var
  I: Integer;
  V: TJSONValue;
  P: TJSONPair;
begin
  case TJSONHelper.ValueType(JSON) of
    TJSONType.jsonArray:
      begin
        Builder.Append('[');
        for I := 0 to TJSONArray(JSON).Count - 1 do
        begin
          V := TJSONArray(JSON).Items[I];
          if (TJSONHelper.ValueType(V) in [TJSONType.jsonArray, TJSONType.jsonObject]) then
          begin
            FormatCompact(Builder, V);
          end else
          begin
            FormatValue(Builder, V);
          end;
          if (I <> TJSONArray(JSON).Count - 1) then
          begin
            Builder.Append(',');
          end;
        end;
        Builder.Append(']');
      end;
    TJSONType.jsonObject:
      begin
        Builder.Append('{');
        for I := 0 to TJSONObject(JSON).Count - 1 do
        begin
          P := TJSONObject(JSON).Pairs[I];
          Builder.Append(P.JSONString.ToString);
          Builder.Append(':');
          if (TJSONHelper.ValueType(P.JsonValue) in
            [TJSONType.jsonArray, TJSONType.jsonObject]) then
          begin
            FormatCompact(Builder, P.JsonValue);
          end else
          begin
            FormatValue(Builder, P.JsonValue);
          end;
          if (I <> TJSONObject(JSON).Count - 1) then
          begin
            Builder.Append(',');
          end;
        end;
        Builder.Append('}');
      end else
      begin
        FormatValue(Builder, JSON);
      end;
  end;
end;

class procedure TJSONFormatter.FormatPretty(Builder: TStringBuilder; const JSON: TJSONValue;
  const Indent, CurrentIndent: String);
var
  I: Integer;
  V: TJSONValue;
  P: TJSONPair;
begin
  case TJSONHelper.ValueType(JSON) of
    TJSONType.jsonArray:
      begin
        Builder.AppendLine('[');
        for I := 0 to TJSONArray(JSON).Count - 1 do
        begin
          V := TJSONArray(JSON).Items[I];
          if (TJSONHelper.ValueType(V) in [TJSONType.jsonArray, TJSONType.jsonObject]) then
          begin
            Builder.Append(CurrentIndent + Indent);
            FormatPretty(Builder, V, Indent, CurrentIndent + Indent);
          end else
          begin
            Builder.Append(CurrentIndent + Indent);
            FormatValue(Builder, V);
          end;
          if (I = TJSONArray(JSON).Count - 1) then
          begin
            Builder.AppendLine('');
          end else
          begin
            Builder.AppendLine(',');
          end;
        end;
        Builder.Append(CurrentIndent + ']');
      end;
    TJSONType.jsonObject:
      begin
        Builder.AppendLine('{');
        for I := 0 to TJSONObject(JSON).Count - 1 do
        begin
          P := TJSONObject(JSON).Pairs[I];
          Builder.Append(CurrentIndent + Indent);
          Builder.Append(P.JSONString.ToString);
          Builder.Append(': ');
          if (TJSONHelper.ValueType(P.JsonValue) in
            [TJSONType.jsonArray, TJSONType.jsonObject]) then
          begin
            FormatPretty(Builder, P.JSONValue, Indent, CurrentIndent + Indent);
          end else
          begin
            FormatValue(Builder, P.JSONValue);
          end;
          if (I = TJSONObject(JSON).Count - 1) then
          begin
            Builder.AppendLine('');
          end else
          begin
            Builder.AppendLine(',');
          end;
        end;
        Builder.Append(CurrentIndent + '}');
      end else
      begin
        FormatValue(Builder, JSON);
      end;
  end;
end;

class procedure TJSONFormatter.FormatValue(Builder: TStringBuilder; const JSON: TJSONValue);
begin
  case TJSONHelper.ValueType(JSON) of
    TJSONType.jsonInteger : Builder.Append(TJSONNumber(JSON).AsInt64);
    TJSONType.jsonFloat   : Builder.Append(FloatToJson(TJSONNumber(JSON).AsDouble));
    TJSONType.jsonString  : Builder.Append('"' + TJSONString(JSON).Value + '"');
    TJSONType.jsonBoolean : Builder.Append(LowerCase(BoolToStr(TJSONBool(JSON).AsBoolean, true)));
    TJSONType.jsonNull    : Builder.Append('null');
  end;
end;
{$ENDREGION}

end.
