unit MarkdownCodeCollector;

interface

uses
  SysUtils, Classes;

type
  TMarkdownCodeCollection = class
  private
    FStrings: TStringList;
    FSelectedIndex: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    // Accessing strings
    function GetString(Index: Integer): string;
    function Select(Index: Integer): Boolean;
    function GetCount: Integer;
    // Modifying strings
    procedure Clear;
    procedure Add(const Value: string);
    procedure Insert(Index: Integer; const Value: string);
    procedure Remove(Index: Integer);
    property Selected: Integer read FSelectedIndex;
  end;

var
  SourceCodeCollection: TMarkdownCodeCollection;

implementation


{ TMarkdownCodeCollection }

procedure TMarkdownCodeCollection.Add(const Value: string);
begin
  FStrings.Add(Value);
end;

procedure TMarkdownCodeCollection.Clear;
begin
  FStrings.Clear;
end;

constructor TMarkdownCodeCollection.Create;
begin
  FStrings := TStringList.Create;
end;

destructor TMarkdownCodeCollection.Destroy;
begin
  FStrings.Free;
  inherited Destroy;
end;

function TMarkdownCodeCollection.GetCount: Integer;
begin
  Result := FStrings.Count;
end;

function TMarkdownCodeCollection.GetString(Index: Integer): string;
begin
  Result := FStrings[Index];
end;

procedure TMarkdownCodeCollection.Insert(Index: Integer; const Value: string);
begin
  FStrings.Insert(Index, Value);
end;

procedure TMarkdownCodeCollection.Remove(Index: Integer);
begin
  FStrings.Delete(Index);
end;

function TMarkdownCodeCollection.Select(Index: Integer): Boolean;
begin
  Result := False;
  if FStrings.Count >= Index then
  begin
    FSelectedIndex := Index;
    Result := True;
  end;
end;

initialization
 SourceCodeCollection := TMarkdownCodeCollection.Create;

finalization
 SourceCodeCollection.Free;
end.


