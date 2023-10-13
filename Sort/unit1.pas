unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type
  crypto = Record
    name: string[20];
    quat: string[3];
    cap: integer;
    price: integer;  //double
    descr: string[50];
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

  sortingThread = class(TThread)
  private
    FForm: TForm1;
    procedure sync1;
    //procedure sync2;
    //procedure sync3;
  protected
    procedure Execute; override;
  public
    Constructor Create(Form: TForm1);
  end;



const cryptoSize = 88;
var
  Form1: TForm1;
  fileSizeInKB: integer;
  structuresPerSplit, splits: integer;
  tempFilesAmount: integer;
implementation

function comp(a,b: crypto):boolean;
begin
   comp:= False;
   if a.cap > b.cap then comp:=True
   else
       begin
             if a.cap = b.cap then
                if a.price > b.price then comp := True

       end;
end;
procedure qSort(var A: array of crypto; first, last:integer);
var f, l: longint;

  mid, temp: crypto;
begin
  f:=first;
  l:=last;
  mid:=a[(f+l) div 2];
  repeat
    while comp(mid, A[f]) do inc(f);
    while comp(A[l],mid) do dec(l);
    if f<=l then
    begin
      temp:=A[f];
      A[f]:=A[l];
      A[l]:=temp;
      inc(f);
      dec(l);
    end;
  until f>l;
  if first<l then qSort(A, first, l);
  if f<last then qSort(A, f, last);
end;

procedure mergeA(firstFile, secondFile: string);
var
  a: crypto;
  b: crypto;
  i1,i2, i, f1a, f2a:integer;
  f1, f2, otp: file of crypto;
begin

  i1 := 0;
  i2 := 0;
  AssignFile(f1, firstFile);
  AssignFile(f2, secondFile);
  AssignFile(otp, 'mergeInWork.tData');

  reset(f1);
  reset(f2);

  f1a := FileSize(f1);
  f2a := FileSize(f2);

  Rewrite(otp);

  Seek(f1, 0);
  read(f1, a);

  Seek(f2, 0);
  read(f2, b);

  for i := 0 to f1a+f2a-1 do
  begin

    if i1>f1a-1 then
    begin
         Seek(f2, i2);
         read(f2, b);
         Write(otp, b);
         i2 := i2+1;
    end
    else
    if i2>f2a-1 then
    begin
          Seek(f1, i1);
          read(f1, a);
          Write(otp, a);
          i1 := i1+1;
    end
    else
    begin
    Seek(f1, i1);
    read(f1, a);
    Seek(f2, i2);
    read(f2, b);
    if comp(b, a) then
    begin
          Write(otp, a);
          i1 := i1+1;
    end
    else
    begin
           Write(otp, b);
           i2 := i2+1;
    end;
    end;
    end;
  CloseFile(f1);
  CloseFile(f2);
  DeleteFile(firstFile);
  DeleteFile(secondFile);
  CloseFile(otp);
  RenameFile('mergeInWork.tData', firstFile);
end;


procedure Split();
var
  unsortedFile: file of crypto;
  tempFileCrypto: file of crypto;
  i, j: integer;
  amount: LongInt;
  tempCrypto: crypto;
  curPos: LongInt;
begin
  splits:=16;
  AssignFile(unsortedFile, 'unsorted.data');
  Reset(unsortedFile);
  amount:=FileSize(unsortedFile);

  structuresPerSplit:=amount div 16;
  if structuresPerSplit mod 10 <> 0 then
      structuresPerSplit := structuresPerSplit + 1;


  Reset(unsortedFile);
  curPos := 0;
  for i:= 1 to splits do begin
    AssignFile(tempFileCrypto, 'tempData\spl' + IntToStr(i) + '.tData');
    Rewrite(tempFileCrypto);
    inc(tempFilesAmount);
    for j := 1 to structuresPerSplit do begin
      if (curPos >= amount) then break;
      Seek(unsortedFile, curPos);
      read(unsortedFile, tempCrypto);
      write(tempFileCrypto, tempCrypto);
      inc(curPos);
    end;
    CloseFile(tempFileCrypto);
  end;
  closeFile(unsortedFile);

end;
procedure qSortAll();
var
  i, j, stt: integer;
  tempCrypto: crypto;
  tempArray: array of crypto;
  tempFile: file of crypto;
  tempFileName: string;
begin

  for i:=1 to tempFilesAmount do begin
    tempFileName := 'tempData\spl' + IntToStr(i) + '.tData';
    AssignFile(tempFile, tempFileName);
    Reset(tempFile);
    stt := FileSize(tempFile);


    SetLength(tempArray, stt);
    for j:=0 to stt-1 do
    begin
      read(tempFile, tempCrypto);
      tempArray[j] := tempCrypto;
    end;
    CloseFile(tempFile);

    qSort(tempArray, 0, High(tempArray));

    Rewrite(tempFile);
    for j := 0 to stt-1 do
        write(tempFile, tempArray[j]);

    CloseFile(tempFile);
    RenameFile(tempFileName, 'tempData\spl' + IntToStr(i) + '_merge.tData');
  end;

end;
procedure MergeAll();
var i, j: integer;
  tmpName1, tmpName2: string;
begin
  j:=8;
  while j >= 1 do
  begin
       i:=1;
       while i <= j do
       begin
            tmpName1:='tempData\spl' + IntToStr(i) + '_merge.tData';
            tmpName2:='tempData\spl' + IntToStr(i+j) + '_merge.tData';
            mergeA(tmpName1, tmpName2);

       inc(i);
       end;
       j:= j div 2;
  end;
  RenameFile('tempData\spl1_merge.tData', 'final.data');
end;


constructor sortingThread.Create(Form: TForm1);
begin
  FForm := Form;
  inherited Create(False);
end;

procedure sortingThread.sync1;
begin
  FForm.ProgressBar1.Position:=FForm.ProgressBar1.Position+1;
end;



procedure sortingThread.Execute;
begin
     Split();
     qSortAll();
     MergeAll();
end;



{$R *.lfm}


procedure TForm1.Button1Click(Sender: TObject);
var unsortedFile: file of crypto;
begin
    {AssignFile(unsortedFile, 'unsorted.data');
    Reset(unsortedFile);
    amount:=FileSize(unsortedFile);
    Form1.Label2.Caption := '1/3 Splitting';
    ProgressBar1.Max:=;
    Split();
    qSortAll();
    MergeAll();}
end;

end.

