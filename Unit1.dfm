object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Digest Authorization Test'
  ClientHeight = 427
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 8
    Top = 24
    Width = 489
    Height = 21
    TabOrder = 0
  end
  object Button1: TButton
    Left = 422
    Top = 51
    Width = 75
    Height = 25
    Caption = 'GET'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 51
    Width = 408
    Height = 358
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object btnTest: TButton
    Left = 422
    Top = 82
    Width = 75
    Height = 25
    Caption = 'Digest test'
    TabOrder = 3
    OnClick = btnTestClick
  end
  object IdHTTP1: TIdHTTP
    MaxLineAction = maException
    AllowCookies = True
    HandleRedirects = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoInProcessAuth]
    Left = 424
    Top = 128
  end
  object IdLogFile1: TIdLogFile
    Active = True
    Filename = 'Log.txt'
    Left = 464
    Top = 120
  end
end
