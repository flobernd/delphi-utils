unit Utils.JSON.Test;

interface uses TestFramework, Utils.JSON;

type
  TestTJsonHelper = class(TTestCase)
  protected
    procedure SetUp(); override;
    procedure TearDown(); override;
  published
    procedure ReturnsFalseWhenEitherIsNil();
    procedure ReturnsTrueOnBothNil();
    procedure NullEqualsNull();
    procedure BooleanEquals();
    procedure FloatEquals();
    procedure ArrayEquals_Integer();
    procedure ObjectEquals_TextField();
    procedure ObjectEquals_DifferentOrder();
    procedure ObjectEquals_NestedObject();
  end;

implementation uses System.Json, System.Json.Builders, System.Json.Writers, System.SysUtils;

procedure TestTJsonHelper.SetUp();
begin
  // do nothing
end;

procedure TestTJsonHelper.TearDown();
begin
  // do nothing
end;

procedure TestTJsonHelper.ReturnsFalseWhenEitherIsNil();
var
  x: TJSONValue;
begin
  x := TJSONNumber.Create(42);
  try
    CheckFalse( TJSONHelper.Equals(nil, x) );
    CheckFalse( TJSONHelper.Equals(x, nil) );
  finally
    x.Destroy();
  end;
end;

procedure TestTJsonHelper.ReturnsTrueOnBothNil();
begin
  Check( TJSONHelper.Equals(nil, nil) );
end;

procedure TestTJsonHelper.NullEqualsNull();
var
  a, b: TJSONValue;
begin
  a := nil; b := nil;
  try
    a := TJSONNull.Create();
    b := TJSONNull.Create();

    Check( TJSONHelper.Equals(a, a) );
    Check( TJSONHelper.Equals(a, b) );
  finally
    a.Free(); b.Free();
  end;
end;

procedure TestTJsonHelper.BooleanEquals();
var
  a, b, c: TJSONBool;
begin
  a := nil; b:= nil; c:= nil;
  try
    a := TJSONBool.Create(True);
    b := TJSONBool.Create(True);

    Check( TJSONHelper.Equals(a, b) );

    c := TJsonBool.Create(False);
    CheckFalse( TJSONHelper.Equals(a, c) );
    Check( TJSONHelper.Equals(c, c) );
  finally
    a.Free(); b.Free(); c.Free();
  end;
end;

procedure TestTJsonHelper.FloatEquals();
const
  value_1 = 3.14159265;
  value_2 = 3.141;
var
  a, b, c: TJSONNumber;
begin
  a := nil; b := nil; c := nil;
  try
    a := TJSONNumber.Create(value_1);
    b := TJSONNumber.Create(value_1);
    c := TJSONNumber.Create(value_2);

    Check( TJSONHelper.Equals(a, b) );
    CheckFalse( TJSONHelper.Equals(a, c) );
  finally
    a.Free(); b.Free(); c.Free();
  end;
end;

procedure TestTJsonHelper.ArrayEquals_Integer();
var
  a, b: TJSONArray;
begin
  a := nil; b := nil;
  try
    a := TJSONArray.Create();
    a.Add(1).Add(10).Add(100).Add(Integer.MaxValue);

    b := TJSONArray.Create();
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.Add(1).Add(10).Add(100);
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.Add(Integer.MaxValue);
    Check( TJSONHelper.Equals(a, b) );

    a.Remove(0).Free();
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.Remove(0).Free();
    Check( TJSONHelper.Equals(a, b) );

    b.Destroy(); b := (a.Clone() as TJSONArray);
    Check( TJSONHelper.Equals(a, b) );
  finally
    a.Free(); b.Free();
  end;
end;

procedure TestTJsonHelper.ObjectEquals_TextField();
var
  a, b: TJSONObject;
begin
  a := nil; b := nil;
  try
    a := TJSONObject.Create();
    b := TJSONObject.Create();
    Check( TJSONHelper.Equals(a, b) );

    a.AddPair('someText', 'Hello World');
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.AddPair('SOMETEXT', 'Hello World');
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.AddPair('SomeText', 'Hello World');
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.AddPair('someText', 'HELLO WORLD');
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.RemovePair('someText').Free();
    b.RemovePair('SomeText').Free();
    b.RemovePair('SOMETEXT').Free();
    b.AddPair('someText', 'Hello World');
    Check( TJSONHelper.Equals(a, b) );

    a.RemovePair('someText').Free();
    CheckFalse( TJSONHelper.Equals(a, b) );

    b.RemovePair('someText').Free();
    Check( TJSONHelper.Equals(a, b) );
  finally
    a.Free(); b.Free();
    end;
end;

procedure TestTJsonHelper.ObjectEquals_DifferentOrder();
var
  a, b: TJSONObject;
begin
  a := nil; b := nil;
  try
    a := TJSONObject.Create();
    a.AddPair('someNumber', '42');
    a.AddPair('someText', 'Hello World');

    b := TJSONObject.Create();
    b.AddPair('someText', 'Hello World');
    b.AddPair('someNumber', '42');

    Check( TJSONHelper.Equals(a, b) );
  finally
    a.Free(); b.Free();
  end;
end;

procedure TestTJsonHelper.ObjectEquals_NestedObject();
var
  builder:  TJSONObjectBuilder;
  writer:    TJSONObjectWriter;
  a, b:    TJSONObject;
begin
  {$REGION 'build object a'}
  writer := nil; builder := nil;
  try
    writer := TJSONObjectWriter.Create(False);
    builder := TJSONObjectBuilder.Create(writer);

    builder
      .BeginObject()
        .Add('someText', 'Hello World')
        .BeginArray('numbersFromOneToFive')
          .Add(1).Add(2).Add(3).Add(4).Add(5)
        .EndArray()
        .Add('theNumberPi', Pi())
        .BeginObject('theInnerObject')
          .Add('whatIsThis', 'itIsTheInnerObject')
          .AddNull('innerNullValue')
          .Add('andWhatIsThis', 'itIsTheEndOfTheInnerObject')
        .EndObject()
        .AddNull('someNullValue')
      .EndObject();

    a := (writer.JSON as TJsonObject);
  finally
    builder.Free(); writer.Free();
  end;
  {$ENDREGION 'build object a'}

  {$REGION 'build object b'}
  writer := nil; builder := nil;
  try
    writer := TJSONObjectWriter.Create(False);
    builder := TJSONObjectBuilder.Create(writer);

    builder
      .BeginObject()
        .Add('theNumberPi', Pi())
        .Add('someText', 'Hello World')
        .BeginArray('numbersFromOneToFive')
          .Add(1).Add(2).Add(3).Add(4).Add(5)
        .EndArray()
        .AddNull('someNullValue')
        .BeginObject('theInnerObject')
          .AddNull('innerNullValue')
          .Add('whatIsThis', 'itIsTheInnerObject')
          .Add('andWhatIsThis', 'itIsTheEndOfTheInnerObject')
        .EndObject()
      .EndObject();

    b := (writer.JSON as TJsonObject);
  finally
    builder.Free(); writer.Free();
  end;
  {$ENDREGION 'build object b'}

  try
    Check( TJSONHelper.Equals(a, b) );
  finally
    a.Destroy(); b.Destroy();
  end;
end;

initialization
  TestFramework.RegisterTest( TestTJSONHelper.Suite() );
end.
