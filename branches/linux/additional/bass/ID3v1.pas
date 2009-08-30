{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library                                                         }
{ Class TID3v1 - for manipulating with ID3v1 tags                             }
{                                                                             }
{ http://mac.sourceforge.net/atl/                                             }
{ e-mail: macteam@users.sourceforge.net                                       }
{                                                                             }
{ Copyright (c) 2000-2002 by Jurgen Faul                                      }
{ Copyright (c) 2003-2005 by The MAC Team                                     }
{                                                                             }
{ Version 1.2 (April 2005) by Gambit                                          }
{   - updated to unicode file access                                          }
{                                                                             }
{ Version 1.1 (16 June 2004) by jtclipper                                     }
{   - added support for Lyrics3 v2.00 Tags                                    }
{                                                                             }
{ Version 1.0 (25 July 2001)                                                  }
{   - Reading & writing support for ID3v1.x tags                              }
{   - Tag info: title, artist, album, track, year, genre, comment             }
{                                                                             }
{ This library is free software; you can redistribute it and/or               }
{ modify it under the terms of the GNU Lesser General Public                  }
{ License as published by the Free Software Foundation; either                }
{ version 2.1 of the License, or (at your option) any later version.          }
{                                                                             }
{ This library is distributed in the hope that it will be useful,             }
{ but WITHOUT ANY WARRANTY; without even the implied warranty of              }
{ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU           }
{ Lesser General Public License for more details.                             }
{                                                                             }
{ You should have received a copy of the GNU Lesser General Public            }
{ License along with this library; if not, write to the Free Software         }
{ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   }
{                                                                             }
{ *************************************************************************** }

// -- Modified for TBASSPlayer  by Silhwan Hyun --
// Replaced the refernced unit TntClasses, TntSysUtils of "Tnt Delphi UNICODE Controls"
//  package with UniCodeUtils and TntCollection.
// Added a function ReadID3v1TagFromStream for TBASSPlayer.

//  - Modified for Delphi 2009  (30 Apr 2009)

unit ID3v1;

interface

{$DEFINE VER185}

{$INCLUDE Delphi_Ver.inc}

uses
  Classes, SysUtils, UniCodeUtils{$IFDEF WINDOWS}, TntCollection{$ENDIF}
  {$IFNDEF DELPHI_2007_BELOW}, Types, AnsiStrings{$ENDIF}, CommonATL;


const
  MAX_MUSIC_GENRES = 148;    // Max. number of music genres
  DEFAULT_GENRE = 255;                              { Index for default genre }

  { Used with VersionID property }
  TAG_VERSION_1_0 = 1;                                { Index for ID3v1.0 tag }
  TAG_VERSION_1_1 = 2;                                { Index for ID3v1.1 tag }

var
  aTAG_MusicGenre: array [0..MAX_MUSIC_GENRES - 1] of AnsiString;   // Genre names
  bTAG_PreserveDate: boolean;
  bTAG_ID3v2PreserveALL: boolean;
  bTAG_UseLYRICS3: boolean;
  bTAG_GenreOther: boolean;

type

  String04 = string[4];                          { String with max. 4 symbols }

  { Real structure of ID3v1 tag }
  TagRecord = record
    Header: array [1..3] of AnsiChar;                //Tag header - must be "TAG"
    Title: array [1..30] of AnsiChar;                // Title data
    Artist: array [1..30] of AnsiChar;               // Artist data
    Album: array [1..30] of AnsiChar;                // Album data
    Year: array [1..4] of AnsiChar;                  // Year data
    Comment: array [1..30] of AnsiChar;              // Comment data
    Genre: Byte;                                     // Genre data
  end;

  TMP3TagInfo = record
    Title: string;                              { Title data }
    Artist: string;                             { Artist data }
    Album: string;                              { Album data }
    Year: string;                               { Year data }
    Comment: string;                            { Comment data }
    Track: word;                                { Track number }
    Genre: string;                              { Genre data }
  end;

  Lyr2Mark = record
    Size: array [1..6] of AnsiChar;
    Mark: array [1..9] of AnsiChar;
  end;
  Lyr2Field = record
    ID: array [1..3] of AnsiChar;
    Size: array [1..5] of AnsiChar;
  end;

  { Class TID3v1 }
  TID3v1 = class(TObject)
    private
      FExists: Boolean;
      FVersionID: Byte;
      FTitle: AnsiString;
      FArtist: AnsiString;
      FAlbum: AnsiString;
      FYear: String04;
      FComment: AnsiString;
      FTrack: Byte;
      //FTrackString: string;
      FGenreID: byte;

      //lyrics 2
      FExists2: boolean;
      FLyrics2Size: integer;
      FArtist2: AnsiString;
      FAlbum2: AnsiString;
      FTitle2: AnsiString;
      FComment2: AnsiString;
      FIMG: AnsiString;

      function FGetLyrics2Size: integer;
      function FGetTagSize: integer;

      function ReadTag(const FileName: WideString; bSetFields: boolean=true): Boolean;
      function SaveTag(const FileName: WideString; bUseLYR2: boolean = true): Boolean;

      procedure FSetTitle(const NewTitle: AnsiString);
      procedure FSetArtist(const NewArtist: AnsiString);
      procedure FSetAlbum(const NewAlbum: AnsiString);
      procedure FSetYear(const NewYear: String04);
      procedure FSetComment(const NewComment: AnsiString);
      procedure FSetTrack(const NewTrack: Byte);
      procedure FSetGenreID(const NewGenreID: Byte);
      procedure FSetGenre(const NewGenre: AnsiString);

      function FGetTrackString: AnsiString;
      function FGetTitle: AnsiString;
      function FGetArtist: AnsiString;
      function FGetAlbum: AnsiString;
      function FGetComment: AnsiString;
      function FGetGenre: AnsiString;
      function FGetHasLyrics: boolean;

    public

      //lyrics 2
      Writer: AnsiString;
      Lyrics: AnsiString;

      constructor Create;
      procedure ResetData;
      function ReadFromFile(const FileName: WideString): Boolean;
      function RemoveFromFile(const FileName: WideString; bLyr2Only: boolean = false): Boolean;
      function SaveToFile(const FileName: WideString ): Boolean;
      property Exists: Boolean read FExists;                       // True if tag found
      property ExistsLyrics2: Boolean read FExists2;               // True if Lyrics 2 tag found
      property VersionID: Byte read FVersionID;                    // Version code

      property Track: Byte read FTrack write FSetTrack;            // Track number
      property TrackString: AnsiString read FGetTrackString;
      property Title: AnsiString read FGetTitle write FSetTitle;
      property Artist: AnsiString read FGetArtist write FSetArtist;
      property Album: AnsiString read FGetAlbum write FSetAlbum;
      property Year: String04 read FYear write FSetYear;
      property Comment: AnsiString read FGetComment write FSetComment;
      property GenreID: Byte read FGenreID write FSetGenreID;      // Genre code
      property Genre: AnsiString read FGetGenre write FSetGenre;       // Genre name
      property HasLyrics: boolean read FGetHasLyrics;
      property Lyrics2Size: integer read FGetLyrics2Size;          // full LYRICS2 tag size
      property TagSize: integer read FGetTagSize;                  // full tag size

  end;

 // Load ID3v1 tag from stream: added for TBASSPlayer by Silhwan Hyun
  function ReadID3v1TagFromStream(TagStream : pAnsiChar;
                                  var MP3TagInfo : TMP3TagInfo): Boolean; { Load tag from tag stream }

  function AnsiCharUpperBuff(lpsz : PAnsiChar; cchLength : DWORD) : DWORD;
            stdcall; external 'user32.dll' name 'CharUpperBuff';

implementation

{$IFNDEF DELPHI_6_BELOW}
uses StrUtils;
{$ENDIF}


//-----------------------------------------------------------------------------------------------------------------------------------
// Private functions & procedures
//-----------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetTitle(const NewTitle: AnsiString);
begin
 {$IFNDEF DELPHI_2007_BELOW}
  FTitle := AnsiStrings.TrimRight(NewTitle);
 {$ELSE}
  FTitle := TrimRight(NewTitle);
 {$ENDIF}
  if Length( FTitle ) > 30 then begin
     FTitle2 := FTitle;
  end else begin
     FTitle2 := '';
  end;
end;

//-----------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetArtist(const NewArtist: AnsiString);
begin
 {$IFNDEF DELPHI_2007_BELOW}
  FArtist := Ansistrings.TrimRight(NewArtist);
 {$ELSE}
  FArtist := TrimRight(NewArtist);
 {$ENDIF}
  if Length( FArtist ) > 30 then begin
     FArtist2 := FArtist;
  end else begin
     FArtist2 := '';
  end;
end;
//-----------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetAlbum(const NewAlbum: AnsiString);
begin
 {$IFNDEF DELPHI_2007_BELOW}
  FAlbum := Ansistrings.TrimRight(NewAlbum);
 {$ELSE}
  FAlbum := TrimRight(NewAlbum);
 {$ENDIF}
  if Length( FAlbum ) > 30 then begin
     FAlbum2 := FAlbum;
  end else begin
     FAlbum2 := '';
  end;
end;
//-----------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetYear(const NewYear: String04);
begin
 {$IFNDEF DELPHI_2007_BELOW}
  FYear := Ansistrings.TrimRight(NewYear);
 {$ELSE}
  FYear := TrimRight(NewYear);
 {$ENDIF}
end;
//-----------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetComment(const NewComment: AnsiString);
begin
  {$IFNDEF DELPHI_2007_BELOW}
  FComment := Ansistrings.TrimRight(NewComment);
 {$ELSE}
  FComment := TrimRight(NewComment);
 {$ENDIF}
  if Length( FComment ) > 30 then begin
     FComment2 := FComment;
  end else begin
     FComment2 := '';
  end;
end;
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetTrack(const NewTrack: Byte);
begin
  FTrack := NewTrack;
end;
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetGenreID(const NewGenreID: Byte);
begin
  FGenreID := NewGenreID;
end;
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.FSetGenre(const NewGenre: AnsiString);
var
  i: integer;
begin
  FGenreID := 255;
  for i := 0 to MAX_MUSIC_GENRES - 1 do begin
     {$IFNDEF DELPHI_2007_BELOW}
      if AnsiStrings.UpperCase( aTAG_MusicGenre[ i ] ) = AnsiStrings.UpperCase( NewGenre ) then begin
     {$ELSE}
      if UpperCase( aTAG_MusicGenre[ i ] ) = UpperCase( NewGenre ) then begin
     {$ENDIF}
         FGenreID := i;
         break;
      end
  end;
  if bTAG_GenreOther and ((FGenreID = 255) and (NewGenre <> '')) then FGenreID := 12; //   _OTHER_GENRE_ID = 12;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetTrackString: AnsiString;
begin
  if FTrack = 0 then begin
     result := '';
  end else begin
     result := IntToStr( FTrack );
  end;
end;
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetTitle: AnsiString;
begin
  if FTitle2 <> '' then begin
     result := FTitle2;
  end else begin
     result := FTitle;
  end;
end;
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetArtist: AnsiString;
begin
  if FArtist2 <> '' then begin
     result := FArtist2;
  end else begin
     result := FArtist;
  end;
end;
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetAlbum: AnsiString;
begin
  if FAlbum2 <> '' then begin
     result := FAlbum2;
  end else begin
     result := FAlbum;
  end;
end;
//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetComment: AnsiString;
begin
  if FComment2 <> '' then begin
     result := FComment2;
  end else begin
     result := FComment;
  end;
end;
//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetGenre: AnsiString;
begin
  Result := '';
  // Return an empty string if the current GenreID is not valid
  if FGenreID in [0..MAX_MUSIC_GENRES - 1] then Result := aTAG_MusicGenre[ FGenreID ];
end;
//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetLyrics2Size: integer;
begin
  if FLyrics2Size > 0 then begin
     result := FLyrics2Size + 15;
  end else begin
     result := 0;
  end;
end;
function TID3v1.FGetTagSize: integer;
begin
  result := Lyrics2Size;
  if FExists then result := result + 128;
end;
//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.FGetHasLyrics: boolean;
begin
 {$IFNDEF DELPHI_2007_BELOW}
  result := (AnsiStrings.Trim( Lyrics ) <> '' );
 {$ELSE}
  result := (Trim( Lyrics ) <> '' );
 {$ENDIF}
end;
//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.ReadTag(const FileName: WideString; bSetFields: boolean=true): Boolean;
var
  TagData: TagRecord;
  SourceFile: TTntFileStream;
  Mark: Lyr2Mark;
  Field: Lyr2Field;
  iOffSet, iFieldSize: integer;
  aBuff: array of AnsiChar;
begin

  try
    Result := true;
    // Set read-access and open file
    SourceFile := TTntFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);

    // Read id3v1 tag
    SourceFile.Seek(SourceFile.Size - 128, soFromBeginning);
    SourceFile.Read(TagData, 128);

    if TagData.Header = 'TAG' then begin
       FExists := true;
       if bSetFields then begin
          // set version
          if ((TagData.Comment[29] = #0) and (TagData.Comment[30] <> #0)) or
             ((TagData.Comment[29] = #32) and (TagData.Comment[30] <> #32)) then begin // Terms for ID3v1.1
             FVersionID := TAG_VERSION_1_1;
          end else begin
             FVersionID := TAG_VERSION_1_0;
          end;

         {$IFNDEF DELPHI_2007_BELOW}
          Title  := Ansistrings.TrimRight( TagData.Title );
          Artist := Ansistrings.TrimRight( TagData.Artist );
          Album  := Ansistrings.TrimRight( TagData.Album );
          Year   := Ansistrings.TrimRight( TagData.Year );
         {$ELSE}
          Title  := TrimRight( TagData.Title );
          Artist := TrimRight( TagData.Artist );
          Album  := TrimRight( TagData.Album );
          Year   := TrimRight( TagData.Year );
         {$ENDIF}

          if FVersionID = TAG_VERSION_1_0 then begin
            {$IFNDEF DELPHI_2007_BELOW}
             Comment := Ansistrings.TrimRight( TagData.Comment )
            {$ELSE}
             Comment := TrimRight( TagData.Comment )
            {$ENDIF}
          end else begin
            {$IFNDEF DELPHI_2007_BELOW}
             Comment := Ansistrings.TrimRight( Copy( TagData.Comment, 1, 28 ) );
            {$ELSE}
             Comment := TrimRight( Copy( TagData.Comment, 1, 28 ) );
            {$ENDIF}
             FTrack := Ord( TagData.Comment[30] );
          end;

          FGenreID := TagData.Genre;
       end;
    end;

    // try to read LYRICS2 tag
    iOffSet := 15;
    if FExists then iOffSet := iOffSet + 128;
    SourceFile.Seek(SourceFile.Size - iOffSet, soFromBeginning);
    SourceFile.Read(Mark, 15);
    if Mark.Mark = 'LYRICS200' then begin

       FLyrics2Size := StrToIntDef( Mark.Size, 0 );
       if FLyrics2Size > 0 then begin
          SourceFile.Seek(SourceFile.Size - (FLyrics2Size + iOffSet), soFromBeginning);
          SetLength( aBuff, 11 ); // LYRICSBEGIN
          SourceFile.Read(aBuff[0], 11);

          if String( aBuff ) = 'LYRICSBEGIN' then begin  // is it ok ?
             FExists2 := true;

             if bSetFields then begin
                while true do begin // read all fields

                   SourceFile.Read(Field, SizeOf(Field));
                   iFieldSize := StrToIntDef( Field.Size, -1 );
                   if iFieldSize < 0 then break;
                   SetLength( aBuff, iFieldSize );
                   SourceFile.Read(aBuff[0], iFieldSize);

                   if Field.ID = 'IND' then begin

                   end else if Field.ID = 'LYR' then begin
                     {$IFNDEF DELPHI_2007_BELOW}
                      Lyrics := Ansistrings.Trim(AnsiString( aBuff ) );
                     {$ELSE}
                      Lyrics := Trim(AnsiString( aBuff ) );
                     {$ENDIF}
                     {$IFNDEF DELPHI_2007_BELOW}
                      Lyrics := AnsiStrings.StringReplace( Lyrics, #13, #13#10, [rfReplaceAll] );
                      Lyrics := AnsiStrings.StringReplace( Lyrics, #13#10#10, #13#10, [rfReplaceAll] );
                     {$ELSE}
                      Lyrics := StringReplace( Lyrics, #13, #13#10, [rfReplaceAll] );
                      Lyrics := StringReplace( Lyrics, #13#10#10, #13#10, [rfReplaceAll] );
                     {$ENDIF}
                 {$IFNDEF DELPHI_2007_BELOW}
                   end else if Field.ID = 'INF' then begin
                      Comment := AnsiStrings.Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'AUT' then begin
                      Writer := AnsiStrings.Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'EAL' then begin
                      Album := AnsiStrings.Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'EAR' then begin
                      Artist := AnsiStrings.Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'ETT' then begin
                      Title := AnsiStrings.Trim(AnsiString( aBuff ) );
                 {$ELSE}
                   end else if Field.ID = 'INF' then begin
                      Comment := Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'AUT' then begin
                      Writer := Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'EAL' then begin
                      Album := Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'EAR' then begin
                      Artist := Trim(AnsiString( aBuff ) );
                   end else if Field.ID = 'ETT' then begin
                      Title := Trim(AnsiString( aBuff ) );
                 {$ENDIF}
                   end else if Field.ID = 'IMG' then begin
                      FIMG := AnsiString( aBuff );
                   end else begin
                      break;
                   end;

                end; //while
             end;
          end else begin
             FExists2 := false;
             FLyrics2Size := 0;
          end;

       end;

    end;

    // end
    SetLength( aBuff, 0 );
    SourceFile.Free;
  except
    Result := false; // Error
  end;

end;

//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.SaveTag(const FileName: WideString; bUseLYR2: boolean = true): Boolean;
var
  Tag: TagRecord;
  iFileAge: integer;
  SourceFile: TTntFileStream;
  iFilePos: integer;
  sTmp: ansistring;
  sTmp30: string[30];

  procedure WriteField( sID, sValue: ansistring );
  var
    iLen: integer;
  begin
   {$IFNDEF DELPHI_2007_BELOW}
    if Ansistrings.Trim( sValue ) <> '' then begin
   {$ELSE}
    if Trim( sValue ) <> '' then begin
   {$ENDIF}
       iLen := Length( sValue );

     {$IFNDEF DELPHI_2007_BELOW}
       sTmp := sID + AnsiStrings.DupeString( '0', 5 - Length( IntToStr( iLen ) ) ) + IntToStr( iLen ) + sValue;
     {$ELSE}
       sTmp := sID + DupeString( '0', 5 - Length( IntToStr( iLen ) ) ) + IntToStr( iLen ) + sValue;
     {$ENDIF}
       SourceFile.Write(sTmp[1], Length(sTmp));
    end;
  end;

begin

  result := true;
  iFileAge := 0;
  try

    if bTAG_PreserveDate then iFileAge := WideFileAge(FileName);

    // Allow write-access and open file
    WideFileSetAttr(FileName, 0);
    SourceFile := TTntFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);

    // Write lyrics2
    if bUseLYR2 and ( bTAG_UseLYRICS3 or ( (Lyrics <> '') or (Writer <> '') or ( FIMG <> '' ) ) ) then begin

       if (Lyrics <> '') or (Writer <> '') or
          (FArtist2 <> '') or (FAlbum2 <> '' ) or (FComment2 <> '') or (FTitle2 <> '') then begin

          SourceFile.Seek(SourceFile.Size, soFromBeginning);
          iFilePos := SourceFile.Position;

           SourceFile.Write('LYRICSBEGIN', 11);
           if Lyrics <> '' then begin
              SourceFile.Write('IND0000210', 10);
           end else begin
              SourceFile.Write('IND0000200', 10);
           end;

           WriteField( 'EAL', FAlbum2 );
           WriteField( 'EAR', FArtist2 );
           WriteField( 'ETT', FTitle2 );
           WriteField( 'INF', FComment2 );
           WriteField( 'AUT', Writer );
           WriteField( 'LYR', Lyrics );
           WriteField( 'IMG', FIMG );

           iFilepos := SourceFile.Position - iFilePos;
         {$IFNDEF DELPHI_2007_BELOW}
           sTmp := AnsiSTrings.DupeString( '0', 6 - Length( IntToStr( iFilepos ) ) ) + IntToStr( iFilepos ) + 'LYRICS200';
         {$ELSE}
           sTmp := DupeString( '0', 6 - Length( IntToStr( iFilepos ) ) ) + IntToStr( iFilepos ) + 'LYRICS200';
         {$ENDIF}
           SourceFile.Write(sTmp[1], Length(sTmp));
           FExists2 := true;
       end;

    end;

    // Write id3v1
    SourceFile.Seek(SourceFile.Size, soFromBeginning);

    FillChar( Tag, SizeOf( Tag ), 0);
    Tag.Header := 'TAG';

   {$IFNDEF DELPHI_2007_BELOW}
    sTmp30 := Ansistrings.TrimRight( Title );
    Move( sTmp30[1], Tag.Title  , Length( sTmp30 ) );
    sTmp30 := Ansistrings.TrimRight( Artist );
    Move( sTmp30[1], Tag.Artist , Length( sTmp30 ) );
    sTmp30 := Ansistrings.TrimRight( Album );
    Move( sTmp30[1], Tag.Album  , Length( sTmp30 ) );
    Move( Year[1], Tag.Year   , Length( Year )  );
    sTmp30 := Ansistrings.TrimRight( Comment );
   {$ELSE}
    sTmp30 := TrimRight( Title );
    Move( sTmp30[1], Tag.Title  , Length( sTmp30 ) );
    sTmp30 := TrimRight( Artist );
    Move( sTmp30[1], Tag.Artist , Length( sTmp30 ) );
    sTmp30 := TrimRight( Album );
    Move( sTmp30[1], Tag.Album  , Length( sTmp30 ) );
    Move( Year[1], Tag.Year   , Length( Year )  );
    sTmp30 := TrimRight( Comment );
   {$ENDIF}
    Move( sTmp30[1], Tag.Comment, Length( sTmp30 ) );
    if FTrack > 0 then begin
       Tag.Comment[29] := #0;
       Tag.Comment[30] := AnsiChar(FTrack);
    end;

    Tag.Genre := FGenreID;

    SourceFile.Write(Tag, SizeOf(Tag));

    SourceFile.Free;

    if bTAG_PreserveDate then WideFileSetDate(FileName, iFileAge);

  except
    result := false; // Error
  end;

end;

//-----------------------------------------------------------------------------------------------------------------------------------
procedure TID3v1.ResetData;
begin
  FExists := false;
  FVersionID := TAG_VERSION_1_0;
  FTitle := '';
  FArtist := '';
  FAlbum := '';
  FYear := '';
  FComment := '';
  FTrack := 0;
  FGenreID := DEFAULT_GENRE;

  // lyrics 2
  FExists2 := false;
  FLyrics2Size := 0;
  Lyrics := '';
  Writer := '';
  FArtist2 := '';
  FAlbum2 := '';
  FTitle2 := '';
  FComment2 := '';
  FIMG := '';
end;

//-----------------------------------------------------------------------------------------------------------------------------------
//  Public functions & procedures
//-----------------------------------------------------------------------------------------------------------------------------------
constructor TID3v1.Create;
begin
  inherited;
  ResetData;
end;

//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.ReadFromFile(const FileName: WideString): Boolean;
begin
  // Reset and load tag data from file to variable
  ResetData;
  Result := ReadTag(FileName);
end;
//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.SaveToFile(const FileName: WideString): Boolean;
begin
  // Delete old tag and write new tag
  result := (RemoveFromFile(FileName)) and (SaveTag(FileName));
  if (result) and ( not FExists ) then FExists := true;
  // NOTE
end;

//-----------------------------------------------------------------------------------------------------------------------------------
function TID3v1.RemoveFromFile(const FileName: WideString; bLyr2Only: boolean = false): Boolean;
var
  iFileAge: integer;
  SourceFile: TTntFileStream;
begin

  result := true;
  try

    ReadTag(FileName, false);
    if FExists or FExists2 then begin

       iFileAge := 0;
       if bTAG_PreserveDate then iFileAge := WideFileAge(FileName);

       Result := true;
       // Allow write-access and open file
       WideFileSetAttr(FileName, 0);
       SourceFile := TTntFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);

       // Delete id3v1
       if FExists then begin
          SourceFile.Seek(SourceFile.Size - 128, soFromBeginning);
          //truncate
          SourceFile.Size := SourceFile.Position;
          FExists := false;
       end;
       // Delete lyrics2
       if FExists2 then begin
          SourceFile.Seek(SourceFile.Size - Lyrics2Size, soFromBeginning);
          //truncate
          SourceFile.Size := SourceFile.Position;
          FExists2 := false;
       end;
       if bLyr2Only then begin
          if SaveTag(FileName, false) then begin
             FExists := true;
          end;
       end;      
       
       SourceFile.Free;

       if bTAG_PreserveDate then WideFileSetDate(FileName, iFileAge);
    end;

  except
    result := false; // Error
  end;

end;

function ReadID3v1TagFromStream(TagStream : pAnsiChar;
                                  var MP3TagInfo : TMP3TagInfo): Boolean; { Load tag from tag stream }
var
   TagData : TagRecord;
   VersionID, GenreID: Byte;
begin
   Result := false;

   Move(pointer(TagStream)^, TagData, 128);
   if (TagData.Header = 'TAG') then
   begin
      Result := true;

      if ((TagData.Comment[29] = #0) and (TagData.Comment[30] <> #0)) or
        ((TagData.Comment[29] = #32) and (TagData.Comment[30] <> #32)) then
         VersionID := TAG_VERSION_1_1
      else
         VersionID := TAG_VERSION_1_0;

    { Fill properties with tag data }
     {$IFNDEF DELPHI_2007_BELOW}
      MP3TagInfo.Title := Ansistrings.TrimRight(TagData.Title);
      MP3TagInfo.Artist := Ansistrings.TrimRight(TagData.Artist);
      MP3TagInfo.Album := Ansistrings.TrimRight(TagData.Album);
      MP3TagInfo.Year := Ansistrings.TrimRight(TagData.Year);
     {$ELSE}
      MP3TagInfo.Title := TrimRight(TagData.Title);
      MP3TagInfo.Artist := TrimRight(TagData.Artist);
      MP3TagInfo.Album := TrimRight(TagData.Album);
      MP3TagInfo.Year := TrimRight(TagData.Year);
     {$ENDIF}

      if VersionID = TAG_VERSION_1_0 then
      begin
        {$IFNDEF DELPHI_2007_BELOW}
         MP3TagInfo.Comment := Ansistrings.TrimRight(TagData.Comment);
        {$ELSE}
         MP3TagInfo.Comment := TrimRight(TagData.Comment);
        {$ENDIF}
         MP3TagInfo.Track := 0;
      end else
      begin
        {$IFNDEF DELPHI_2007_BELOW}
         MP3TagInfo.Comment := Ansistrings.TrimRight(Copy(TagData.Comment, 1, 28));
        {$ELSE}
         MP3TagInfo.Comment := TrimRight(Copy(TagData.Comment, 1, 28));
        {$ENDIF}
         MP3TagInfo.Track := Ord(TagData.Comment[30]);
      end;
      GenreID := TagData.Genre;
      if GenreID in [0..MAX_MUSIC_GENRES - 1] then
         MP3TagInfo.Genre := aTAG_MusicGenre[GenreID]
      else
         MP3TagInfo.Genre := 'Unknown';
   end;

end;

{ ************************** Initialize music genres ************************ }

initialization
begin
  //-- Initialize music genres
  { Standard genres }
  aTAG_MusicGenre[0] := 'Blues';
  aTAG_MusicGenre[1] := 'Classic Rock';
  aTAG_MusicGenre[2] := 'Country';
  aTAG_MusicGenre[3] := 'Dance';
  aTAG_MusicGenre[4] := 'Disco';
  aTAG_MusicGenre[5] := 'Funk';
  aTAG_MusicGenre[6] := 'Grunge';
  aTAG_MusicGenre[7] := 'Hip-Hop';
  aTAG_MusicGenre[8] := 'Jazz';
  aTAG_MusicGenre[9] := 'Metal';
  aTAG_MusicGenre[10] := 'New Age';
  aTAG_MusicGenre[11] := 'Oldies';
  aTAG_MusicGenre[12] := 'Other';
  aTAG_MusicGenre[13] := 'Pop';
  aTAG_MusicGenre[14] := 'R&B';
  aTAG_MusicGenre[15] := 'Rap';
  aTAG_MusicGenre[16] := 'Reggae';
  aTAG_MusicGenre[17] := 'Rock';
  aTAG_MusicGenre[18] := 'Techno';
  aTAG_MusicGenre[19] := 'Industrial';
  aTAG_MusicGenre[20] := 'Alternative';
  aTAG_MusicGenre[21] := 'Ska';
  aTAG_MusicGenre[22] := 'Death Metal';
  aTAG_MusicGenre[23] := 'Pranks';
  aTAG_MusicGenre[24] := 'Soundtrack';
  aTAG_MusicGenre[25] := 'Euro-Techno';
  aTAG_MusicGenre[26] := 'Ambient';
  aTAG_MusicGenre[27] := 'Trip-Hop';
  aTAG_MusicGenre[28] := 'Vocal';
  aTAG_MusicGenre[29] := 'Jazz+Funk';
  aTAG_MusicGenre[30] := 'Fusion';
  aTAG_MusicGenre[31] := 'Trance';
  aTAG_MusicGenre[32] := 'Classical';
  aTAG_MusicGenre[33] := 'Instrumental';
  aTAG_MusicGenre[34] := 'Acid';
  aTAG_MusicGenre[35] := 'House';
  aTAG_MusicGenre[36] := 'Game';
  aTAG_MusicGenre[37] := 'Sound Clip';
  aTAG_MusicGenre[38] := 'Gospel';
  aTAG_MusicGenre[39] := 'Noise';
  aTAG_MusicGenre[40] := 'AlternRock';
  aTAG_MusicGenre[41] := 'Bass';
  aTAG_MusicGenre[42] := 'Soul';
  aTAG_MusicGenre[43] := 'Punk';
  aTAG_MusicGenre[44] := 'Space';
  aTAG_MusicGenre[45] := 'Meditative';
  aTAG_MusicGenre[46] := 'Instrumental Pop';
  aTAG_MusicGenre[47] := 'Instrumental Rock';
  aTAG_MusicGenre[48] := 'Ethnic';
  aTAG_MusicGenre[49] := 'Gothic';
  aTAG_MusicGenre[50] := 'Darkwave';
  aTAG_MusicGenre[51] := 'Techno-Industrial';
  aTAG_MusicGenre[52] := 'Electronic';
  aTAG_MusicGenre[53] := 'Pop-Folk';
  aTAG_MusicGenre[54] := 'Eurodance';
  aTAG_MusicGenre[55] := 'Dream';
  aTAG_MusicGenre[56] := 'Southern Rock';
  aTAG_MusicGenre[57] := 'Comedy';
  aTAG_MusicGenre[58] := 'Cult';
  aTAG_MusicGenre[59] := 'Gangsta';
  aTAG_MusicGenre[60] := 'Top 40';
  aTAG_MusicGenre[61] := 'Christian Rap';
  aTAG_MusicGenre[62] := 'Pop/Funk';
  aTAG_MusicGenre[63] := 'Jungle';
  aTAG_MusicGenre[64] := 'Native American';
  aTAG_MusicGenre[65] := 'Cabaret';
  aTAG_MusicGenre[66] := 'New Wave';
  aTAG_MusicGenre[67] := 'Psychadelic';
  aTAG_MusicGenre[68] := 'Rave';
  aTAG_MusicGenre[69] := 'Showtunes';
  aTAG_MusicGenre[70] := 'Trailer';
  aTAG_MusicGenre[71] := 'Lo-Fi';
  aTAG_MusicGenre[72] := 'Tribal';
  aTAG_MusicGenre[73] := 'Acid Punk';
  aTAG_MusicGenre[74] := 'Acid Jazz';
  aTAG_MusicGenre[75] := 'Polka';
  aTAG_MusicGenre[76] := 'Retro';
  aTAG_MusicGenre[77] := 'Musical';
  aTAG_MusicGenre[78] := 'Rock & Roll';
  aTAG_MusicGenre[79] := 'Hard Rock';
  { Extended genres }
  aTAG_MusicGenre[80] := 'Folk';
  aTAG_MusicGenre[81] := 'Folk-Rock';
  aTAG_MusicGenre[82] := 'National Folk';
  aTAG_MusicGenre[83] := 'Swing';
  aTAG_MusicGenre[84] := 'Fast Fusion';
  aTAG_MusicGenre[85] := 'Bebob';
  aTAG_MusicGenre[86] := 'Latin';
  aTAG_MusicGenre[87] := 'Revival';
  aTAG_MusicGenre[88] := 'Celtic';
  aTAG_MusicGenre[89] := 'Bluegrass';
  aTAG_MusicGenre[90] := 'Avantgarde';
  aTAG_MusicGenre[91] := 'Gothic Rock';
  aTAG_MusicGenre[92] := 'Progressive Rock';
  aTAG_MusicGenre[93] := 'Psychedelic Rock';
  aTAG_MusicGenre[94] := 'Symphonic Rock';
  aTAG_MusicGenre[95] := 'Slow Rock';
  aTAG_MusicGenre[96] := 'Big Band';
  aTAG_MusicGenre[97] := 'Chorus';
  aTAG_MusicGenre[98] := 'Easy Listening';
  aTAG_MusicGenre[99] := 'Acoustic';
  aTAG_MusicGenre[100]:= 'Humour';
  aTAG_MusicGenre[101]:= 'Speech';
  aTAG_MusicGenre[102]:= 'Chanson';
  aTAG_MusicGenre[103]:= 'Opera';
  aTAG_MusicGenre[104]:= 'Chamber Music';
  aTAG_MusicGenre[105]:= 'Sonata';
  aTAG_MusicGenre[106]:= 'Symphony';
  aTAG_MusicGenre[107]:= 'Booty Bass';
  aTAG_MusicGenre[108]:= 'Primus';
  aTAG_MusicGenre[109]:= 'Porn Groove';
  aTAG_MusicGenre[110]:= 'Satire';
  aTAG_MusicGenre[111]:= 'Slow Jam';
  aTAG_MusicGenre[112]:= 'Club';
  aTAG_MusicGenre[113]:= 'Tango';
  aTAG_MusicGenre[114]:= 'Samba';
  aTAG_MusicGenre[115]:= 'Folklore';
  aTAG_MusicGenre[116]:= 'Ballad';
  aTAG_MusicGenre[117]:= 'Power Ballad';
  aTAG_MusicGenre[118]:= 'Rhythmic Soul';
  aTAG_MusicGenre[119]:= 'Freestyle';
  aTAG_MusicGenre[120]:= 'Duet';
  aTAG_MusicGenre[121]:= 'Punk Rock';
  aTAG_MusicGenre[122]:= 'Drum Solo';
  aTAG_MusicGenre[123]:= 'A capella';
  aTAG_MusicGenre[124]:= 'Euro-House';
  aTAG_MusicGenre[125]:= 'Dance Hall';
  aTAG_MusicGenre[126]:= 'Goa';
  aTAG_MusicGenre[127]:= 'Drum & Bass';
  aTAG_MusicGenre[128]:= 'Club-House';
  aTAG_MusicGenre[129]:= 'Hardcore';
  aTAG_MusicGenre[130]:= 'Terror';
  aTAG_MusicGenre[131]:= 'Indie';
  aTAG_MusicGenre[132]:= 'BritPop';
  aTAG_MusicGenre[133]:= 'Negerpunk';
  aTAG_MusicGenre[134]:= 'Polsk Punk';
  aTAG_MusicGenre[135]:= 'Beat';
  aTAG_MusicGenre[136]:= 'Christian Gangsta Rap';
  aTAG_MusicGenre[137]:= 'Heavy Metal';
  aTAG_MusicGenre[138]:= 'Black Metal';
  aTAG_MusicGenre[139]:= 'Crossover';
  aTAG_MusicGenre[140]:= 'Contemporary Christian';
  aTAG_MusicGenre[141]:= 'Christian Rock';
  aTAG_MusicGenre[142]:= 'Merengue';
  aTAG_MusicGenre[143]:= 'Salsa';
  aTAG_MusicGenre[144]:= 'Thrash Metal';
  aTAG_MusicGenre[145]:= 'Anime';
  aTAG_MusicGenre[146]:= 'JPop';
  aTAG_MusicGenre[147]:= 'Synthpop';

  //---
  bTAG_PreserveDate := false;
  bTAG_ID3v2PreserveALL := false;
  bTAG_UseLYRICS3 := false;
  bTAG_GenreOther := false;
end;


end.
