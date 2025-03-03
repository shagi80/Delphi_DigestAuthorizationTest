unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, IdAuthentication, IdHeaderList, IdAuthenticationDigest, IdIntercept,
  IdLogBase, IdLogFile, DigestResponse;

type
  TForm1 = class(TForm)
    IdHTTP1: TIdHTTP;
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    IdLogFile1: TIdLogFile;
    btnTest: TButton;
    Button2: TButton;
    IdTCPClient: TIdTCPClient;
    procedure btnTestClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    procedure ShowResponseHeader(DigestResponse: TDigestResponse;
      ServerAuthResponse, Header: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.Edit1.Text := 'http://192.168.1.199/ISAPI/System/capabilities';
  Self.IdHTTP1.Intercept := Self.IdLogFile1;
  Self.IdTCPClient.Intercept := Self.IdLogFile1;
  Memo1.Lines.Clear;
end;

procedure TForm1.ShowResponseHeader(DigestResponse: TDigestResponse;
  ServerAuthResponse, Header: string);
begin
  Memo1.Lines.Add('');
  Memo1.Lines.Add(UpperCase('Server auth response:'));
  Memo1.Lines.Add(ServerAuthResponse);
  Memo1.Lines.Add('');
  Memo1.Lines.Add(UpperCase('Digest header creator:'));
  Memo1.Lines.Add('Method: ' + DigestResponse.DigestRecord.method);
  Memo1.Lines.Add('Realm: ' + DigestResponse.DigestRecord.realm);
  Memo1.Lines.Add('Nonce: ' + DigestResponse.DigestRecord.nonce);
  Memo1.Lines.Add('Url: ' + DigestResponse.DigestRecord.url);
  Memo1.Lines.Add('Qop: ' + DigestResponse.DigestRecord.qop);
  Memo1.Lines.Add('Nc: ' + DigestResponse.DigestRecord.nc);
  Memo1.Lines.Add('Cnonce: ' + DigestResponse.DigestRecord.cnonce);
  Memo1.Lines.Add('opaque: ' + DigestResponse.DigestRecord.opaque);
  Memo1.Lines.Add('');
  Memo1.Lines.Add(UpperCase('Header:'));
  Memo1.Lines.Add(Header);
end;

procedure TForm1.btnTestClick(Sender: TObject);
var
  ServerResponse, Header: string;
  DigestResponse: TDigestResponse;
begin
  {ServerResponse := 'Digest realm="testrealm@host.com",'
    + 'qop="auth,auth-int",'
    + 'nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",'
    + 'opaque="5ccc069c403ebaf9f0171e9517f40e41"';
  DigestResponse := TDigestResponse.Create;
  Header := DigestResponse.GetResponseHeader(ServerResponse,
    '/dir/index.html', 'Mufasa', 'Circle Of Life', 1);
  Self.ShowResponseHeader(DigestResponse, ServerResponse, Header);
  DigestResponse.Free;  }

  ServerResponse := 'igest qop="auth",'
    + 'realm="DS-0362B98B",'
    + 'nonce="NjU3YTFlM2JhOGM0OGVhNTg4OWM0NmNjZTBhNjAzYTY=",'
    + 'stale="false", opaque="", domain="::"';
  DigestResponse := TDigestResponse.Create;
  Header := DigestResponse.GetResponseHeader(ServerResponse,
    '/ISAPI/System/capabilities', 'admin', 'shrtyjk8006', 1);
  Self.ShowResponseHeader(DigestResponse, ServerResponse, Header);
  DigestResponse.Free;     
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Resp, Header: String;
  DigestResponse: TDigestResponse;
begin
  if length(Self.Edit1.Text) > 0 then begin
    try
      Resp := Self.IdHTTP1.Get(Edit1.Text);
      Memo1.Text := Resp;
    except
      Memo1.Lines.Add('');
      Memo1.Lines.Add(UpperCase('Ответ сервера:'));
      Memo1.Text := IdHTTP1.ResponseText;
      //
      Resp := IdHTTP1.Response.WWWAuthenticate.Text;
      DigestResponse := TDigestResponse.Create;
      Header := DigestResponse.GetResponseHeader(Resp, IdHTTP1.Request.URL,
        'admin', 'shrtyjk8006', 1);
      Self.ShowResponseHeader(DigestResponse, Resp,Header);
      IdHTTP1.Request.CustomHeaders.Add('Authorization: ' + Header);
      try
        Resp := Self.IdHTTP1.Get(Edit1.Text);
        Memo1.Lines.Add('');
        Memo1.Lines.Add(UpperCase('Ответ сервера:'));
        Memo1.Lines.Add(Resp);
      except
        Memo1.Lines.Add('');
        Memo1.Lines.Add(UpperCase('Ответ сервера:'));
        Memo1.Lines.Add(IdHTTP1.ResponseText);
      end;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  RequestList: TStringlist;
  Resp, Header: string;
  I: integer;
  DigestResponse: TDigestResponse;
begin
  Memo1.Lines.Clear;
  try
    RequestList:=TStringlist.Create;
    IdTcpClient.ReadTimeout:=3000;
    //IdTcpClient.ConnectTimeout:=3000;
    IdTCPClient.Disconnect;
    IdTCPClient.Host := '192.168.1.199';
    IdTCPClient.Port:=80;
    IdTCPClient.Connect;
    IdTCPClient.WriteLn('GET ' + Edit1.Text + ' HTTP/1.1');
    IdTCPClient.WriteLn('Host: 192.168.1.199');
    IdTCPClient.WriteLn('');
    RequestList.Text := IdTcpClient.AllData;
    for I := 0 to RequestList.Count - 1 do
      Memo1.Lines.Add(IntToStr(I) + ')  ' + RequestList[I]);
    if Pos('401 Unauthorized', RequestList[0]) > 0 then begin
      DigestResponse := TDigestResponse.Create;
      Header := DigestResponse.GetResponseHeader(RequestList[7],
        '/ISAPI/System/capabilities',
        'admin', 'shrtyjk8006', 1);
      ShowResponseHeader(DigestResponse, Resp, Header);
      DigestResponse.Free;

      IdTCPClient.Host := '192.168.1.199';
      IdTCPClient.Port:=80;
      IdTCPClient.Connect;
      IdTCPClient.WriteLn('GET ' + Edit1.Text + ' HTTP/1.1');
      IdTCPClient.WriteLn('Host: 192.168.1.199');
      IdTCPClient.WriteLn('Authorization: ' + Header);
      IdTCPClient.WriteLn('');

      RequestList.Text := IdTcpClient.AllData;
      Memo1.Lines.Add('----------------------');
      Memo1.Lines.AddStrings(RequestList);
      RequestList.SaveToFile('RESULT.txt');
    end;
    RequestList.Free;
  except
    RequestList.Free;
  end;
end;

end.
