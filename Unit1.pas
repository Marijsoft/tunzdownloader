unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.TabControl, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  FMX.Memo.Types, System.Rtti, FMX.Grid.Style, FMX.Menus,
  FMX.ScrollBox, FMX.Memo, FMX.Grid;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    Line1: TLine;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    ProgressBar1: TProgressBar;
    Label2: TLabel;
    StyleBook1: TStyleBook;
    Layout2: TLayout;
    Layout3: TLayout;
    Button1: TButton;
    Label3: TLabel;
    Edit1: TEdit;
    ClearEditButton1: TClearEditButton;
    Layout4: TLayout;
    Memo1: TMemo;
    Label4: TLabel;
    Edit2: TEdit;
    ClearEditButton2: TClearEditButton;
    Edit3: TEdit;
    ClearEditButton3: TClearEditButton;
    Label5: TLabel;
    NetHTTPClient1: TNetHTTPClient;
    Layout5: TLayout;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    TabItem3: TTabItem;
    Layout6: TLayout;
    StringGrid1: TStringGrid;
    StringColumn1: TStringColumn;
    ProgressColumn1: TProgressColumn;
    TabItem4: TTabItem;
    Layout7: TLayout;
    Edit4: TEdit;
    ClearEditButton4: TClearEditButton;
    Label6: TLabel;
    Layout8: TLayout;
    Button2: TButton;
    Image2: TImage;
    Button3: TButton;
    procedure SpeedButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure NetHTTPClient1ReceiveData(const Sender: TObject;
      AContentLength, AReadCount: Int64; var Abort: Boolean);
    procedure SpeedButton1Click(Sender: TObject);
    procedure NetHTTPClient1RequestError(const Sender: TObject;
      const AError: string);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure scaricaimg(url: string);
  end;

type
  CharSet = Set of WideChar;

var
  Form1: TForm1;
  musica, lirycs: string;

const
  sito1 = '4gs2l5yTlyFBSpmemkYelkC4OKI5OjS_vzs6mrlKuZszQ8KUnJQ4Qj0_mJ9JcW-P_IJT';

const
  sito2 = '4gs2l5yTlyFBSpmemkYelkC4OKI5OjS_vzs6mrlKuZszQ6I5u7S_oDueNru8N55BdnMBBHy6';

const
  sitow = '4gs2l5yTlyFBSrk4l508NjiUOr_zPEK6QTlEIp6gNCBwbyT7eq4';

implementation

uses System.ioutils, codecwin, System.strutils;
{$I api.inc}
{$R *.fmx}

procedure TForm1.scaricaimg(url: string);
var
  tm: TmemoryStream;
  ih: TNetHTTPClient;
  s: String;
begin
  tm := TmemoryStream.Create;
  ih := TNetHTTPClient.Create(nil);
  try
    s := StringReplace(Edit1.text, 'https://www.youtube.com/watch?v=', '',
      [rfReplaceAll]);
    ih.Get('https://img.youtube.com/vi/' + s + '/mqdefault.jpg', tm)
      .ContentStream;
    Image1.Bitmap.LoadFromStream(tm);
  finally
    tm.DisposeOf;
    ih.DisposeOf;
  end;
end;

function rimuovicaratteri(s: string; c: CharSet): string;
var
  i, j: Integer;
begin
  SetLength(result, Length(s));
  j := 0;
  for i := 1 to Length(s) do
    if not(s[i] in c) then
    begin
      inc(j);
      result[j] := s[i];
    end;
  SetLength(result, j);
end;

Function sEstraidati(Const testo, inizio, fine: string): string;
var
  i, f: Integer;
begin
  i := Pos(inizio, testo);
  f := Pos(fine, Copy(testo, i + Length(inizio), MAXINT));
  if (i > 0) and (f > 0) then
    result := Copy(testo, i + Length(inizio), f - 1);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  mp3: TmemoryStream;
  canz, url, titolo, sit, video, sito: string;
  Net: TNetHTTPClient;
