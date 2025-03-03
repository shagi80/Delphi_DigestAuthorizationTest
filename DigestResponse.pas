unit DigestResponse;

interface

{ Digest аунтефикация в Википедии:
https://ru.wikipedia.org/wiki/%D0%94%D0%B0%D0%B9%D0%B4%D0%B6%D0%B5%D1%81%D1%82-%D0%B0%D1%83%D1%82%D0%B5%D0%BD%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%86%D0%B8%D1%8F
}

type
  TDigestRecord = record
    method: string;
    realm: string;
    nonce: string;
    url: string;
    qop: string;
    nc: string;
    cnonce: string;
    opaque: string;
    stale: boolean;
  end;

  TDigestResponse = class
  private
    FDigestRec: TDigestRecord;
    procedure ClearRecord;
    function GetQuotedValue(Text, Key: string): string;
    function GetMD5(Text: string): string;
    procedure ParseServerResponse(ServerResponse: string);
  public
    constructor Create;
    destructor Destroy; override;
    property DigestRecord: TDigestRecord read FDigestRec;
    function GetResponseHeader(ServerResponse, Url, Username, Password: string;
      AttemptNum: Integer): string;
  end;

implementation

uses
  SysUtils, IdGlobal, IdHash, IdHashMessageDigest, Dialogs;

constructor TDigestResponse.Create;
begin
  inherited Create;
  Self.ClearRecord;
end;

destructor TDigestResponse.Destroy;
begin
  inherited Destroy;
end;

procedure TDigestResponse.ClearRecord;
begin
  FDigestRec.method := '';
  FDigestRec.realm := '';
  FDigestRec.nonce := '';
  FDigestRec.url := '';
  FDigestRec.qop := '';
  FDigestRec.nc := '';
  FDigestRec.cnonce := '';
  FDigestRec.opaque := '';
  FDigestRec.stale := True;
end;

function TDigestResponse.GetQuotedValue(Text, Key: string): string;
var
  Start: Integer;
begin
  Result := '';
  Start := pos(Key, Text) + Length(Key + '="') - 1;
  if not(Start > 0) then Exit;
  Delete(Text, 1, Start);
  Result := copy(Text, 1, pos('"', Text) - 1);
end;

function TDigestResponse.GetMD5(Text: string): string;
begin
  Result := '';
  with TIdHashMessageDigest5.Create do
    try
      Result := TIdHash128.AsHex(HashValue(Text));
    finally
      Free;
    end;
end;

procedure TDigestResponse.ParseServerResponse(ServerResponse: string);
{*
  Ответ сервера:
  Digest realm="testrealm@host.com",
  qop="auth,auth-int",
  nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
  opaque="5ccc069c403ebaf9f0171e9517f40e41"
*}
begin
  FDigestRec.method := copy(ServerResponse, 1, pos(' ', ServerResponse) - 1);
  FDigestRec.realm := GetQuotedValue(ServerResponse, 'realm');
  FDigestRec.nonce := GetQuotedValue(ServerResponse, 'nonce');
  FDigestRec.url := '';
  FDigestRec.qop := GetQuotedValue(ServerResponse, 'qop');
  FDigestRec.nc := '';
  FDigestRec.cnonce := '';
  FDigestRec.opaque := GetQuotedValue(ServerResponse, 'opaque');
  FDigestRec.stale := (GetQuotedValue(ServerResponse, 'stale') = 'true');
end;

function TDigestResponse.GetResponseHeader(ServerResponse, Url, Username,
  Password: string; AttemptNum: Integer): string;
{*
Ответ клиента должен быть:
  Digest username="Mufasa",
  realm="testrealm@host.com",
  nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
  uri="/dir/index.html",
  qop=auth,
  nc=00000001,
  cnonce="0a4f113b",
  response="6629fae49393a05397450978507c4ef1",
  opaque="5ccc069c403ebaf9f0171e9517f40e41"
*}
var
  HA1, HA2, HA3, Text: string;
begin
  Result := '';
  Self.ClearRecord;
  Self.ParseServerResponse(ServerResponse);
  FDigestRec.url := Url;
  FDigestRec.nc := FormatFloat('00000000', AttemptNum);
  //FDigestRec.cnonce := '0a4f113b';
  FDigestRec.cnonce := 'b817c618cd7da4e1';
  Text := Username + ':' + FDigestRec.realm + ':' + Password;
  HA1 := Lowercase(Self.GetMD5(Text));
  HA2 := Lowercase(Self.GetMD5('GET' + ':' +Url));
  Text := HA1 + ':' + FDigestRec.nonce + ':' + FDigestRec.nc
    + ':' + FDigestRec.cnonce + ':' + 'auth' + ':' + HA2;
  HA3 := Lowercase(Self.GetMD5(Text));
  Result := 'Digest '
    + 'username="' + Username + '", '
    + 'realm="' + FDigestRec.realm + '", '
    + 'nonce="' + FDigestRec.nonce + '", '
    + 'uri="' + Url + '", '
    + 'qop=auth, '
    + 'nc=' + FDigestRec.nc + ', '
    + 'cnonce="' + FDigestRec.cnonce + '", '
    + 'response="' + HA3 + '", '
    + 'opaque="' + FDigestRec.opaque + '"'
end;

end.
