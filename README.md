# JSON Utils
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Various helper classes- and functions for the JSON Objects Framework (System.JSON)

## Features ##
### General ####
- Misc helper functions

### Formatting
- Default formatting
- Pretty-print formatting with custom indentation settings

### IJSONArrayReader and IJSONObjectReader
Encapsulates ```System.JSON.TJSONArray``` respectively ```System.JSON.TJSONObject``` and provides methods for strong-typed reading.
- Automatically keeps track of the current path and raises a meaningfull exception, if the accessed element's type did not match
- Reads trivial JSON types (```Integer```, ```Int64```, ```Double```, ```String```, ```Boolean```)
- Reads complex JSON types (```Array```, ```Object```)
  - Returns a new ```IJSONArrayReader``` or ```IJSONObjectReader``` for chained reading
- Reads generic types (```Enum<T>```, ```Set<T>```)
- Supports default values (returns default-value if the accessed element does not exists, instead of raising an exception)
 
### IJSONArrayWriter and IJSONObjectWriter
Encapsulates ```System.JSON.TJSONArray``` respectively ```System.JSON.TJSONObject``` and provides methods for strong-typed writing.
- Writes trivial JSON types (```Integer```, ```Int64```, ```Double```, ```String```, ```Boolean```, ```Null```)
- Writes complex JSON types (```Array```, ```Object```)
  - Returns a new ```IJSONArrayWriter``` or ```IJSONObjectWriter``` for chained writing
- Writes generic types (```Enum<T>```, ```Set<T>```)
- Supports conditional writes using anonymous functions
  - Conditional ```AddArray```, ```WriteArray```, ```AddObject```, ```WriteObject```
  - Conditional ```AddArrayOrNull```, ```WriteArrayOrNull```, ```AddObjectOrNull```, ```WriteObjectOrNull```
 
## Examples ##
### Reader ###
```pascal
var
  S: String;
  J: TJSONObject;
  R: IJSONObjectReader;
begin
  S := '{'
    + '  "number": 42,'
    + '  "object": {'
    + '    "bool": true'
    + '  },'
    + '  "array": ['
    + '    { "str": "Hello" },'
    + '    { "str": "World" }'
    + '  ],'
    + '  "set": [1, 3]'
    + '}';

  J := TJSONObject.ParseJSONValue(S) as TJSONObject;
  try
    R := TJSONObjectReader.Create(J);

    // 42
    ShowMessage(R.ReadInteger('number').ToString);
    // true
    ShowMessage(R.ReadObject('object').ReadBoolean('bool').ToString);
    // 'Hello World'
    ShowMessage(
      R.ReadArray('array').ReadObject(0).ReadString('str') + ' ' +
      R.ReadArray('array').ReadObject(1).ReadString('str'));
    // [akTop, akBottom]
    R.Reader.ReadSet<TAnchors>('set');

    // Exception: "JSON.array[0].oops" is missing or does not contain a valid STRING value."
    ShowMessage(R.ReadArray('array').ReadObject(0).ReadString('oops'));
    // 'Default Value'
    ShowMessage(R.ReadArray('array').ReadObject(0).ReadString('oops', 'Default Value'));

  finally
    J.Free;
  end;
end;
```
###Writer###
```pascal
var
  J: TJSONObject;
  W: IJSONObjectWriter;
begin
  J := TJSONObject.Create;
  try
    W := TJSONObjectWriter.Create(J);

    W.WriteInteger('number', 42);
    W.WriteObject('object').WriteBoolean('bool', true);
    with W.WriteArray('array') do
    begin
      AddObject.WriteString('str', 'Hello');
      AddObject.WriteString('str', 'World');
    end;

    // Ordinal values: [1, 3]
    W.Writer.WriteSet<TAnchors>('set', [akTop, akBottom]);
    // String values : ["akTop", "akBottom"]
    W.Writer.WriteSet<TAnchors>('set', [akTop, akBottom], true);
    // Custom strings: ["top", "bottom"]
    W.Writer.WriteSet<TAnchors>('set', [akTop, akBottom], ['left', 'top', 'right', 'bottom']);

    // Writes a new array or "null", if the array does not contain elements
    W.WriteArrayOrNull('conditional', 
      function(W: TJSONArrayWriter): Boolean
      begin
        // Add elements to the new array
        // ...
        Result := W.InnerObject.Count > 0;
      end);

  finally
    J.Free;
  end;
end;
```

## License ##

Licensed under the MIT License. Dependencies are under their respective licenses.