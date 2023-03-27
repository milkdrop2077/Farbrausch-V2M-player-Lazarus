//V2M player in Lazarus
//Code: MilkDrop2077
//with Magic_h2001.dll

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Windows;



type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

  type // need Windows in uses
  TV2mPlayFile = procedure(FName: PChar; AuRepeat: Boolean); stdcall;
  TV2mPlayResource = procedure(hInst:Longint; ResName, ResType:Pchar; AuRepeat:Bool); stdcall;
  TV2mGetTime = function :Longint; stdcall;
  TV2mStop = procedure() stdcall;

var
  Form1: TForm1;

  V2mPlayFile: TV2mPlayFile;
  V2mPlayResource: TV2mPlayResource;
  V2mGetTime: TV2mGetTime;
  V2mStop: TV2mStop;
  V2mDLLHandle: HMODULE;

  Target : string;
  Res : TResourceStream;

implementation

{$R *.lfm}
{$R V2mRes.res}


// LOAD V2M DLL dynamically + GetProcedureAddress
procedure LoadV2mDLLfromRes;
begin
  V2mDLLHandle := LoadLibrary(Pchar(Target));
  if V2mDLLHandle <> NilHandle then begin
    V2mPlayResource := TV2mPlayResource(GetProcedureAddress(V2mDLLHandle, 'V2mPlayResource')); //V2mPlayResource
    V2mGetTime := TV2mGetTime(GetProcedureAddress(V2mDLLHandle, 'V2mGetTime')); //V2mGetTime
    V2mStop := TV2mStop(GetProcedureAddress(V2mDLLHandle, 'V2mStop')); //V2mStop
  end;
end;

// UNLOAD V2M DLL + free Procedures
procedure UnloadV2mDLLfromRes;
begin
  if V2mDLLHandle <> NilHandle then begin
    UnloadLibrary(V2mDLLHandle);
    V2mPlayResource := nil;
    V2mGetTime := nil;
    V2mStop := nil;
  end;
end;

// V2mPlayResource
procedure CallV2mPlayResource(hInst:Longint; ResName, ResType:Pchar; AuRepeat:Bool);
begin
 V2mPlayResource(hInst, ResName, ResType, AuRepeat);
end;

// V2mGetTime
function CallV2mGetTime: Longint;
begin
 Result := V2mGetTime();
end;

// V2mStop
procedure CallV2mStop();
begin
 V2mStop();
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  Target := GetTempDir;
  if Target[Length(Target)] <> '\' then Target := Target + '\';
  Target := Target+'V2M.dll';

 Try
 res := TResourceStream.Create(hinstance, 'V2M', 'V2mfile');
 res.SaveToFile(Target);
 res.Free;
 Except on EFCreateError do end;

  // LOAD V2M DLL
  LoadV2mDLLfromRes;

  // PLAY V2M file from RES
  CallV2mPlayResource(hInstance,Pchar(101),'V2mFile',False);

  Timer1.Enabled:= true;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Timer1.Enabled:= false;
  Label2.Caption:= '';
  CallV2mStop();
  UnloadV2mDLLfromRes;
  DeleteFile(Pchar(Target+'V2M.dll'));
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Label2.Caption:= inttostr(CallV2mGetTime);
end;

end.

