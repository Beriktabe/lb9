unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls;

type
    crypto = record
      name: string[20];
      quat: string[3];
      cap: integer;
      price: integer;   //double
      descr: string[50];
    end;
  { TForm1 }



  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

  generatorThread = class(TThread)
    private
      FForm: TForm1;
      procedure sync;
    protected
      procedure Execute; override;
    public
      Constructor Create(Form: TForm1);
    end;

const cryptoSize = 88;
var
  Form1: TForm1;
  unsortedFile: file of crypto;
  cryptoAmount: Integer;
implementation

{$R *.lfm}

{ TForm1 }
function genInt():integer;
begin
   genInt:=Random(integer.MaxValue-1 );                 //integer.MaxValue-1
end;

function genDouble():Double;
begin
   genDouble:=random() * Double.MaxValue-1;
end;

function genString(l: integer):string;
var tempStr: string;
  i: integer;
begin
   for i:= 1 to l do
       tempStr:= tempStr + chr(random( ord('Z') - ord('A') + 1) + ord('A'));
   genString := tempStr;
end;


constructor generatorThread.Create(Form: TForm1);
begin
  FForm := Form;
  inherited Create(False);
end;
procedure generatorThread.sync;
begin
  FForm.ProgressBar1.Position:=FForm.ProgressBar1.Position+1;
end;

procedure generatorThread.Execute;
var tempCrypto: crypto;
  i: integer;
begin
  FreeOnTerminate := True;

  AssignFile(unsortedFile,'unsorted.data');

  Rewrite(unsortedFile);
  for i:= 0 to cryptoAmount do begin
    with tempCrypto do begin
    Name:=genString(20);
    quat:=genString(3);
    cap:=genInt();
    price:= genInt(); //genDouble
    descr:= genString(50);
    end;
    Write(unsortedFile, tempCrypto);

    Synchronize(@sync);
  end;
  CloseFile(unsortedFile);
  ShowMessage('Generated');
end;

procedure TForm1.Button1Click(Sender: TObject);
var FThread: generatorThread;
begin
  Randomize;
  cryptoAmount := (StrToInt(Edit1.Text)*1024*1024) div cryptoSize + 1;   //
  Edit2.Text:= IntToStr(cryptoAmount);
  ProgressBar1.Max:=cryptoAmount;
  FThread := generatorThread.Create(Self);
end;


end.

