unit LibDefine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdGlobal, IdSSLOpenSSLHeaders, BassLibs, Dialogs;

var
  RootFolder: string;
  LibFolder: string;
  RuntimeFolder: string;

implementation


initialization
  RootFolder := ExtractFileDir(ParamStr(0)); // Get exe location

  {$IFDEF WINDOWS}
  // Windows
  LibFolder := RootFolder + '/shared-lib-win/';
  RuntimeFolder := RootFolder + '/runtime/';
  {$ELSE}
  // Linux
  if RootFolder = '/usr/bin' then
    begin
      LibFolder := '/usr/lib/ibroadcast/';
      RuntimeFolder := '/usr/share/ibroadcast/';
    end else
    begin
      LibFolder := RootFolder + '/shared-lib-linux/';
      RuntimeFolder := RootFolder + '/runtime/';
    end;
    {$ENDIF}

  // Libs
  BASS_DLL_PATH := LibFolder;
  IdOpenSSLSetLibPath( LibFolder );
end.

