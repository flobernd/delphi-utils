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

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"b"}       {"a":null}      {}
	procedure MergePatch_RemovesNullValues1();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"b",       {"a":null}      {"b":"c"}
	//    "b":"c"}
	procedure MergePatch_RemovesNullValues2();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a": {         {"a": {         {"a": {
	//     "b": "c"}       "b": "d",       "b": "d"
	//   }                 "c": null}      }
	//                   }               }
	procedure MergePatch_RemoveSomethingThatDoesNotExist();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"foo"}     null            null
	procedure MergePatch_RemovesEverything();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"b"}       {"a":"c"}       {"a":"c"}
	procedure MergePatch_ReplacesValue();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":["b"]}     {"a":"c"}       {"a":"c"}
	procedure MergePatch_ReplacesArray();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"c"}       {"a":["b"}}       {"a":["b"]}
	procedure MergePatch_ReplacesValueWithArray();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"b"}       {"b":"c"}       {"a":"b",
	//                                    "b":"c"}
	procedure MergePatch_AddsPair();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   ["a","b"]       ["c","d"]       ["c","d"]
	procedure MergePath_ReplacesArrayWithOtherArray();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"b"}       ["c"]           ["c"]
	procedure MergePath_ReplacesObjectWithArray();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   [1,2]           {"a":"b",       {"a":"b"}
	//                    "c":null}
	procedure MergePath_ReplacesArrayWithObject();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a":"foo"}     "bar"           "bar"
	procedure MergePatch_ReplacesObjectWithString();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"a": [         {"a": [1]}      {"a": [1]}
	//     {"b":"c"}
	//    ]
	//   }
	procedure MergePatch_ReplacesArrayWithArray();

	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {"e":null}      {"a":1}         {"e":null,
	//                                    "a":1}
	procedure MergePatch_AddsPair_ExistingNullValue();
	//   ORIGINAL        PATCH            RESULT
	//   ------------------------------------------
	//   {}              {"a":            {"a":
	//                    {"bb":           {"bb":
	//                     {"ccc":          {}}}
	//					  null}}}
	procedure MergePatch_RemovesSomethingThatDoesNotExist2();
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

procedure TestTJsonHelper.MergePatch_AddsPair();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":"b"}');
		patch := TJSONObject.ParseJSONValue('{"b": "c"}');
		result := TJSONHelper.MergePatch(target, patch);
		Check(result <> patch, 'result <> patch');
		Check(result <> target, 'result <> target');
		Check(result is TJSONObject, 'result is TJSONObject');
		//   {"a":"b"}       {"b":"c"}       {"a":"b",
		//                                    "b":"c"}

		CheckEquals(2, (result as TJsonObject).Count, 'result.count');
		CheckEqualsString('b', (result as TJsonObject).GetValue<String>('a'), 'a');
		CheckEqualsString('c', (result as TJsonObject).GetValue<String>('b'), 'b');
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_AddsPair_ExistingNullValue();
var
	target, patch: TJsonValue;
	result: TJsonValue;
	resultObj: TJsonObject;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"e":null}');
		patch := TJSONObject.ParseJSONValue('{"a":1}');
		result := TJSONHelper.MergePatch(target, patch);
		Check(result <> patch, 'result <> patch');
		Check(result <> target, 'result <> target');
		Check(result is TJsonObject, 'result is object');
		resultObj := (result as TJsonObject);

		CheckEquals(2, resultObj.Count, 'obj.count');
		Check(resultObj.GetValue('e').Null, 'obj.e is null');
		CheckEquals(1, resultObj.GetValue<Integer>('a'));
		//   {"e":null}      {"a":1}         {"e":null,
		//                                    "a":1}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_RemovesEverything();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":"foo"}');
		patch := TJSONObject.ParseJSONValue('null');
		result := TJSONHelper.MergePatch(target, patch);
		Check(result <> patch, 'result <> patch');
		Check(result <> target, 'result <> target');
		Check(result is TJSONNull, 'result is TJSONNull');
		//   {"a":"foo"}     null            null
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_RemovesNullValues1();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":"b"}') as TJsonObject;
		patch := TJSONObject.ParseJSONValue('{"a":null}') as TJsonObject;
		result := TJSONHelper.MergePatch(target, patch);
		Check(result <> patch, 'result <> patch');
		Check(result <> target, 'result <> target');
		Check(result is TJsonObject, 'result is TJsonObject');
		CheckEquals(0, (result as TJsonObject).Count);
		//{"a":"b"}       {"a":null}      {}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_RemovesNullValues2();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":"b", "b":"c"}') as TJsonObject;
		patch := TJSONObject.ParseJSONValue('{"a":null}') as TJsonObject;
		result := TJSONHelper.MergePatch(target, patch);
		Check(result <> patch);
		Check(result <> target);
		Check(result is TJsonObject);
		CheckEquals(1, (result as TJsonObject).Count);
		Check((result as TJsonObject).GetValue<String>('b') = 'c');
		//{"a":"b", "b": "c"}       {"a":null}      {"b": "c"}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_RemoveSomethingThatDoesNotExist();
var
	target, patch: TJsonValue;
	result: TJsonValue;
	obj: TJsonObject;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":{"b": "c"}}') as TJsonObject;
		patch := TJSONObject.ParseJSONValue('{"a":{"b": "d", "c": null}}') as TJsonObject;
		result := TJSONHelper.MergePatch(target, patch);

		Check(result <> patch); Check(result <> target);
		Check(result is TJsonObject);
		CheckEquals(1, (result as TJsonObject).Count);

		obj := (result as TJSONObject).GetValue<TJSONObject>('a');
		CheckNotNull(obj);
		CheckEquals(1, obj.Count);
		CheckEqualsString('d', obj.GetValue<String>('b'));

		// {"a": {         {"a": {         {"a": {
		//     "b": "c"}       "b": "d",       "b": "d"
		//   }                 "c": null}      }
		//				   }               }

	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_RemovesSomethingThatDoesNotExist2;
var
	target, patch: TJsonValue;
	expected: TJsonObject;
	actual: TJsonValue;
begin
	target := nil; patch := nil; expected := nil; actual := nil;
	try
		target := TJSONObject.Create();
		patch := TJSONObject.ParseJSONValue('{"a": {"bb": {"ccc": null}}}');

		expected := TJsonObject.ParseJSONValue('{"a": {"bb": {}}}') as TJsonObject;
		actual := TJSONHelper.MergePatch(target, patch);

		CheckIs(actual, TJsonObject);
		Check( TJSONHelper.Equals(expected, actual) );

		//   {}              {"a":            {"a":
		//                    {"bb":           {"bb":
		//                     {"ccc":          {}}}
		//					  null}}}
	finally
		target.Free(); patch.Free();
		expected.Free(); actual.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_ReplacesArray();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":["b"]}') as TJsonObject;
		patch := TJSONObject.ParseJSONValue('{"a": "c"}') as TJsonObject;
		result := TJSONHelper.MergePatch(target, patch);

		Check(target <> patch);
		Check(result is TJsonObject);
		CheckEquals(1, (result as TJsonObject).Count);
		CheckEqualsString('c', (result as TJsonObject).GetValue<String>('a'));
		//   {"a":["b"]}     {"a":"c"}       {"a":"c"}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_ReplacesArrayWithArray;
var
	target, patch: TJsonValue;
	result: TJsonValue;
	arr: TJsonArray;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a": [{"b":"c"}]}');
		patch := TJsonObject.ParseJSONValue('{"a": [1]}');
		result := TJsonHelper.MergePatch(target, patch);

		Check(result <> patch); Check(result <> target);
		Check(result is TJSONObject);
		CheckEquals(1, (result as TJSONObject).Count, 'object.count');
		CheckIs((result as TJsonObject).GetValue('a'), TJSONArray, 'a is array');
		arr := (result as TJsonObject).GetValue('a') as TJsonArray;
		CheckEquals(1, arr.Count, 'array.count');
		CheckEquals(1, arr.Items[0].GetValue<Integer>(), 'array[0]');

		//   {"a": [         {"a": [1]}      {"a": [1]}
		//     {"b":"c"}
		//    ]}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_ReplacesObjectWithString();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":"foo"}') as TJsonObject;
		patch := TJSONObject.ParseJSONValue('"bar"') as TJSONString;
		result := TJSONHelper.MergePatch(target, patch);

		Check(result <> patch);
		Check(result is TJSONString);
		CheckEqualsString('bar', (result as TJSONString).Value());
		//   {"a":"foo"}     "bar"           "bar"
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_ReplacesValue();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":"b"}') as TJsonObject;
		patch := TJSONObject.ParseJSONValue('{"a": "c"}') as TJsonObject;
		result := TJSONHelper.MergePatch(target, patch);

		Check(result <> patch); Check(result <> target);
		Check(result is TJsonObject);
		CheckEquals(1, (result as TJsonObject).Count);
		CheckEqualsString('c', (result as TJsonObject).GetValue<String>('a'));
		//   {"a":"b"}       {"a":"c"}       {"a":"c"}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePatch_ReplacesValueWithArray();
var
	target, patch: TJsonValue;
	result: TJsonValue;
	arr: TJsonArray;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a":"c"}');
		patch := TJSONObject.ParseJSONValue('{"a": ["b"]}');
		result := TJSONHelper.MergePatch(target, patch);

		Check(result <> patch); Check(result <> target);
		Check(result is TJsonObject);
		CheckEquals(1, (result as TJsonObject).Count);
		CheckIs((result as TJsonObject).Values['a'], TJSONArray, 'a is array');
		arr := (result as TJsonObject).Values['a'] as TJSONArray;
		CheckEquals(1, arr.Count, 'array.count');
		CheckIs(arr.Items[0], TJsonString);
		CheckEqualsString('b', arr.Items[0].GetValue<String>());
		//   {"a":"c"}       {"a":["b"}}       {"a":["b"]}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePath_ReplacesArrayWithObject();
var
	target, patch: TJsonValue;
	result: TJsonValue;

begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('[1,2]');
		patch := TJSONObject.ParseJSONValue('{"a": "b", "c": null}');
		result := TJSONHelper.MergePatch(target, patch);

		Check(result <> patch); Check(result <> target);
		Check(result is TJsonObject, 'result is object');
		CheckEquals(1, (result as TJsonObject).Count, 'object.count');
		CheckEqualsString('b', (result as TJSONObject).GetValue<String>('a'));
		//   [1,2]           {"a":"b",       {"a":"b"}
		//                    "c":null}
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePath_ReplacesArrayWithOtherArray();
var
	target, patch: TJsonValue;
	result: TJsonValue;
	arr: TJsonArray;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('["a","b"]');
		patch := TJSONObject.ParseJSONValue('["c","d"]');
		result := TJSONHelper.MergePatch(target, patch);

		Check(result <> patch); Check(result <> target);
		Check(result is TJSONArray, 'result is array');
		arr := (result as TJSONArray);

		CheckEquals(2, arr.Count, 'array.count');
		CheckEqualsString('c', arr.Items[0].GetValue<String>());
		CheckEqualsString('d', arr.Items[1].GetValue<String>());
		//   ["a","b"]       ["c","d"]       ["c","d"]
	finally
		target.Free(); patch.Free(); result.Free();
	end;
end;

procedure TestTJsonHelper.MergePath_ReplacesObjectWithArray();
var
	target, patch: TJsonValue;
	result: TJsonValue;
begin
	target := nil; patch := nil; result := nil;
	try
		target := TJSONObject.ParseJSONValue('{"a": "b"}');
		patch := TJSONObject.ParseJSONValue('["c"]');
		result := TJSONHelper.MergePatch(target, patch);

		Check(result <> patch);
		Check(result is TJSONArray);
		CheckEquals(1, (result as TJSONArray).Count, 'array.count');
		CheckEqualsString('c', (result as TJsonArray).Items[0].GetValue<String>());
		//   {"a":"b"}       ["c"]           ["c"]
	finally
		target.Free(); patch.Free(); result.Free();
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
