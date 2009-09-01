// unit UniCodeUtils

//    written by Silhwan Hyun  (hyunsh@hanafos.com)
//
//
// Ver 1.0                         3 Sep 2008
//   - Initial release


unit UniCodeUtils;

interface

uses LResources;

 {$INCLUDE Delphi_Ver.inc}


 // function DupeString is defined in StrUtils.pas of Delphi 7
 function DupeString(const AText: ansistring; ACount: Integer): ansistring;

 function ToWideString(s: AnsiString): WideString;

implementation

const
  Max_Wide_Len = 8192;
  Max_Ansi_Len = Max_Wide_Len;

type
  pW = array[0..Max_Wide_Len-1] of WideChar;
  pa = array[0..Max_Ansi_Len-1] of AnsiChar;
var
  pw1 : pW;
  pa1 : pa;

function DupeString(const AText: ansistring; ACount: Integer): ansistring;
var
  P: PAnsiChar;
  C: Integer;
begin
  C := Length(AText);
  SetLength(Result, C * ACount);
  P := Pointer(Result);
  if P = nil then Exit;
  while ACount > 0 do
  begin
    Move(Pointer(AText)^, P^, C);
    Inc(P, C);
    Dec(ACount);
  end;
end;

function ToWideString(s: AnsiString): WideString;
var
   p : pByte;
begin
   Result:=UTF8Decode(AnsiToUtf8(s));
end;

end.


