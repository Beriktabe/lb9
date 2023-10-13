unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

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
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  unCheckedFile: file of crypto;
  tempCrypto, lastCrypto: crypto;
  isCheck: boolean;
  i, amount: integer;
implementation

{$R *.lfm}

{ TForm1 }
function getAmountOfStructs(fileName: string): LongInt;
var amount:integer;
  tempFile: file of crypto;
  tempCrypto: crypto;
begin
amount:=0;
  AssignFile(tempFile, fileName);
  Reset(tempFile);

  while not Eof(tempFile) do
  begin
    read(tempFile, tempCrypto);
    Inc(amount);
    end;
  CloseFile(tempFile);
  getAmountOfStructs:=amount;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   isCheck:=True;
   amount := getAmountOfStructs('unCheckedFile.data');
   AssignFile(unCheckedFile, 'unCheckedFile.data');
   reset(unCheckedFile);
   Seek(unCheckedFile, 0);
   read(unCheckedFile, lastCrypto);

   for i:= 1 to amount-1 do
   begin
     if isCheck = False then break;
     Seek(unCheckedFile, i);
     read(unCheckedFile, tempCrypto);

     if lastCrypto.cap <= tempCrypto.cap then
        begin
        if lastCrypto.cap = tempCrypto.cap then
           if lastCrypto.cap > tempCrypto.cap then isCheck:=False;
        end
     else
        isCheck:=False;

     lastCrypto := tempCrypto;
   end;
   if isCheck = True then ShowMessage('Sorted')
   else ShowMessage('notSorted');
   CloseFile(unCheckedFile);
end;

end.