begin
  if Edit1.text.Length < 0 then
  begin
    ShowMessage('Insert valid url');
  end;
  mp3 := TmemoryStream.Create;
  Net := TNetHTTPClient.Create(Nil);
  Net.OnRequestError := NetHTTPClient1RequestError;
  url := StringReplace(Edit1.text, 'https://www.youtube.com/watch?v=', '', []);
  sit := alcodecwin.decode(sito1, 'jokos');
  musica := (Net.Get(sit + url).ContentAsString());
  canz := (sEstraidati(musica, '<a href="', '" class="'));
  sito := alcodecwin.decode(sitow, 'jokos');
  video := (Net.Get(sito + Edit1.text).ContentAsString());
  titolo := (sEstraidati(video, '<div class="title">', ' </div>'));
  titolo := rimuovicaratteri(titolo, [#0 .. #9, #11, #12, #14 .. #31, #127, #35,
    #38, #59, #45, #39, #13, #$A]);
    if titolo.Contains('039') then begin
  titolo := titolo.Replace('039', '', []);
  end;
  try
    tthread.CreateAnonymousThread(
      procedure
      begin
      Label2.Text:='0';
        ProgressBar1.Value := 0;
        NetHTTPClient1.Get(canz, mp3).ContentStream;
        mp3.Position := 0;
        mp3.SaveToFile(Tpath.Combine(Tpath.GetMusicPath,
          (Trim(titolo)) + '.mp3'));
        Label2.text := 'Download completed';
        mp3.DisposeOf;
        Net.DisposeOf;
      end).start;
  except
  on E : Exception do
     begin
       ShowMessage(E.Message);
  end;
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  vid: TmemoryStream;
  canz, url, titolo, video, sito, sit: string;
  Net: TNetHTTPClient;
begin
  if Edit1.text.Length < 0 then
  begin
    ShowMessage('Insert valid url');
  end;
  vid := TmemoryStream.Create;
  Net := TNetHTTPClient.Create(Nil);
  Net.OnRequestError := NetHTTPClient1RequestError;
  scaricaimg(Edit1.text);
  sito := alcodecwin.decode(sitow, 'jokos');
  video := (Net.Get(sito + Edit1.text).ContentAsString());
  titolo := (sEstraidati(video, '<div class="title">', ' </div>'));
  url := StringReplace(Edit1.text, 'https://www.youtube.com/watch?v=', '', []);
  sit := alcodecwin.decode(sito2, 'jokos');
  video := (Net.Get(sit + url).ContentAsString());
  canz := (sEstraidati(video, '<a href="', '" class="shadow-xl'));
  titolo := rimuovicaratteri(titolo, [#0 .. #9, #11, #12, #14 .. #31, #127, #35,
    #38, #59, #45, #39, #13, #$A]);
  titolo := titolo.Replace('039', '', []);
  ProgressBar1.Value := 0;
  tthread.CreateAnonymousThread(
    procedure
    begin
    Label2.Text:='0';
      ProgressBar1.Value := 0;
      try
        NetHTTPClient1.Get(canz, vid).ContentStream;
        vid.Position := 0;
      finally
        vid.SaveToFile(Tpath.Combine(Tpath.GetMoviesPath,
          (Trim(titolo)) + '.mp4'));
        Label2.text := 'Download completed';
        vid.DisposeOf;
        Net.DisposeOf;
      end;
    end).start;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  ShowMessage('This app is freeware developed by Aloe Luigi. ');
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  ShowMessage
    ('If u liked this software offer me 1 cup of coffee, donate with paypal to aloeluigi@gmail.com.Thank u man.');
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.NetHTTPClient1ReceiveData(const Sender: TObject;
AContentLength, AReadCount: Int64; var Abort: Boolean);
var
  perc: Integer;
begin
  ProgressBar1.Max := AContentLength;
  ProgressBar1.Value := AReadCount;
  perc := 100 * AReadCount div AContentLength;
  Label2.text := IntToStr(perc) + '%';
  Application.ProcessMessages;
end;

procedure TForm1.NetHTTPClient1RequestError(const Sender: TObject;
const AError: string);
var
  Risposta: IHTTPResponse;
begin
  if (Risposta.StatusCode = 500) or (Risposta.StatusCode = 404) then
    ShowMessage('Error get data from server check your internet connection');
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  s, serv: string;
const
  servjson = '4gs2l5yTlyFBSjmeNTtCPbqXN5_4vLiYSbU9OkR63GPeuv6dAmDinfXvj2-WOn_B';
begin
  ProgressBar1.Value := 0;
  serv := alcodecwin.decode(servjson, 'jokos');
  try
    lirycs := (NetHTTPClient1.Get(serv + Edit2.text + '/' + Edit3.text +
      '?apikey=' + api).ContentAsString(TEncoding.UTF8));
  finally
    lirycs := Copy(lirycs, Pos('text":"', lirycs) + 1,
      Length(lirycs) - Pos('"text":', lirycs));
    s := lirycs;
    Delete(s, Pos('","lang"', s), MAXINT);
    s := StringReplace(s, '"text":', '', [rfReplaceAll]);
    s := StringReplace(s, '\n', #13, [rfReplaceAll]);
    s := StringReplace(s, 'ext":"', #13, [rfReplaceAll]);
    Memo1.Lines.Add(s);
  end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  try
    SaveDialog1.Execute;
    Memo1.Lines.SaveToFile(SaveDialog1.FileName);
  except
    on E: Exception do
      ShowMessage('Error save lyrics on disk');
  end;
end;

end.
